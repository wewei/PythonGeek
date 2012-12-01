//
//  PGObjCObject.m
//  PythonGeek
//
//  Created by Wei Wei on 12/1/12.
//  Copyright (c) 2012 Wei Wei. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/objc-runtime.h>
#import "Python.h"
#import "structmember.h"

#import "PGObjCObject.h"
#import "PGTypeConverts.h"


typedef struct
{
    PyObject_HEAD
    id target;
} PGObjCObject;

static void PGObjCObject_dealloc(PGObjCObject *ego)
{
    [ego->target release];
    ego->ob_type->tp_free((PyObject *)ego);
}

static PyObject *PGObjCObject_new(PyTypeObject *type, PyObject *args, PyObject *kwds)
{
    PGObjCObject *ego;
    ego = (PGObjCObject *)type->tp_alloc(type, 0);
    if (ego != NULL) {
        ego->target = nil;
    }
    return (PyObject *)ego;
}

static int PGObjCObject_init(PGObjCObject *ego, PyObject *args, PyObject *kwds)
{
    ego->target = [[NSString alloc] initWithFormat:@"Hello! (%@)", [NSDate date]];
    return 0;
}

static PyObject *PGObjCObject_str(PGObjCObject *ego)
{
    return Py_BuildValue("s", ((NSString *)ego->target).UTF8String);
}

typedef struct {
    // The initial arguments
    PGObjCObject *object;
    PyObject *arguments;
    
    // Prepared by sendMessage_parseArguments
    id target;
    char *selectorName;
    PyObject *parameters;
    
    // Prepared by sendMessage_createInvocation
    NSMethodSignature *methodSignature;
    SEL selector;
    NSInvocation *invocation;
    
    // Prepared by sendMessage_buildReturnValue
    PyObject *returnValue;
    
} SendMessageContext;

static BOOL sendMessage_parseArguments(SendMessageContext *ctx)
{
    ctx->target = ctx->object->target;
    if (!PyArg_ParseTuple(ctx->arguments, "sO", &ctx->selectorName, &ctx->parameters))
        return NO;
    return YES;
}


#define BUFFER_SIZE 256

static BOOL sendMessage_prepareParameters(SendMessageContext *ctx)
{
    if (!PySequence_Check(ctx->parameters))
        return NO;
    int i, size = PySequence_Size(ctx->parameters);
    for (i = 0; i < size; i++) {
        char buf[BUFFER_SIZE];
        PyObject *param = PySequence_GetItem(ctx->parameters, i);
        if (!ConvertPythonObjectToObjCType(param, [ctx->methodSignature getArgumentTypeAtIndex:i], buf, BUFFER_SIZE))
            return NO;
        [ctx->invocation setArgument:buf atIndex:i];
    }
    return YES;
}

static BOOL sendMessage_createInvocation(SendMessageContext *ctx)
{
    SEL selector = sel_registerName(ctx->selectorName);
    ctx->selector = selector;
    
    NSMethodSignature *methodSignature = [ctx->target methodSignatureForSelector:selector];
    ctx->methodSignature = methodSignature;
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.target = ctx->target;
    invocation.selector = selector;    
    ctx->invocation = invocation;

    if (ctx->parameters)
        return sendMessage_prepareParameters(ctx);
    return YES;
}

static BOOL sendMessage_invoke(SendMessageContext *ctx)
{
    @try {
        [ctx->invocation invoke];
    }
    @catch (NSException *exception) {
        return NO;
    }
    return YES;
}

static BOOL sendMessage_buildReturnValue(SendMessageContext *ctx)
{
    char buf[BUFFER_SIZE];
    NSMethodSignature *sig = ctx->methodSignature;
    [ctx->invocation getReturnValue:buf];
    
    // DEBUG
    NSLog(@"%d", *(int *)buf);

    return ConvertObjCTypeToPythonObject(buf, sig.methodReturnLength, sig.methodReturnType, &ctx->returnValue);
}

static PyObject *PGObjCObject_sendMessage(PGObjCObject *ego, PyObject *args)
{
    SendMessageContext ctxObj = { ego, args };
    if (!sendMessage_parseArguments(&ctxObj))
        return NULL;
    if (!sendMessage_createInvocation(&ctxObj))
        return NULL;
    if (!sendMessage_invoke(&ctxObj))
        return NULL;
    if (!sendMessage_buildReturnValue(&ctxObj))
        return NULL;
    return ctxObj.returnValue;
}

//static PyMemberDef PGObjCObject_members[] = {
//    {NULL}  /* Sentinel */
//};
//
//static PyGetSetDef PGObjCObject_getset[] = {
//    {NULL}  /* Sentinel */
//};

static PyMethodDef PGObjCObject_methods[] = {
    {"sendMessage", (PyCFunction)PGObjCObject_sendMessage, METH_VARARGS, "Send ObjC message."},
    {NULL}  /* Sentinel */
};


static PyTypeObject PGObjCObject_type = {
    PyObject_HEAD_INIT(NULL)
    0,                                  /* ob_size */
    "PythonGeek.ObjCObject",            /* tp_name */
    sizeof(PGObjCObject),               /* tp_basicsize */
    0,                                  /* tp_itemsize */
    (destructor)PGObjCObject_dealloc,   /* tp_dealloc */
    0,                                  /* tp_print */
    0,                                  /* tp_getattr */
    0,                                  /* tp_setattr */
    0,                                  /* tp_compare */
    0,                                  /* tp_repr */
    0,                                  /* tp_as_number */
    0,                                  /* tp_as_sequence */
    0,                                  /* tp_as_mapping */
    0,                                  /* tp_hash */
    0,                                  /* tp_call */
    (reprfunc)PGObjCObject_str,         /* tp_str */
    0,                                  /* tp_getattro */
    0,                                  /* tp_setattro */
    0,                                  /* tp_as_buffer */
    Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE,
                                        /* tp_flags */
    "ObjC bridged object",              /* tp_doc */
    0,                                  /* tp_traverse */
    0,                                  /* tp_clear */
    0,                                  /* tp_richcompare */
    0,                                  /* tp_weaklistoffset */
    0,                                  /* tp_iter */
    0,                                  /* tp_iternext */
    PGObjCObject_methods,               /* tp_methods */
    0,                                  /* tp_members */
    0,                                  /* tp_getset */
    0,                                  /* tp_base */
    0,                                  /* tp_dict */
    0,                                  /* tp_descr_get */
    0,                                  /* tp_descr_set */
    0,                                  /* tp_dictoffset */
    (initproc)PGObjCObject_init,        /* tp_init */
    0,                                  /* tp_alloc */
    PGObjCObject_new,                   /* tp_new */
};

void AddPGObjCObjectToModule(PyObject *module)
{
    if (PyType_Ready(&PGObjCObject_type) < 0)
        return;
    PyModule_AddObject(module, "ObjCObject", (PyObject *)&PGObjCObject_type);
}


