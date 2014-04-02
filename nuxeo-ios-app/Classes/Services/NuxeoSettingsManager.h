//
//  NuxeoSettingsManager.h
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


@interface NuxeoSettingsManager : NSObject
{
    
}

+ (NuxeoSettingsManager *) instance;

- (void) saveSetting:(id)value forKey:(NSString*)key;
- (id) readSetting:(NSString*)key;
- (void) deleteSetting:(NSString*)key;

- (void) saveIntSetting:(int)value forKey:(NSString*)key;
- (int) readIntSetting:(NSString*)key defaulValue:(int)defaultValue;

- (void) saveBoolSetting:(BOOL)value forKey:(NSString*)key;
- (BOOL) readBoolSetting:(NSString*)key defaulValue:(BOOL)defaultValue;


@end
