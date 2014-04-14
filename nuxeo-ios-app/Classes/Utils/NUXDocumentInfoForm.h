//
//  NUXDocumentInfoForm.h
//  nuxeo-ios-app
//
//  Created by Julien Di Marco on 14/04/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>

@interface NUXDocumentInfoForm : NSObject <FXForm>

@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *desc;

#pragma mark - Initializers
- (id)init;
- (id)initWithNUXDocumment:(NUXDocument *)document;

@end