//
//  NuxeoDriveUtils.m
//  NuxeoDrive
//
/* (C) Copyright 2013-2014 Nuxeo SA (http://nuxeo.com/) and contributors.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser General Public License
 * (LGPL) version 2.1 which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl-2.1.html
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * Contributors:
 * 	Matthias Rouberol
 */

#import "NuxeoDriveUtils.h"

@implementation NuxeoLog

+ (void)logLogo
{
	NSString* aLineA = @"----------------------------------------------------------------------";
	NSString* aLine1 = @"  _   _ _   ___  _______ ___  ";
	NSString* aLine2 = @" | \\ | | | | \\ \\/ / ____/ _ \\ ";
	NSString* aLine3 = @" |  \\| | | | |\\  /|  _|| | | |";
	NSString* aLine4 = @" | |\\  | |_| |/  \\| |___ |_| |";
	NSString* aLine5 = @" |_| \\_|\\___//_/\\_\\_____\\___/ ";
	
	NSString* aStr = [[NSString alloc] initWithFormat:@"Powered by: \n\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n\n", aLineA, aLine1, aLine2, aLine3, aLine4, aLine5, aLineA];
	
	[self logString:aStr];
	
	[aStr release];
    
}

+ (void)logString:(NSString *)iStr
{
	// We'll log strings asynchrnously into a low priority quue
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
	
	// This will be used to make sure that the strings are logged
	// in the same order they came in
	static NSString* _lock_ = nil;
	if (_lock_ == nil)
		_lock_ = [[NSString alloc] init];
    
	// log everything in the background especially because logging
	// into the file will be SLOW !
	dispatch_async(queue, ^{
		
		@synchronized(_lock_)
		{
			NSLog(@"%@", iStr);
            
#ifdef NUXEO_LOG_FILE
#if TARGET_IPHONE_SIMULATOR
			NSDate* aDate = [NSDate date];
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
			[self logString:[NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:aDate], iStr] toFile:[self logFilePath]];
			[dateFormatter release];
#endif
#endif
		}
	});
	
}

+ (NSString *)logFilePath
{
	NSString* aFileName = [[[NSProcessInfo processInfo] processName] stringByAppendingString:@".log"];
	aFileName = [aFileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	
    NSArray *aPaths	= NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath	= [aPaths objectAtIndex:0];
		
	return [cachePath stringByAppendingPathComponent:aFileName];
}

+ (void)clearLogFile
{
	NSString* aFilePath = [self logFilePath];
	NSError* aError = nil;
	NSFileManager* aFileManager = [NSFileManager defaultManager];
    
	if ([aFileManager fileExistsAtPath:aFilePath])
	{
		[aFileManager removeItemAtPath:aFilePath error:&aError];
		if (aError != nil)
			NuxeoLogE(@"Failed to remove cache with reason %@", [aError description]);
	}
	
	BOOL aIsFileCreated = [aFileManager createFileAtPath:aFilePath contents:nil attributes:nil];
	
	if (!aIsFileCreated)
		NuxeoLogE(@"Failed to create log file at path %@", aFilePath);
}

+ (void)logString:(NSString *)iStr toFile:(NSString *)logFilePath
{
	NSString* aFilePath = [self logFilePath];
	
	iStr = [iStr stringByAppendingString:@"\n"];
	
	// Use a file handle to write at the end of the file
	NSFileHandle *aFileHandler = [NSFileHandle fileHandleForWritingAtPath:aFilePath];
	[aFileHandler seekToEndOfFile];
	[aFileHandler writeData:[iStr dataUsingEncoding:NSUTF8StringEncoding]];
	[aFileHandler closeFile];
	
}

+ (void) log:(char *)sourceFile
  lineNumber:(int)lineNumber
	  method:(const char*)method
	logLevel:(NuxeoLogLevel)logLevel
	  format:(NSString *)format, ...
{
	// We ignore the log the trigger does not match
#ifndef NUXEO_LOG_LEVEL
	return;
#endif
	
	NSString * logLevelString;
	switch (logLevel)
	{
		case NuxeoLogLevelDebug:
		default:
			logLevelString = @"DBG";
			break;
		case NuxeoLogLevelInfo:
			logLevelString = @"INF";
			break;
		case NuxeoLogLevelWarning:
			logLevelString = @"WRN";
			break;
		case NuxeoLogLevelError:
			logLevelString = @"ERR";
			break;
		case NuxeoLogLevelFatal:
			logLevelString = @"FTL";
			break;
	}
	
	NSString * filePath = [[NSString alloc] initWithBytes:sourceFile length:strlen(sourceFile) encoding:NSUTF8StringEncoding];
	
	va_list arguments;
	va_start(arguments, format);
	const NSString* str = [[NSString alloc] initWithFormat:format arguments:arguments];
	va_end(arguments);
	
	NSString* aStringToLog = [[NSString alloc] initWithFormat:@"{%@ - %s:%d %s} %@", logLevelString, [[filePath lastPathComponent] UTF8String], lineNumber, method, str];
	
	[self logString:aStringToLog];
	
	[str release];
	[aStringToLog release];
	[filePath release];
}

+ (void) logWithStringLevel:(char *)sourceFile
				 lineNumber:(int)lineNumber
				   logLevel:(NuxeoLogLevel)logLevel
			 logLevelString:(NSString *)logLevelString
				  exception:(NSException *)exception
					 format:(NSString *)format, ...
{
#ifndef NUXEO_LOG_LEVEL
	return;
#endif
	
	NSString * filePath = [[NSString alloc] initWithBytes:sourceFile length:strlen(sourceFile) encoding:NSUTF8StringEncoding];
	va_list arguments;
	va_start(arguments, format);
	const NSString * print = [[NSString alloc] initWithFormat:format arguments:arguments];
	// Taken from http://stackoverflow.com/questions/1282364/iphone-exception-handling
	// The reference discussion on Apple is under http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/Exceptions/Tasks/ControllingAppResponse.html#//apple_ref/doc/uid/20000473-DontLinkElementID_3
	const NSString * allPrint = [[NSString alloc] initWithFormat:@"%@\nException:%@\n%@", print, [exception reason], [exception callStackReturnAddresses]];
	va_end(arguments);
	
	NSString* aStringToLog = [[NSString alloc] initWithFormat:@"[%@ - %s:%d] %@", logLevelString, /*[[NSThread currentThread] name],*/ [[filePath lastPathComponent] UTF8String], lineNumber, allPrint];
	
	[self logString:aStringToLog];
	
	[allPrint release];
	[print release];
	[filePath release];
	[aStringToLog release];
}

@end


@implementation NuxeoColorUtils


+ (UIColor *) colorFromWebColor:(NSString *)color {
	NSUInteger red = 0;
	NSUInteger green = 0;
	NSUInteger blue = 0;
	UIColor *result = nil;
	
	if (sscanf([color UTF8String], "#%2x%2x%2x", &red, &green, &blue) == 3) {
		result = [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:1.0];
	}
	
	return result;
}

@end


@implementation NuxeoDriveUtils


+ (UIDocumentInteractionController *) setupControllerWithURL:(NSURL *)fileURL usingDelegate:(id<UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

@end
