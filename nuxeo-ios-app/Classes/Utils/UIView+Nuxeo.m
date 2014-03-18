//
//  UIView+Nuxeo.m
//  nuxeo-drive-ios
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

#import "UIView+Nuxeo.h"

@implementation UIView (Nuxeo)


/**
 * @abstract
 *  Goes through all the subviews and will automitcally call NSLocalizedString with the text set.
 * @discussion
 *  This is very useful when using XIB files because you only have to put the keys inside labels/buttons...
 *  and one call to this selector on the main will localize everything.
 */
- (void)localizeRecursively
{
	for (UIView* v in [self subviews])
	{
		if ([v isKindOfClass:[UILabel class]])
        {
			[(UILabel*)v setText:NSLocalizedString([(UILabel*)v text], nil)];
		}
		else if ([v isKindOfClass:[UITextView class]])
		{
			[(UITextView*)v setText:NSLocalizedString([(UITextView*)v text], nil)];
		}
		else if ([v isKindOfClass:[UIButton class]])
		{
			[(UIButton*)v setTitle:NSLocalizedString([(UIButton*)v titleForState:UIControlStateNormal], nil)
						  forState:UIControlStateNormal];
		}
		else if ([v isKindOfClass:[UITextField class]])
		{	
			UITextField* f = (UITextField*)v;
			f.text = NSLocalizedString(f.text, nil);
			f.placeholder = NSLocalizedString(f.placeholder, nil);
		}
		
		[v localizeRecursively];
	}
}

@end
