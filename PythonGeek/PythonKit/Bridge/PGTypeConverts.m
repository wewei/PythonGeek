//
//  PGTypeConverts.m
//  PythonGeek
//
//  Created by Wei Wei on 12/1/12.
//  Copyright (c) 2012 Wei Wei. All rights reserved.
//

#import "PGTypeConverts.h"

BOOL ConvertPythonObjectToObjCType(PyObject *pyObj, const char *type, char *buffer, int bufSize)
{
    // Not implemented
    return NO;
}

BOOL ConvertObjCTypeToPythonObject(const char *buffer, int size, const char *type, PyObject **pyObjRef)
{
    // Not implemented
    *pyObjRef = Py_None;
    return YES;
}
