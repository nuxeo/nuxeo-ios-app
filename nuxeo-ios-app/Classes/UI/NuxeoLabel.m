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

#pragma mark - Initializers -

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        [self setup];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
		[self setup];
	return self;
}

- (void)setup
{
	BOOL isBold = [self.font.description rangeOfString:@"font-weight: bold"].location != NSNotFound;
	NSString* fontName = isBold ? @"UniversLT-Black" : @"UniversLT";
    UIFont *font_ = nil;
    
    if ((font_ = [UIFont fontWithName:fontName size:self.font.pointSize]))
        self.font = font_;
    self.leftMargin = 0;
}

#pragma mark - Drawings -

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {0, self.leftMargin, 0, 0};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
