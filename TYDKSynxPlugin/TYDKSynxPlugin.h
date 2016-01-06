//
//  TYDKSynxPlugin.h
//  TYDKSynxPlugin
//
//  Created by 李浩然 on 1/6/16.
//  Copyright © 2016 tydic-lhr. All rights reserved.
//

#import <AppKit/AppKit.h>

@class TYDKSynxPlugin;

static TYDKSynxPlugin *sharedPlugin;

@interface TYDKSynxPlugin : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end