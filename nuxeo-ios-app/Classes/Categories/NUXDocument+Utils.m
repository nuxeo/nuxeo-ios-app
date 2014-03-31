//
//  NUXDocument+Utils.m
//  nuxeo-ios-app
//
//  Created by Matthias ROUBEROL on 25/03/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import "NUXDocument+Utils.h"

#define kNuxeoDocumentTypeSections      @"Sections"
#define kNuxeoDocumentTypeSection       @"Section"
#define kNuxeoDocumentTypeTemplateRoot  @"TemplateRoot"
#define kNuxeoDocumentTypeWorkspaceRoot @"WorkspaceRoot"

#define kNuxeoDocumentTypeFile          @"File"
#define kNuxeoDocumentTypeNote          @"Note"

@implementation NUXDocument (Utils)


- (BOOL) isFolder
{
    if ([self.type isEqualToString:kNuxeoDocumentTypeSection] || [self.type isEqualToString:kNuxeoDocumentTypeTemplateRoot] || [self.type isEqualToString:kNuxeoDocumentTypeWorkspaceRoot])
    {
        return YES;
    }
    
    if ([self.type isEqualToString:kNuxeoDocumentTypeFile] || [self.type isEqualToString:kNuxeoDocumentTypeNote])
    {
        return NO;
    }
    return YES;
}

@end
