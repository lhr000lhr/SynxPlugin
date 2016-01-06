//
//  NSObject_Extension.m
//  TYDKSynxPlugin
//
//  Created by 李浩然 on 1/6/16.
//  Copyright © 2016 tydic-lhr. All rights reserved.
//


#import "NSObject_Extension.h"
#import "TYDKSynxPlugin.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[TYDKSynxPlugin alloc] initWithBundle:plugin];
        });
    }
}
@end
