//
//  BreadCrumbsCellView.m
//  nuxeo-ios-app
//
//  Created by Julien Di Marco on 15/04/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import "BreadCrumbsCellView.h"

@interface BreadCrumbsCellView ()

@end

@implementation BreadCrumbsCellView

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

- (void)setup
{
    self.crumbsIndicator = nil;
    self.crumbsText = nil;
}

//! View did load equivalent
- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    
//    self.layer.borderColor = [UIColor redColor].CGColor;
//    self.layer.borderWidth = 0.5;
//    
//    _crumbsIndicator.layer.borderWidth = 0.5;
//    _crumbsIndicator.layer.borderColor = [UIColor blueColor].CGColor;
//    
//    _crumbsText.layer.borderColor = [UIColor greenColor].CGColor;
//    _crumbsText.layer.borderWidth = 0.5;
}

#pragma mark - Cell Sizing -

+ (CGSize)contentSizeWithText:(NSString *)text
{
    CGSize contentSize_ = (CGSize){15, 42};
    CGRect contentRect_ = CGRectZero;
    UIFont *font_ = [UIFont fontWithName:@"Avenir-Book" size:22];
    
    
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        contentRect_ = [text boundingRectWithSize:(CGSize){914, 42} options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName : font_} context:nil];
        contentSize_ = contentRect_.size;
    }
    else
        contentSize_ = [text sizeWithFont:font_ constrainedToSize:(CGSize){914, 42} lineBreakMode:NSLineBreakByTruncatingTail];
    
    contentSize_.width += 20; // Indicator size
    contentSize_ = (CGSize){((contentSize_.width < 15) ? 15.f : contentSize_.width), contentSize_.height};
    return (CGSize){ceilf( contentSize_.width), ceilf(contentSize_.height)};
}

#pragma mark - Memory Management -

- (void)dealloc
{
    self.crumbsIndicator = nil;
    self.crumbsText = nil;
    
    [super dealloc];
}

@end
