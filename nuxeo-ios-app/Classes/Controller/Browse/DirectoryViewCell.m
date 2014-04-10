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
#import "NuxeoPopoverViewController.h"

@implementation DirectoryViewCell

#pragma mark - Initializers -

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
        [self setup];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
        [self setup];
    return self;
}

- (void)awakeFromNib
{
    _backgroundImage.image = [_backgroundImage.image resizableImageWithCapInsets:UIEdgeInsetsZero];
    _contentView.layer.cornerRadius = 2.5;
    _contentView.clipsToBounds = YES;
    _contentView.frame = (CGRect){1, 0.5, 178, 158};
}

- (void)setup
{
    self.enabled = NO;
    
    _infoPopoverController = [[UIPopoverController alloc] initWithContentViewController:[[NuxeoPopoverViewController alloc] init]];
    ((NuxeoPopoverViewController *)_infoPopoverController.contentViewController).parentPopover = _infoPopoverController;
}

#pragma mark - Setters

- (void)setPictoBackgroundColor:(UIColor *)iColor
{
    _topView.backgroundColor = iColor;
}

- (void)setTitleBackgroundColor:(UIColor *)iColor
{
    _bottomView.backgroundColor = iColor;
}

#pragma mark - Events -

- (IBAction)onTouchInfo:(UIButton *)sender
{
//    _infoPopoverController.popoverContentSize = _infoPopoverController.contentViewController.view.frame.size;
    [_infoPopoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - Memory Management -

- (void)dealloc
{
    NuxeoReleaseAndNil(_backgroundImage);
    NuxeoReleaseAndNil(_infoPopoverController);
    
    self.title = nil;
    self.picto = nil;
    
    [super dealloc];
}

@end
