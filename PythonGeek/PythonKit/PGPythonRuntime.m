//
//  PGPythonRuntime.m
//  PythonGeek
//
//  Created by Wei Wei on 11/30/12.
//  Copyright (c) 2012 Wei Wei. All rights reserved.
//

#import <objc/runtime.h>
#import "Python.h"

#import "PGPythonRuntime.h"


NSString * const kNotificationStdoutWritten = @"NOTIFICATION_STDOUT_WRITTEN";
NSString * const kNotificationStderrWritten = @"NOTIFICATION_STDERR_WRITTEN";

NSString * const kUserInfoKeyText = @"TEXT";

static PyObject *stdout_write(PyObject *self, PyObject *args)
{
    const char *text;
    if (!PyArg_ParseTuple(args, "s", &text))
        return NULL;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:text]
                                                         forKey:kUserInfoKeyText];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStdoutWritten
                                                        object:[PGPythonRuntime sharedRuntime]
                                                      userInfo:userInfo];
    return Py_None;
}

static PyMethodDef stdout_methods[] = {
    {"write", stdout_write, METH_VARARGS, "Write something"},
    {NULL, NULL, 0, NULL},
};

static PyObject *stderr_write(PyObject *self, PyObject *args)
{
    const char *text;
    if (!PyArg_ParseTuple(args, "s", &text))
        return NULL;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:text]
                                                         forKey:kUserInfoKeyText];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStderrWritten
                                                        object:[PGPythonRuntime sharedRuntime]
                                                      userInfo:userInfo];
    return Py_None;
}

static PyMethodDef stderr_methods[] = {
    {"write", stderr_write, METH_VARARGS, "Write something"},
    {NULL, NULL, 0, NULL},
};


@implementation PGPythonRuntime

- (id)init
{
    return nil;
}

- (id)initInternal {
    self = [super init];
    if (self) {
        [self resetInterpreter];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

static PGPythonRuntime *_sharedRuntime = nil;

+ (PGPythonRuntime *)sharedRuntime {
    if (_sharedRuntime == nil)
        _sharedRuntime = [[PGPythonRuntime alloc] initInternal];
    return _sharedRuntime;
}

- (void)resetInterpreter
{
    [self finalizeInterpreter];
    [self initializeInterpreter];
}

- (void)setPythonHome
{
    NSString *pythonPath = [[NSBundle mainBundle] resourcePath];
    int length = pythonPath.length;
    char *buffer = malloc(length + 1);
    if (buffer) {
        memccpy(buffer, pythonPath.UTF8String, length, length + 1);
        buffer[length] = '\0';
        Py_SetPythonHome(buffer);
        free(buffer);
    }
}

- (void)overrideStreams
{
    PyObject * m = NULL;
    m = Py_InitModule("override_stdout", stdout_methods);
    if (m)
        PySys_SetObject("stdout", m);
    m = Py_InitModule("override_stderr", stderr_methods);
    if (m)
        PySys_SetObject("stderr", m);
}

- (void)initializeInterpreter
{
    [self setPythonHome];
    Py_NoSiteFlag = 1;
    Py_Initialize();
    [self overrideStreams];
}

- (void)finalizeInterpreter
{
    if (Py_IsInitialized())
        Py_Finalize();
}

- (void)executeScriptString:(NSString *)scriptString
{
    assert(Py_IsInitialized());
    PyRun_SimpleString(scriptString.UTF8String);
}


@end
