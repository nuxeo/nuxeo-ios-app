//
//  NUXDocument+Utils.m
//  nuxeo-ios-app
//
//  Created by Matthias ROUBEROL on 25/03/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import "NUXDocument+Utils.h"

#import "NUXBlobStore.h"

#define kNuxeoDocumentTypeSections      @"Sections"
#define kNuxeoDocumentTypeSection       @"Section"
#define kNuxeoDocumentTypeTemplateRoot  @"TemplateRoot"
#define kNuxeoDocumentTypeWorkspaceRoot @"WorkspaceRoot"

#define kNuxeoDocumentTypeFile          @"File"
#define kNuxeoDocumentTypeNote          @"Note"
#define kNuxeoDocumentTypeVideo         @"Video"
#define kNuxeoDocumentTypePicture       @"Picture"
#define kNuxeoDocumentTypeAudio         @"Audio"

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

- (NSString *) pictoForDocument:(NSString *)context
{
    if ([self isFolder] == YES)
    {
        return [NSString stringWithFormat:@"ic%@type_folder",context];
    }
    if ([self.type isEqualToString:kNuxeoDocumentTypeFile])
    {
        return [NSString stringWithFormat:@"ic%@type_file",context];
    }
    else if ([self.type isEqualToString:kNuxeoDocumentTypeNote])
    {
        return [NSString stringWithFormat:@"ic%@type_note",context];
    }
    else if ([self.type isEqualToString:kNuxeoDocumentTypeVideo])
    {
        return [NSString stringWithFormat:@"ic%@type_video",context];
    }
    else if ([self.type isEqualToString:kNuxeoDocumentTypePicture])
    {
        return [NSString stringWithFormat:@"ic%@type_image",context];
    }
    else if ([self.type isEqualToString:kNuxeoDocumentTypeAudio])
    {
        return [NSString stringWithFormat:@"ic%@type_sound",context];
    }
    return [NSString stringWithFormat:@"ic%@type_file",context];
    
}

- (BOOL) hasBinaryFile
{
    if ([self.properties objectForKey:kXPathFileContent] == nil)
    {
        return NO;
    }
    if ([[self.properties objectForKey:kXPathFileContent] isKindOfClass:[NSNull class]] == YES)
    {
        return NO;
    }
    return YES;
}

- (BOOL) hasBinaryFileOnDevice
{
    return [[NUXBlobStore instance] hasBlobFromDocument:self metadataXPath:kXPathFileContent];
}

@end
