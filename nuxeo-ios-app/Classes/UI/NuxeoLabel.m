//
//  NuxeoLabel.m
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

#import "NuxeoLabel.h"

@interface NuxeoLabel (Private)

- (void)setup;

@end

@implementation NuxeoLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (self)
		[self setup];
	
	return self;
}

- (void)setup
{
	BOOL isBold = [self.font.fontName rangeOfString:@"Bold"].location != NSNotFound;
	NSString* fontName = isBold ? @"UniversLT-Black" : @"UniversLT";
	UIFont * customFont = [UIFont fontWithName:fontName size:self.font.pointSize];
    self.font = customFont;
}

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {0, self.leftMarge, 0, 0};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
