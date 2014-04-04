//
//  NUXDocument+Utils.h
//  nuxeo-ios-app
//
//  Created by Matthias ROUBEROL on 25/03/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import "NUXDocument.h"

@interface NUXDocument (Utils)


- (BOOL) isFolder;
- (BOOL) isDriveSynchronizedFolder;

- (NSString *) pictoForDocument:(NSString *)context;

@end
