//
//  CCPProject+SynxProject.h
//  TYDKSynxPlugin
//
//  Created by 李浩然 on 1/6/16.
//  Copyright © 2016 tydic-lhr. All rights reserved.
//

#import "CCPProject.h"

@interface CCPProject (SynxProject)

- (NSString*)projectPath;
- (BOOL)hasProject;
@end
