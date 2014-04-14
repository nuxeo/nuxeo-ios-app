//
//  NuxeoDriveUtils.h
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

#import <Foundation/Foundation.h>

// for cocoapods, we only know if the DEBUG macro is defined
#ifdef DEBUG
    #define NUXEO_LOG_LEVEL_DEBUG 1
#endif

#if NUXEO_LOG_LEVEL_DEBUG != 0
    #define NUXEO_LOG_LEVEL 5
#endif

#if NUXEO_LOG_LEVEL_INFO != 0
    #define NUXEO_LOG_LEVEL 4
#endif

#if NUXEO_LOG_LEVEL_WARN != 0
    #define NUXEO_LOG_LEVEL 3
#endif

#if NUXEO_LOG_LEVEL_ERROR != 0
    #define NUXEO_LOG_LEVEL 2
#endif

#if NUXEO_LOG_LEVEL_FATAL != 0
    #define NUXEO_LOG_LEVEL 1
#endif

// Nuxeo starting logo

#define NuxeoLogLogo()	[NuxeoLog logLogo]

// Clear log file

#if NUXEO_LOG_FILE != 0
    #define NuxeoLogClear()		\
[NuxeoLog clearLogFile]
#else
    #define NuxeoLogClear()
#endif


// No log level has been specified: in that case, we discard all logs

#if NUXEO_LOG_LEVEL != 0
    #define NuxeoLog(theLogLevel, theFormat, ...)						\
            [NuxeoLog log:__FILE__										\
                lineNumber:__LINE__										\
                logLevel:(theLogLevel)									\
                    format:(theFormat), ##__VA_ARGS__]
#else
    #define NuxeoLog(theLogLevel, theFormat, ...)
#endif

#if NUXEO_LOG_LEVEL >= 5
    #define NuxeoLogD(theFormat, ...)									\
            [NuxeoLog log:__FILE__										\
                lineNumber:__LINE__										\
                    method:__FUNCTION__									\
                logLevel:NuxeoLogLevelDebug								\
            format:(theFormat), ##__VA_ARGS__]
#else
    #define NuxeoLogD(theFormat, ...)
#endif

#if NUXEO_LOG_LEVEL >= 4
    #define NuxeoLogI(theFormat, ...)									\
            [NuxeoLog log:__FILE__										\
                lineNumber:__LINE__										\
                    method:__FUNCTION__									\
            logLevel:NuxeoLogLevelInfo									\
            format:(theFormat), ##__VA_ARGS__]
#else
    #define NuxeoLogI(theFormat, ...)
#endif

#if NUXEO_LOG_LEVEL >= 3
    #define NuxeoLogW(theFormat, ...)									\
            [NuxeoLog log:__FILE__										\
                lineNumber:__LINE__										\
                    method:__FUNCTION__									\
            logLevel:NuxeoLogLevelWarning								\
                    format:(theFormat), ##__VA_ARGS__]

#define NuxeoLogEW(theException, theFormat, ...)					\
    [NuxeoLog logWithStringLevel:__FILE__							\
                        lineNumber:__LINE__							\
                        logLevel:NuxeoLogLevelWarning				\
                    logLevelString:@"WARN"							\
exception:(theException)					\
format:(theFormat), ##__VA_ARGS__]
#else
    #define NuxeoLogW(theFormat, ...)
    #define NuxeoLogEW(theException, theFormat, ...)
#endif

#if NUXEO_LOG_LEVEL >= 2
    #define NuxeoLogE(theFormat, ...)									\
            [NuxeoLog log:__FILE__										\
                lineNumber:__LINE__										\
                    method:__FUNCTION__									\
                logLevel:NuxeoLogLevelError								\
                    format:(theFormat), ##__VA_ARGS__]

    #define NuxeoLogEE(theException, theFormat, ...)					\
        [NuxeoLog logWithStringLevel:__FILE__							\
                            lineNumber:__LINE__							\
                            logLevel:NuxeoLogLevelError					\
                        logLevelString:@"ERROR"							\
                            exception:(theException)					\
                                format:(theFormat), ##__VA_ARGS__]
#else
    #define NuxeoLogE(theFormat, ...)
    #define NuxeoLogEE(theException, theFormat, ...)
#endif

#if NUXEO_LOG_LEVEL >= 1
    #define NuxeoLogF(theFormat, ...)									\
            [NuxeoLog log:__FILE__										\
                lineNumber:__LINE__										\
                    method:__FUNCTION__									\
                logLevel:NuxeoLogLevelFatal								\
                    format:(theFormat), ##__VA_ARGS__]

    #define NuxeoLogEF(theException, theFormat, ...)					\
        [NuxeoLog logWithStringLevel:__FILE__							\
                            lineNumber:__LINE__							\
                            logLevel:NuxeoLogLevelFatal					\
                        logLevelString:@"FATAL"							\
                            exception:(theException)					\
                        format:(theFormat), ##__VA_ARGS__]
#else
    #define NuxeoLogF(theFormat, ...)
    #define NuxeoLogFF(theException, theFormat, ...)
#endif

/**
 * Indicates the log level.
 */
typedef enum
{
    NuxeoLogLevelDebug		= 5,
    NuxeoLogLevelInfo		= 4,
    NuxeoLogLevelWarning	= 3,
    NuxeoLogLevelError		= 2,
    NuxeoLogLevelFatal		= 1,
}
NuxeoLogLevel;

/**
 * Defines some helper functions and macros for logging.
 *
 * The log helpers should be exclusively used from macros, so that some logs can be removed from the compilation process
 * for a production environment purpose. The <code>NuxeoLogD</code>, <code>NuxeoLogI</code>, <code>NuxeoLogW</code>,
 * <code>NuxeoLogE</code> and <code>NuxeoLogF</code> macros should be used, and not directly the static methods!
 */
@interface NuxeoLog : NSObject
{
}

/**
 * Log the Nuxeo logo in a nice Ascii Art
 * (http://goo.gl/Rcd42)
 */
+ (void)logLogo;

/**
 * This is the main method to log anything with the Nuxeo Framework.
 * If logging on file is activated than it also handled here.
 * @param iStr	The NSString to log
 */
+ (void)logString:(NSString*)iStr;

+ (NSString*)logFilePath;

+ (void)clearLogFile;

/**
 * Logs a specified string into the application specified log file
 * @param iStr	The NSString to log
 * @param logFilePath The path for the file to log the string in
 */
+ (void)logString:(NSString*)iStr toFile:(NSString*)logFilePath;

/**
 * Do not use, use the macros instead!
 */
+ (void) log:(char *)sourceFile
  lineNumber:(int)lineNumber
	  method:(const char*)method
	logLevel:(NuxeoLogLevel)logLevel
	  format:(NSString *)format, ...;

///**
// * Do not use, use the macros instead!
// */
//+ (void) logWithStringLevel:(char *)sourceFile
//				 lineNumber:(int)lineNumber
//				   logLevel:(NuxeoLogLevel)logLevel
//			 logLevelString:(NSString *)logLevelString
//					 format:(NSString *)format, ...;

/**
 * Do not use, use the macros instead!
 */
+ (void) logWithStringLevel:(char *)sourceFile
				 lineNumber:(int)lineNumber
				   logLevel:(NuxeoLogLevel)logLevel
			 logLevelString:(NSString *)logLevelString
				  exception:(NSException *)exception
					 format:(NSString *)format, ...;

@end

@interface NuxeoColorUtils : NSObject
{
    
}

+ (UIColor *) colorFromWebColor:(NSString *)color;

@end

@interface NuxeoDriveUtils : NSObject {

}

+ (UIDocumentInteractionController *) setupControllerWithURL:(NSURL *)fileURL usingDelegate:(id<UIDocumentInteractionControllerDelegate>) interactionDelegate;
+ (NSString*) applicationDocumentsPath;

+ (NSString *) formatDate:(NSDate *)date withPattern:(NSString *)pattern withLocale:(NSLocale *)locale;

@end
