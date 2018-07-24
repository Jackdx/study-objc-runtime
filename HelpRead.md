
### 这个文件主要是帮助阅读此项目，添加了关键字搜索。

// 各种结构体
jack.deng  对象的定义
jack.deng  isa的定义
jack.deng   Class的定义
jack.deng  id的定义
jack.deng  class_rw_t结构体的定义
jack.deng    class_ro_t结构体的定义
jack.deng   class_data_bits_t结构体的定义
jack.deng  category_t结构体的定义
jack.deng   class AutoreleasePoolPage的定义
jack.deng  class AssociationsManager的定义
jack.deng  struct ivar_t结构体
jack.deng   struct SideTable结构体
jack.deng  struct weak_table_t结构体

//  方法加载  各种函数
jack.deng  _objc_init(void)
jack.deng   ap_images_nolock(unsigned mhCount, co
jack.deng  _read_images(header_info **hList, uin
jack.deng  static Class realizeClass(Class cls)
jack.deng   static void methodizeClass(Class cls)
jack.deng  load_images(const char *path __unused, const
jack.deng  void prepare_load_methods(const headerType *mhdr)
jack.deng   void schedule_class_load(Class cls)
jack.deng  void add_class_to_loadable_list(Class cls)
jack.deng void add_category_to_loadable_list(Category cat)
jack.deng  void call_load_methods(void)
jack.deng  static bool call_category_loads(void)
jack.deng  static void call_class_loads(void)

//  方法调用  各种函数
jack.deng     _objc_msgSend_uncached
jack.deng    _class_lookupMethodAndLoadCache3
jack.deng   IMP _class_lookupMethodAndLoadCache3(id obj, SEL sel, Class cls)
jack.deng   IMP lookUpImpOrForward(Class cls, SEL sel, id inst
jack.deng   getMethodNoSuper_nolock(Class cls, SEL sel)
jack.deng  static method_t *search_method_list(const method_list_t *mlist
jack.deng  static method_t *findMethodInSortedMethodList(SEL key, const m
jack.deng   log_and_fill_cache(Class cls, IMP imp, SEL sel, id receiver, Class implementer)
jack.deng  void cache_fill(Class cls, SEL sel, IMP imp, id rece
jack.deng  static void cache_fill_nolock(Class cls, SEL sel, IMP imp, id receiver)

//  消息转发过程   各种函数
1.  动态方法解析   各种函数
jack.deng  void _class_resolveMethod(Class cls, SEL sel, id inst)
jack.deng  static void _class_resolveInstanceMethod(Class cls, SEL sel, id inst)
jack.deng  static void _class_resolveClassMethod(Class cls, SEL sel, id inst)

2.  查找备源接收者和完整消息转发   各种函数
jack.deng  __objc_msgForward_impcache
jack.deng  void *_objc_forward_handler = (void*)objc_defaultForwardHandler;
jack.deng  objc_defaultForwardHandler(id self, SEL sel)

//  分类category   各种函数
jack.deng  static void addUnattachedCategoryForClass(category_t *c
jack.deng  static void remethodizeClass(Class cls)
jack.deng   attachCategories(Class cls, category_list *cats, bool f

//   +load和+initialize    相关函数
jack.deng  void prepare_load_methods(const headerType *mhdr)
jack.deng  void call_load_methods(void)
jack.deng   void _class_initialize(Class cls)

//  autoreleasepool的实现    相关函数
jack.deng AutoreleasePoolPage(AutoreleasePoolPage *newParent)  构造函数
//  push过程
jack.deng   static inline void *push()
jack.deng   static inline id *autoreleaseFast(id obj)
jack.deng  static inline AutoreleasePoolPage *hotPage()
jack.deng  id *autoreleaseNoPage(id obj)
jack.deng  id *add(id obj)
jack.deng  id *autoreleaseFullPage(id obj, AutoreleasePoolPage *page)
jack.deng  static inline id autorelease(id obj)
//  pop过程
jack.deng  static inline void pop(void *token)

// Associated Object 相关函数
jack.deng  void objc_setAssociatedObject(id o
jack.deng  void _object_set_associative_reference(id object, void *key
jack.deng id objc_getAssociatedObject(id object, const
jack.deng   id _object_get_associative_reference(id object, void *key)
jack.deng  void objc_removeAssociatedObjects(id object)
jack.deng  void _object_remove_assocations(id object)

//  ivar 相关函数
jack.deng  static void reconcileInstanceVariables(Class cls, Class supercls, const
jack.deng  static void moveIvars(class_ro_t *ro, uint32_t superSize)

//  retain和release  相关函数
jack.deng  objc_object::rootRetain(bool tryRetain, bool handleOverflow)
jack.deng  objc_object::rootRelease(bool performDealloc, bool handleUnderflow)
jack.deng  objc_object::rootRetainCount()

//  alloc,init,new和dealloc  相关函数
jack.deng callAlloc(Class cls, bool checkNil, bool allocWithZone=false)
jack.deng  _class_createInstanceFromZone(Class cls, size_t ex
jack.deng  _objc_rootInit(id obj)
jack.deng  objc_object::rootDealloc()
jack.deng  object_dispose(id obj)
jack.deng  void *objc_destructInstance(id obj)
jack.deng  objc_object::clearDeallocating()
jack.deng  objc_object::clearDeallocating_slow()

//  weak实现   相关函数
jack.deng  objc_initWeak(id *location, id newObj)
jack.deng  storeWeak(id *location, objc_object *newObj
jack.deng  weak_unregister_no_lock(weak_table_t *weak_table
jack.deng  weak_register_no_lock(weak_table_t *weak_table
jack.deng  weak_clear_no_lock(weak_table_t *weak
