# objc-runtime
objc runtime 723

这个文件主要是帮助阅读此项目，添加了关键字搜索。

// 各种结构体
jack.deng  对象的定义
jack.deng  isa的定义
jack.deng   Class的定义
jack.deng  id的定义
jack.deng  class_rw_t结构体的定义
jack.deng    class_ro_t结构体的定义
jack.deng   class_data_bits_t结构体的定义

// 各种函数
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
