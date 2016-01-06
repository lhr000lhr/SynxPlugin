//
//  CCPProject+SynxProject.m
//  TYDKSynxPlugin
//
//  Created by 李浩然 on 1/6/16.
//  Copyright © 2016 tydic-lhr. All rights reserved.
//

#import "CCPProject+SynxProject.h"

@implementation CCPProject (SynxProject)

- (NSString*)projectPath {
    return [NSString stringWithFormat:@"%@/%@.xcodeproj", self.directoryPath, self.projectName];
}

- (BOOL)hasProject {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self projectPath]];
}
@end
