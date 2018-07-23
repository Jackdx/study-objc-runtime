/*
 * Copyright (c) 2004-2006 Apple Inc.  All Rights Reserved.
 * 
 * @APPLE_LICENSE_HEADER_START@
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
 */

/***********************************************************************
* objc-loadmethod.m
* Support for +load methods.
**********************************************************************/

#include "objc-loadmethod.h"
#include "objc-private.h"

typedef void(*load_method_t)(id, SEL);

struct loadable_class {
    Class cls;  // may be nil
    IMP method;
};

struct loadable_category {
    Category cat;  // may be nil
    IMP method;
};


// List of classes that need +load called (pending superclass +load)
// This list always has superclasses first because of the way it is constructed
static struct loadable_class *loadable_classes = nil;
static int loadable_classes_used = 0;
static int loadable_classes_allocated = 0;

// List of categories that need +load called (pending parent class +load)
static struct loadable_category *loadable_categories = nil;
static int loadable_categories_used = 0;
static int loadable_categories_allocated = 0;


/***********************************************************************
* add_class_to_loadable_list
* Class cls has just become connected. Schedule it for +load if
* it implements a +load method.
**********************************************************************/
// jack.deng  void add_class_to_loadable_list(Class cls)
void add_class_to_loadable_list(Class cls)
{
    /*
     在add_class_to_loadable_list中我们能看到将类与load方法存储进loadable_classes的代码段,那么loadable_classes是什么呢?
     loadable_classes是一个loadable_class类型的列表,存储需要调用load方法的类, 而loadable_class是一个只有cls和方法实现method的结构体.
     其中loadable_classes_allocated 标识已分配的内存空间大小，loadable_classes_used则标识已使用的内存空间大小,当内存空间不够时,会进行扩容操作.
     在这一部分,也就是将需要执行+load方法的类与其对应的方法实现存储到loadable_classes表中.
     */
    IMP method;

    loadMethodLock.assertLocked();

    //获取load方法
    method = cls->getLoadMethod();
    if (!method) return;  // Don't bother if cls has no +load method
    
    if (PrintLoading) {
        _objc_inform("LOAD: class '%s' scheduled for +load", 
                     cls->nameForLogging());
    }
    //扩容
    if (loadable_classes_used == loadable_classes_allocated) {
        loadable_classes_allocated = loadable_classes_allocated*2 + 16;
        loadable_classes = (struct loadable_class *)
            realloc(loadable_classes,
                              loadable_classes_allocated *
                              sizeof(struct loadable_class));
    }
    //存储
    loadable_classes[loadable_classes_used].cls = cls;
    loadable_classes[loadable_classes_used].method = method;
    loadable_classes_used++;
}


/***********************************************************************
* add_category_to_loadable_list
* Category cat's parent class exists and the category has been attached
* to its class. Schedule this category for +load after its parent class
* becomes connected and has its own +load method called.
**********************************************************************/

// jack.deng void add_category_to_loadable_list(Category cat)
void add_category_to_loadable_list(Category cat)
{
    /*
     add_category_to_loadable_list方法的实现和类的处理(add_class_to_loadable_list(Class cls))相似,将类别和对应的方法实现存储进loadable_categories列表中.
     */
    IMP method;

    loadMethodLock.assertLocked();

    method = _category_getLoadMethod(cat);

    // Don't bother if cat has no +load method
    if (!method) return;

    if (PrintLoading) {
        _objc_inform("LOAD: category '%s(%s)' scheduled for +load", 
                     _category_getClassName(cat), _category_getName(cat));
    }
    
    if (loadable_categories_used == loadable_categories_allocated) {
        loadable_categories_allocated = loadable_categories_allocated*2 + 16;
        loadable_categories = (struct loadable_category *)
            realloc(loadable_categories,
                              loadable_categories_allocated *
                              sizeof(struct loadable_category));
    }

    loadable_categories[loadable_categories_used].cat = cat;
    loadable_categories[loadable_categories_used].method = method;
    loadable_categories_used++;
}


/***********************************************************************
* remove_class_from_loadable_list
* Class cls may have been loadable before, but it is now no longer 
* loadable (because its image is being unmapped). 
**********************************************************************/
void remove_class_from_loadable_list(Class cls)
{
    loadMethodLock.assertLocked();

    if (loadable_classes) {
        int i;
        for (i = 0; i < loadable_classes_used; i++) {
            if (loadable_classes[i].cls == cls) {
                loadable_classes[i].cls = nil;
                if (PrintLoading) {
                    _objc_inform("LOAD: class '%s' unscheduled for +load", 
                                 cls->nameForLogging());
                }
                return;
            }
        }
    }
}


/***********************************************************************
* remove_category_from_loadable_list
* Category cat may have been loadable before, but it is now no longer 
* loadable (because its image is being unmapped). 
**********************************************************************/
void remove_category_from_loadable_list(Category cat)
{
    loadMethodLock.assertLocked();

    if (loadable_categories) {
        int i;
        for (i = 0; i < loadable_categories_used; i++) {
            if (loadable_categories[i].cat == cat) {
                loadable_categories[i].cat = nil;
                if (PrintLoading) {
                    _objc_inform("LOAD: category '%s(%s)' unscheduled for +load",
                                 _category_getClassName(cat), 
                                 _category_getName(cat));
                }
                return;
            }
        }
    }
}


/***********************************************************************
* call_class_loads
* Call all pending class +load methods.
* If new classes become loadable, +load is NOT called for them.
*
* Called only by call_load_methods().
**********************************************************************/

// jack.deng  static void call_class_loads(void)
static void call_class_loads(void)
{
    //1.初始化数据
    int i;
    // Detach current loadable list.
    struct loadable_class *classes = loadable_classes; //指向用于保存类信息的内存的首地址
    int used = loadable_classes_used;
    loadable_classes = nil;
    loadable_classes_allocated = 0;//标识已分配的内存空间大小，
    loadable_classes_used = 0;//标识已使用的内存空间大小
    
    // Call all +loads for the detached list.
    //2.调用load方法
    for (i = 0; i < used; i++) {
        Class cls = classes[i].cls;
        load_method_t load_method = (load_method_t)classes[i].method;
        if (!cls) continue; 

        if (PrintLoading) {
            _objc_inform("LOAD: +[%s load]\n", cls->nameForLogging());
        }
        /*
         也就是说load方法的调用是通过直接使用函数内存地址的方式实现的而不是最常见的消息发送objc_msgSend.
         也因为这个原因,类,分类,子类中的load方法调用除了遵循类>子类>分类的顺序外并无其他相关.具体来说,就是子类不会继承父类的实现,分类不会覆盖类的实现.
         */
        (*load_method)(cls, SEL_load);
    }
    
    // Destroy the detached list.
    //3. 清理数据
    if (classes) free(classes);
}


/***********************************************************************
* call_category_loads
* Call some pending category +load methods.
* The parent class of the +load-implementing categories has all of 
*   its categories attached, in case some are lazily waiting for +initalize.
* Don't call +load unless the parent class is connected.
* If new categories become loadable, +load is NOT called, and they 
*   are added to the end of the loadable list, and we return TRUE.
* Return FALSE if no new categories became loadable.
*
* Called only by call_load_methods().
**********************************************************************/

// jack.deng  static bool call_category_loads(void)
static bool call_category_loads(void)
{
    int i, shift;
    bool new_categories_added = NO;
    
    // Detach current loadable list.
    struct loadable_category *cats = loadable_categories;
    int used = loadable_categories_used;
    int allocated = loadable_categories_allocated;
    loadable_categories = nil;
    loadable_categories_allocated = 0;
    loadable_categories_used = 0;

    // Call all +loads for the detached list.
    for (i = 0; i < used; i++) {
        Category cat = cats[i].cat;
        load_method_t load_method = (load_method_t)cats[i].method;
        Class cls;
        if (!cat) continue;

        cls = _category_getClass(cat);
        if (cls  &&  cls->isLoadable()) {
            if (PrintLoading) {
                _objc_inform("LOAD: +[%s(%s) load]\n", 
                             cls->nameForLogging(), 
                             _category_getName(cat));
            }
            (*load_method)(cls, SEL_load);
            cats[i].cat = nil;
        }
    }

    // Compact detached list (order-preserving)
    shift = 0;
    for (i = 0; i < used; i++) {
        if (cats[i].cat) {
            cats[i-shift] = cats[i];
        } else {
            shift++;
        }
    }
    used -= shift;

    // Copy any new +load candidates from the new list to the detached list.
    new_categories_added = (loadable_categories_used > 0);
    for (i = 0; i < loadable_categories_used; i++) {
        if (used == allocated) {
            allocated = allocated*2 + 16;
            cats = (struct loadable_category *)
                realloc(cats, allocated *
                                  sizeof(struct loadable_category));
        }
        cats[used++] = loadable_categories[i];
    }

    // Destroy the new list.
    if (loadable_categories) free(loadable_categories);

    // Reattach the (now augmented) detached list. 
    // But if there's nothing left to load, destroy the list.
    if (used) {
        loadable_categories = cats;
        loadable_categories_used = used;
        loadable_categories_allocated = allocated;
    } else {
        if (cats) free(cats);
        loadable_categories = nil;
        loadable_categories_used = 0;
        loadable_categories_allocated = 0;
    }

    if (PrintLoading) {
        if (loadable_categories_used != 0) {
            _objc_inform("LOAD: %d categories still waiting for +load\n",
                         loadable_categories_used);
        }
    }

    return new_categories_added;
}


/***********************************************************************
* call_load_methods
* Call all pending class and category +load methods.
* Class +load methods are called superclass-first. 
* Category +load methods are not called until after the parent class's +load.
* 
* This method must be RE-ENTRANT, because a +load could trigger 
* more image mapping. In addition, the superclass-first ordering 
* must be preserved in the face of re-entrant calls. Therefore, 
* only the OUTERMOST call of this function will do anything, and 
* that call will handle all loadable classes, even those generated 
* while it was running.
*
* The sequence below preserves +load ordering in the face of 
* image loading during a +load, and make sure that no 
* +load method is forgotten because it was added during 
* a +load call.
* Sequence:
* 1. Repeatedly call class +loads until there aren't any more
* 2. Call category +loads ONCE.
* 3. Run more +loads if:
*    (a) there are more classes to load, OR
*    (b) there are some potential category +loads that have 
*        still never been attempted.
* Category +loads are only run once to ensure "parent class first" 
* ordering, even if a category +load triggers a new loadable class 
* and a new loadable category attached to that class. 
*
* Locking: loadMethodLock must be held by the caller 
*   All other locks must not be held.
**********************************************************************/

//  jack.deng  void call_load_methods(void)
void call_load_methods(void)
{
    static bool loading = NO;
    bool more_categories;

    loadMethodLock.assertLocked();

    // Re-entrant calls do nothing; the outermost call will finish the job.
    if (loading) return;
    loading = YES;

    void *pool = objc_autoreleasePoolPush();

    do {
        // 1. Repeatedly call class +loads until there aren't any more
         // 1. 调用类的load方法
        while (loadable_classes_used > 0) {
            call_class_loads();
        }

        // 2. Call category +loads ONCE
        // 2. 调用分类的load方法
        more_categories = call_category_loads();

        // 3. Run more +loads if there are classes OR more untried categories
         //3. 如果有未处理的继续执行
    } while (loadable_classes_used > 0  ||  more_categories);

    objc_autoreleasePoolPop(pool);

    loading = NO;
}


