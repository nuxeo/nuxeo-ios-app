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
    self.browsable = YES;
    self.nuxeoActionPopoverTitles = nil;
    
    NuxeoReleaseAndNil(_infoPopoverController);
    _infoPopoverController = [[UIPopoverController alloc] initWithContentViewController:[[NuxeoPopoverViewController alloc] init]];
    ((NuxeoPopoverViewController *)_infoPopoverController.contentViewController).parentPopover = _infoPopoverController;
    ((NuxeoPopoverViewController *)_infoPopoverController.contentViewController).caller = self;
}

#pragma mark - Setters -

- (void)setPictoBackgroundColor:(UIColor *)iColor
{
    _topView.backgroundColor = iColor;
}

- (void)setTitleBackgroundColor:(UIColor *)iColor
{
    _bottomView.backgroundColor = iColor;
}

- (void)setDelegate:(id<NuxeoActionPopoverDelegate>)delegate
{
    ((NuxeoPopoverViewController *)_infoPopoverController.contentViewController).delegate = delegate;
    _delegate = delegate;
}

#pragma mark - UICollectionView Loading -

- (void)loadWithActionPopoverTitles:(NSArray *)actionPopoverTitles
{
    ((NuxeoPopoverViewController *)_infoPopoverController.contentViewController).titles = actionPopoverTitles;
}

#pragma mark - Events -

- (IBAction)onTouchInfo:(UIButton *)sender
{
//    _infoPopoverController.popoverContentSize = _infoPopoverController.contentViewController.view.frame.size;
    [_infoPopoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - Specific rendering

- (void)repositoryRendering
{
    _infoButton.hidden = YES;
    _cloudImageView.hidden = YES;
}

- (void)folderRendering
{
    _pictoImageView.image = [UIImage imageNamed:@"ic_type_folder"];
    _infoButton.hidden = NO;
    _cloudImageView.hidden = NO;
}

-(void) renderWithStatus:(NuxeoHierarchieStatus)folderStatus
{
    switch (folderStatus)
    {
        case NuxeoHierarchieStatusNotLoaded:
        {
            self.browsable = NO;
        }
            break;
        case NuxeoHierarchieStatusIsLoadingHierarchy:
        {
            self.browsable = NO;
            CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = @0.0f;
            animation.toValue = @(2 * M_PI);
            animation.duration = 2.f;
            animation.repeatCount = HUGE_VALF;
            [_cloudImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        }
            break;
        case NuxeoHierarchieStatusTreeLoaded:
        {
            self.browsable = YES;
        }
            break;
        case NuxeoHierarchieStatusIsLoadingContent:
        {
            self.browsable = YES;
            CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = @0.0f;
            animation.toValue = @(2 * M_PI);
            animation.duration = 2.f;
            animation.repeatCount = HUGE_VALF;
            [_cloudImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        }
            break;
        case NuxeoHierarchieStatusContentLoaded:
        {
            self.browsable = YES;
            [_cloudImageView.layer removeAllAnimations];
            _cloudImageView.image = [UIImage imageNamed:@"ic_cloud"];
            [self folderRendering];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Memory Management -

- (void)dealloc
{
    NuxeoReleaseAndNil(_backgroundImage);
    NuxeoReleaseAndNil(_infoPopoverController);
    
    self.title = nil;
    
    [_pictoImageView release];
    [super dealloc];
}

@end
