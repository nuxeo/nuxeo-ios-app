//
//  BrowseAllOffLineDocumentListViewController.m
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

#import "BrowseAllOffLineDocumentListViewController.h"

#import "NuxeoDriveRemoteServices.h"

#import <NuxeoSDK/NUXJSONSerializer.h>

@implementation BrowseAllOffLineDocumentListViewController
    
#pragma mark - Business Object Loading -
    
- (void)viewDidLoad
    {
        [super viewDidLoad];
        self.pinButton.hidden = YES;
        self.searchButton.hidden = YES;
    }
    
- (void) loadBusinessObjects
{
    _documents = [[NSMutableArray array] retain];
    
    [[NuxeoDriveRemoteServices instance] retrieveAllSynchronizePointsNames:^(id listOfHierarchyNames)
     {
         for (NSString * hierarchyName in listOfHierarchyNames)
         {
             NSArray * listOfDocOfHierarchy = [[NuxeoDriveRemoteServices instance] retrieveAllDocumentsOfHierarchy:hierarchyName];
             [listOfDocOfHierarchy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 NUXDocument * currentDocument = (NUXDocument *)obj;
                 [currentDocument.properties setObject:hierarchyName forKey:@"local:hierarchyName"];
             }];
             [_documents addObjectsFromArray:listOfDocOfHierarchy];
         }
     }];
    
    
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    NUXDocument * selectedDocument = [self documentByIndexPath:indexPath];
    if (![selectedDocument hasBinaryFile] && ![selectedDocument isFolder])
        return ;
    
    if ([selectedDocument isFolder])
    {
        NUXHierarchy * hierarchy = [[NuxeoDriveRemoteServices instance] getHierarchyWithName:[selectedDocument.properties objectForKey:@"local:hierarchyName"]];
        [CONTROLLER_HANDLER pushDocumentsControllerFrom:self options:@{kParamKeyDocument: selectedDocument , kParamKeyHierarchy :  hierarchy ? : [NSNull null]}];
    }
    else
    {
        [CONTROLLER_HANDLER pushPreviewControllerFrom:self options:@{kParamKeyDocument: selectedDocument}];
    }
    
}

@end
