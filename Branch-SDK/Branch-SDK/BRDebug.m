

//----------------------------------------------------------------------------------------
//
//																				 BRDebug.h
//																		  Branch.framework
//
//                                                                          Debugging Aids
//                                                              Edward Smith, October 2016
//
//                                   -©- Copyright © 2016 Branch, all rights reserved. -©-
//
//----------------------------------------------------------------------------------------


#include <sys/sysctl.h>
#import  <objc/runtime.h>
#import "BRDebug.h"


BOOL BRDebuggerIsAttached()
	{
	//	From an Apple tech note that I've lost --EB Smith

    //	Returns true if the current process is being debugged (either
    //	running under the debugger or has a debugger attached post facto).

    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;

    //	Initialize the flags so that, if sysctl fails for some bizarre
    //	reason, we get a predictable result.

    info.kp_proc.p_flag = 0;

    //	Initialize mib, which tells sysctl the info we want, in this case
    // 	we're looking for information about a specific process ID.

    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();

    //	Call sysctl.

    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);

    //	We're being debugged if the P_TRACED flag is set.

    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
	}


NSString* _Nonnull BRNSStringFromClassDump(Class _Null_unspecified class)
	{
	//	Dump the class --

	if (!class) return @"\nClass is 'nil'.\n";

	const char* superclassname = "nil";
	Class superclass = class_getSuperclass(class);
	if (superclass) superclassname = class_getName(superclass);
	if (!superclassname) superclassname = "<nil>";

    NSMutableString *result = [NSMutableString stringWithCapacity:512];
    [result appendFormat:@"\nClass '%s' of class '%s':\n",
        class_getName(class), superclassname];

	uint count = 0;
	Method *methods = class_copyMethodList(object_getClass(class), &count);
	for (int i = 0; i < count; ++i)
        [result appendFormat:@"\tClass method name: '%s'.\n",
            sel_getName(method_getName(methods[i]))];
	if (methods) free(methods);

	count = 0;
	methods = class_copyMethodList(class, &count);
	for (int i = 0; i < count; ++i)
        [result appendFormat:@"\tMethod name: '%s'.\n",
            sel_getName(method_getName(methods[i]))];
	if (methods) free(methods);

	count = 0;
	Ivar *ivars = class_copyIvarList(class, &count);
	for (int i = 0; i < count; ++i)
        [result appendFormat:@"\tIvar name: '%s'.\n",
            ivar_getName(ivars[i])];
	if (ivars) free(ivars);

	count = 0;
	objc_property_t *properties = class_copyPropertyList(class, &count);
	for (int i = 0; i < count; ++i)
        [result appendFormat:@"\tProperty name: '%s'.\n",
            property_getName(properties[i])];
	if (properties) free(properties);

    return result;
	}


NSString * _Nonnull BRNSStringFromInstanceDump(id<NSObject> _Null_unspecified instance)
	{
	//	Dump the class --

	if (!instance) return @"Instance is nil.\n";

	const char* superclassname = "nil";
	Class class = instance.class;	
	Class superclass = class_getSuperclass(class);
	if (superclass) superclassname = class_getName(superclass);
	if (!superclassname) superclassname = "<nil>";

    NSMutableString *result = [NSMutableString stringWithCapacity:512];
    [result appendFormat:@"\nInstance %p is of class '%s' of class '%s':\n",
        instance, class_getName(class), superclassname];

	uint count = 0;
	Method *methods = class_copyMethodList(object_getClass(class), &count);
	for (int i = 0; i < count; ++i)
        [result appendFormat:@"\tClass method name: '%s'.\n",
            sel_getName(method_getName(methods[i]))];
	if (methods) free(methods);

	count = 0;
	methods = class_copyMethodList(class, &count);
	for (int i = 0; i < count; ++i)
		[result appendFormat:@"\tMethod name: '%s'.\n",
            sel_getName(method_getName(methods[i]))];
	if (methods) free(methods);

	#define isTypeOf(encoding, type) \
        (strncmp(encoding, @encode(type), strlen(encoding)) == 0)

    #define LogValueOfType(type, format) \
		if (isTypeOf(encoding, type)) \
			[result appendFormat:@"\tIvar '%s' type '%s' value '"format"'.\n", \
                ivarName, #type, *((type*)ivarPtr)]; \
        else

	count = 0;
	Ivar *ivars = class_copyIvarList(class, &count);
	for (int i = 0; i < count; ++i)
		{
		const char* encoding = ivar_getTypeEncoding(ivars[i]);
        const char* ivarName = ivar_getName(ivars[i]);
        const void* ivarPtr = nil;
        if (encoding[0] == '@' || encoding[0] == '#')
            ivarPtr = (__bridge void*) object_getIvar(instance, ivars[i]);
        else
            ivarPtr = (void*) (((__bridge void*)instance) + ivar_getOffset(ivars[i]));

        if (encoding[0] == '@')
			[result appendFormat:@"\tIvar '%s' type '%@' value '%@'.\n",
                ivarName, NSStringFromClass(((__bridge id<NSObject>)ivarPtr).class), ivarPtr];
		else
		if (isTypeOf(encoding, Class))
			[result appendFormat:@"\tIvar '%s' type 'class' value '%@'.\n",
                ivarName, NSStringFromClass((__bridge Class _Nonnull)(ivarPtr))];
        else
		if (isTypeOf(encoding, int))
			[result appendFormat:@"\tIvar '%s' type '%s' value '%d'.\n",
                ivarName, "int", *((int*)ivarPtr)];
		else
        if (isTypeOf(encoding, char*))
			[result appendFormat:@"\tIvar '%s' type 'char*' value '%s'.\n",
                ivarName, *(char**)ivarPtr];
        else
            LogValueOfType(float, "%f")
            LogValueOfType(double, "%f")
            LogValueOfType(long double, "%Lf")
            LogValueOfType(char, "%c")
            LogValueOfType(int, "%d")
            LogValueOfType(short, "%hd")
            LogValueOfType(long, "%ld")
            LogValueOfType(long long, "%lld")
            LogValueOfType(unsigned char, "%c")
            LogValueOfType(unsigned int, "%u")
            LogValueOfType(unsigned short, "%hu")
            LogValueOfType(unsigned long, "%lu")
            LogValueOfType(unsigned long long, "%llu")
            [result appendFormat:@"\tIvar '%s' type '%s' (un-handled type).\n",
                ivarName, encoding];
		}
	if (ivars) free(ivars);

    #undef LogValueOfType
    #undef isTypeOf

	count = 0;
	objc_property_t *properties = class_copyPropertyList(class, &count);
	for (int i = 0; i < count; ++i)
        [result appendFormat:@"\tProperty name: '%s'.\n", property_getName(properties[i])];
	if (properties) free(properties);

    return result;
	}	

