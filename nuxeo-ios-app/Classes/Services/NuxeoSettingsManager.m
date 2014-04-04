//
//  SettingsManager.m
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

#import "NuxeoSettingsManager.h"

@implementation NuxeoSettingsManager

+ (NuxeoSettingsManager *) instance
{
    static dispatch_once_t pred = 0;
    __strong static NuxeoSettingsManager * _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        // or some other init method
    });
    return _sharedObject;
}

#pragma mark -
#pragma mark Public API

- (void) saveSetting:(id)value forKey:(NSString*)key
{
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (id) readSetting:(NSString*)key defaultValue:(id)defaultValue
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil)
    {
        [self saveSetting:defaultValue forKey:key];
    }
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void) deleteSetting:(NSString*)key
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) saveIntSetting:(int)value forKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:value] forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (int) readIntSetting:(NSString*)key defaulValue:(int)defaultValue
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil)
    {
        [self saveIntSetting:defaultValue forKey:key];
    }
	return [[[NSUserDefaults standardUserDefaults] objectForKey:key] intValue];
}

- (void) saveBoolSetting:(BOOL)value forKey:(NSString*)key
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:value] forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
        
}

- (BOOL) readBoolSetting:(NSString*)key defaulValue:(BOOL)defaultValue
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil)
    {
        [self saveBoolSetting:defaultValue forKey:key];
    }
	return [[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue];
}


@end
