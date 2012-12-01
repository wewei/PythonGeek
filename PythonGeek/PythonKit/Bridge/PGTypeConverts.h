//
//  PGTypeConverts.h
//  PythonGeek
//
//  Created by Wei Wei on 12/1/12.
//  Copyright (c) 2012 Wei Wei. All rights reserved.
//

#import "Python.h"

BOOL ConvertPythonObjectToObjCType(PyObject *pyObj, const char *type, char *buffer, int bufSize);
BOOL ConvertObjCTypeToPythonObject(const char *buffer, int size, const char *type, PyObject **pyObjRef);