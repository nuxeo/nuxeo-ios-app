//
//  BreadCrumbsCellView.h
//  nuxeo-ios-app
//
//  Created by Julien Di Marco on 15/04/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BreadCrumbsCellView : UICollectionViewCell

#pragma mark - Properties
@property (nonatomic, retain) IBOutlet UILabel *crumbsIndicator;
@property (nonatomic, retain) IBOutlet UILabel *crumbsText;

#pragma mark - Class Method
+ (CGSize)contentSizeWithText:(NSString *)text;

@end
