//
//  DirectoryViewCell.m
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

#import "DirectoryViewCell.h"

@implementation DirectoryViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.enabled = NO;
    }
    return self;
}

- (void) setPictoBackgroundColor:(UIColor *)iColor
{
    if (self.picto != nil)
    {
        self.picto.backgroundColor = iColor;
    }
}

- (IBAction)onTouchInfo:(id)sender
{
    if (self.popupInfoDelegate != nil)
    {
        [self.popupInfoDelegate onTouchInfoAtIndexPath:self.indexPath];
    }
}



- (void)dealloc {
    [_title release];
    [_picto release];
    [super dealloc];
}
@end
