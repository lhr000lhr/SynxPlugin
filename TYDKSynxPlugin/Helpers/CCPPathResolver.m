//
//  CCPEnvironmentUtils.m
//
//  Copyright (c) 2015 Delisa Mason. http://delisa.me
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

#import "CCPPathResolver.h"

@implementation CCPPathResolver

+ (NSString *)stringByAdjustingGemPathForEnvironment:(NSString *)path {
    NSString *newPath = [self stringByExpandingGemHomeInPath:path];
    newPath = [self stringByExpandingGemPathInPath:newPath];
    return [self stringByAdjustingRvmBinPath:newPath];
}

+ (NSString *)resolveHomePath {
    NSString *userId = [[[NSProcessInfo processInfo] environment] objectForKey:@"USER"];
    NSString *userHomePath = [[NSString stringWithFormat:@"~%@", userId] stringByExpandingTildeInPath];
    return userHomePath;
}

+ (NSString *)resolveWorkspacePath {
    NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];

    for (id controller in workspaceWindowControllers) {
        if ([[controller valueForKey:@"window"] isEqual:[NSApp keyWindow]]) {
            id workspace = [controller valueForKey:@"_workspace"];
            return [[workspace valueForKey:@"representingFilePath"] valueForKey:@"_pathString"];
        }
    }

    return nil;
}

+ (NSString *)resolveCommand:(NSString *)command forPath:(NSString *)path {
    NSArray *pathArray = [path componentsSeparatedByString:@":"];
    NSString *resolvedCommand = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    for (NSString *pathComponent in pathArray) {
        NSString *pathComponentWithCommand = [pathComponent stringByAppendingPathComponent:command];
        if ([fileManager isExecutableFileAtPath:pathComponentWithCommand]) {
            resolvedCommand = pathComponentWithCommand;
            break;
        }
    }

    return resolvedCommand;
}

+ (NSString *)resolveGemHome {
    return [self resolveGemEnvironmentVariable:@"gemdir"];
}

+ (NSString *)resolveGemPath {
    return [self resolveGemEnvironmentVariable:@"gempath"];
}

+ (NSString *)resolveGemEnvironmentVariable:(NSString *)variable {
    NSString *workspacePath = [self resolveWorkspacePath];
    if (!workspacePath)
        workspacePath = [self resolveHomePath];

    NSString *command = [NSString stringWithFormat:@"cd %@; gem env %@;", workspacePath, variable];
    NSPipe *pipe = [self outputPipeForBashTaskWithCommand:command];

    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *gemPath = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

    return [gemPath stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

+ (NSPipe *)outputPipeForBashTaskWithCommand:(NSString *)command {
    NSTask *task = [NSTask new];
    NSPipe *pipe = [NSPipe pipe];

    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[ @"-l", @"-c", command ]];
    [task setStandardOutput:pipe];
    [task launch];
    return pipe;
}

/**
 *  adjust path rvm, adding /wrappers in addition to /bin
 *
 *  @param path path containing possible replacements
 *
 *  @return updated path
 */
+ (NSString *)stringByAdjustingRvmBinPath:(NSString *)path {
    NSArray *paths = [path componentsSeparatedByString:@":"];
    NSMutableArray *adjustedPaths = [paths mutableCopy];
    if ([paths count] > 0) {
        int adjustmentsMade = 0;
        for (int i = 0; i < paths.count; i++) {
            NSString *pathComponent = paths[i];
            NSRange rangeRvm = [pathComponent rangeOfString:@".rvm"];
            NSRange rangeBin = [pathComponent rangeOfString:@"/bin" options:NSBackwardsSearch];

            if (rangeRvm.location != NSNotFound && rangeBin.location != NSNotFound) {
                NSString *adjustedPathComponent = [pathComponent stringByReplacingOccurrencesOfString:[pathComponent substringWithRange:rangeBin]
                                                                                           withString:@"/wrappers"
                                                                                              options:0
                                                                                                range:rangeBin];
                [adjustedPaths insertObject:adjustedPathComponent atIndex:i + adjustmentsMade];
                adjustmentsMade++;
            }
        }
    }

    return [adjustedPaths componentsJoinedByString:@":"];
}

/**
 *  resolve instances of $GEM_HOME, ${GEM_HOME}
 *
 *  @param path path containing possible replacements
 *
 *  @return path with GEM_HOME references replaced
 */
+ (NSString *)stringByExpandingGemHomeInPath:(NSString *)path {
    NSString *gemHome = [self resolveGemHome];
    NSString *newPath = [path stringByReplacingOccurrencesOfString:@"$GEM_HOME" withString:gemHome];
    return [[newPath stringByReplacingOccurrencesOfString:@"${GEM_HOME}" withString:gemHome] stringByStandardizingPath];
}

/**
 *  // resolve instances of $GEM_PATH, ${GEM_PATH}
 *
 *  @param path path containing possible replacements
 *
 *  @return path with GEM_PATH references replaced
 */
+ (NSString *)stringByExpandingGemPathInPath:(NSString *)path {
    NSString *gemPath = [self resolveGemPath];
    NSString *newPath = [path stringByReplacingOccurrencesOfString:@"$GEM_PATH" withString:gemPath];
    return [[newPath stringByReplacingOccurrencesOfString:@"${GEM_PATH}" withString:gemPath] stringByStandardizingPath];
}

@end
