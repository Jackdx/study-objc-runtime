
### 这个文件主要是帮助阅读此项目，添加了关键字搜索。

// 各种结构体
jack.deng  对象的定义
jack.deng  isa的定义
jack.deng   Class的定义
jack.deng  id的定义
jack.deng  class_rw_t结构体的定义
jack.deng    class_ro_t结构体的定义
jack.deng   class_data_bits_t结构体的定义

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

