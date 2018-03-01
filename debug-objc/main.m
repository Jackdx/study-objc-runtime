
//  main.m
//  debug-objc
//
//  Created by closure on 2/24/16.
//
//

#import <Foundation/Foundation.h>

// 宏的真假

/*
 __OBJC2__            真(判断是不是oc2.0以上)
 __OBJC__             真(判断是不是oc1.0以上)
 OBJC_TYPES_DEFINED   真(objc-private.h中定义为1)
 TARGET_OS_WIN32      假(判断是不是32位windows)
 TARGET_OS_MAC        真(判断是不是mac)
 PROTECT_AUTORELEASEPOOL 假(NSObject.mm定义为假)
 SUPPORT_NONPOINTER_ISA  假
 SUPPORT_GC_COMPAT    假(判断是否支持GC)
 SUPPORT_INDEXED_ISA  假
 */

int main(int argc, const char * argv[]) {
    @autoreleasepool {
#if SUPPORT_INDEXED_ISA
        NSLog(@"true");
#else
        NSLog(@"false");
#endif
        NSLog(@"Hello, World!");
    }
    return 0;
}
