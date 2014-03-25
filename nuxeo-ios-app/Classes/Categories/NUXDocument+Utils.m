//
//  NUXDocument+Utils.m
//  nuxeo-ios-app
//
//  Created by Matthias ROUBEROL on 25/03/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import "NUXDocument+Utils.h"

#define kNuxeoDocumentTypeFile          @"File"

@implementation NUXDocument (Utils)


- (BOOL) isFolder
{
    if ([self.type isEqualToString:kNuxeoDocumentTypeFile])
    {
        return NO;
    }
    return YES;
}

@end
