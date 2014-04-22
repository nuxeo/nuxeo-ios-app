//
//  NUXDocumentInfoForm.m
//  nuxeo-ios-app
//
//  Created by Julien Di Marco on 14/04/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import <NuxeoSDK/NUXDocument.h>
#import "NuxeoDriveUtils.h"

#import "NUXDocumentInfoForm.h"

@implementation NUXDocumentInfoForm

#pragma mark - initialziers -

- (id)init
{
    if ((self = [super init]))
    {
        self.date = nil;
        self.author = nil;
        self.desc = nil;
    }
    return self;
}

- (id)initWithNUXDocumment:(NUXDocument *)document
{
    if ((self = [self init]))
    {
        self.date = [NuxeoDriveUtils formatDate:document.lastModified withPattern:@"yyyy-MM-dd'T'HH:mm:ss" withLocale:[NSLocale currentLocale]];
        self.author = [document.properties objectForKey:@"dc:creator"];
        self.desc = [document.properties objectForKey:@"dc:description"];
    }
    return self;
}

#pragma mark - FXForm Protocol -

- (NSArray *)fields
{
    return  @[
              @{FXFormFieldKey : @"date", FXFormFieldTitle : @"Modified",  FXFormFieldType : FXFormFieldTypeLabel},
              @{FXFormFieldKey : @"author", FXFormFieldTitle : @"Author", FXFormFieldType : FXFormFieldTypeLabel, FXFormFieldFooter : @""},
              @{FXFormFieldKey : @"desc", FXFormFieldType : FXFormFieldTypeLongText, @"textView.editable": @(NO), @"textView.textAlignment" : @(NSTextAlignmentCenter)},
              ];
}

@end