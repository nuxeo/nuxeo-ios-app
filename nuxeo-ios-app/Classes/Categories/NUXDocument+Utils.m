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

#define kNuxeoDocumentFacetFolder       @"Folderish"
#define kNuxeoDocumentFacetSynchronized @"DriveSynchronized"


@implementation NUXDocument (Utils)


- (BOOL) isFolder
{
    if ([self.facets containsObject:kNuxeoDocumentFacetFolder])
    {
        return YES;
    }
    return NO;
}


- (BOOL) isDriveSynchronizedFolder
{
    if ([self.facets containsObject:kNuxeoDocumentFacetSynchronized])
    {
        return YES;
    }
    return NO;
}

- (NSString *) pictoForDocument
{
    if ([self isFolder] == YES)
    {
        return @"ic_type_folder";
    }
    return @"ic_type_file";
}

@end
