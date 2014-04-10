//
//  DirectoryViewCell.h
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

#import <UIKit/UIKit.h>

#import "NuxeoDrivePopupInfoViewDelegate.h"

#import "NuxeoLabel.h"

@interface DirectoryViewCell : UICollectionViewCell
{
    IBOutlet UIImageView *_backgroundImage;
    IBOutlet UIView *_contentView;
    
    IBOutlet UIView *_topView;
    IBOutlet UIView *_bottomView;
    
    IBOutlet UIImageView *_cloudImageView;
    IBOutlet UIButton *_infoButton;
    
    UIPopoverController *_infoPopoverController;
}

@property (nonatomic, assign) id<NuxeoDrivePopupActionViewDelegate> popupInfoDelegate;
@property (nonatomic, assign) NSIndexPath * indexPath;

@property (retain, nonatomic) IBOutlet UIImageView *picto;
@property (retain, nonatomic) IBOutlet UILabel *title;

@property (nonatomic, assign) BOOL loading; // Indicate if this folder is under synchronisation
@property (nonatomic, assign) BOOL enabled;

#pragma mark - Initializer

- (id)initWithCoder:(NSCoder *)aDecoder;
- (id)initWithFrame:(CGRect)frame;

#pragma mark - Custom Setters
- (void)setPictoBackgroundColor:(UIColor *)iColor;
- (void)setTitleBackgroundColor:(UIColor *)iColor;

#pragma mark - Events
- (IBAction)onTouchInfo:(UIButton *)sender;

@end
