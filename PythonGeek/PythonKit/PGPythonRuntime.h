//
//  PGPythonRuntime.h
//  PythonGeek
//
//  Created by Wei Wei on 11/30/12.
//  Copyright (c) 2012 Wei Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kNotificationStdoutWritten;
extern NSString * const kNotificationStderrWritten;

extern NSString * const kUserInfoKeyText;

@interface PGPythonRuntime : NSObject

+ (PGPythonRuntime *)sharedRuntime;

- (void)resetInterpreter;

- (void)executeScriptString:(NSString *)scriptString;

@end
