

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


//----------------------------------------------------------------------------------------
/**

	BRDebug
	=======

	Useful run time debugging environmental variables

	Set DYLD_IMAGE_SUFFIX to _debug to load debug versions of dynamic libraries.
	Set NSDebugEnabled to YES to enable obj-c debug checks.
	Set NSZombieEnabled to YES to enable zombies to help catch the referencing of released objects.
	Set NSAutoreleaseFreedObjectCheckEnabled to YES to catch autorelease problems.
	Set MallocStackLoggingNoCompact to YES to track and save all memory allocations. Memory intensive.

	Check NSDebug.h for more debug switches.  Check Technical Note TN2124 and TN2239 for more info.

	Good exception breakpoints to set:

		objc_exception_throw
		NSInternalInconsistencyException


	May be helpful for iPhone Simulator: GTM_DISABLE_IPHONE_LAUNCH_DAEMONS 1

	Useful lldb macros (Works after Xcode 5.0):

	   command script import lldb.macosx.heap

	Search the heap for all references to the pointer 0x0000000116e13920:

	   ptr_refs -m 0x0000000116e13920


*/
//----------------------------------------------------------------------------------------


#import <Foundation/Foundation.h>


#ifdef __cplusplus
extern "C" {
#endif


//@name 	BRDebugger Functions


//@function	BRDebuggerIsAttached
//@brief	BRDebuggerIsAttached
//@return	Returns true if the app is currently attached to a debugger.
extern BOOL BRDebuggerIsAttached();

///	@param 	class An objective-c class.
///	@return Returns an NSString* with a dump of the passed class.
extern NSString* _Nonnull BRNSStringFromClassDump(Class _Null_unspecified class);

///	@param	instance An object-c instance.
///	@return Returns an NSString* with a dump of the methods and member variables of the instance.
extern NSString* _Nonnull BRNSStringFromInstanceDump(id<NSObject> _Null_unspecified instance);


#ifdef __cplusplus
}
#endif

