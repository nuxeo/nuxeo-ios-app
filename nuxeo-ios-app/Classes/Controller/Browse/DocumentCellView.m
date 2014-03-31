//
//  DocumentCellViewCell.m
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

#import "DocumentCellView.h"

@implementation DocumentCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) updateDisplayForFile
{
    
}

- (void) updateDisplayForFolder
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onTouchPreview:(id)sender
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onTouchPreview:)] == YES)
    {
        [self.delegate performSelector:@selector(onTouchPreview:) withObject:self.indexPath];
    }
}

- (IBAction)onTouchOpenWith:(id)sender
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onTouchOpenWith:)] == YES)
    {
        [self.delegate performSelector:@selector(onTouchOpenWith:) withObject:self.indexPath];
    }
}

- (IBAction)onTouchSync:(id)sender
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onTouchUpdate:)] == YES)
    {
        [self.delegate performSelector:@selector(onTouchUpdate:) withObject:self.indexPath];
    }
}

- (IBAction)onTouchInfo:(id)sender
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onTouchInfo:)] == YES)
    {
        [self.delegate performSelector:@selector(onTouchInfo:) withObject:self.indexPath];
    }
}

- (IBAction)onTouchPin:(id)sender
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onTouchPin:)] == YES)
    {
        [self.delegate performSelector:@selector(onTouchPin:) withObject:self.indexPath];
    }
}

- (IBAction)onTouchAddSynch:(id)sender
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onTouchAddSynch:)] == YES)
    {
        [self.delegate performSelector:@selector(onTouchAddSynch:) withObject:self.indexPath];
    }
}

- (void) setPictoBackgroundColor:(UIColor *)iColor
{
    if (self.picto != nil)
    {
        self.picto.backgroundColor = iColor;
    }
}

- (void) setTarget:(id)target forIndexPath:(NSIndexPath *)indexPath
{
    self.indexPath = [indexPath copy];
    self.delegate = target;
    
}

- (void) beginUpdate
{
    [self.update setEnabled:NO];
    self.updateActivity.center = self.update.center;
    [self.updateActivity startAnimating];
    self.updateActivity.hidden = NO;
}

- (void) finishUpdate
{
    [self.preview setEnabled:YES];
    [self.openWith setEnabled:YES];
    
    [self.updateActivity stopAnimating];
    self.updateActivity.hidden = YES;
    
    [self.update setEnabled:YES];
}

- (void)dealloc
{
    self.indexPath = nil;
    self.delegate = nil;
    [_picto release];
    [_title release];
    [_preview release];
    [_openWith release];
    [_update release];
    [_updateActivity release];
    [_addSynch release];
    [super dealloc];
}
@end
