//
//  Application.h
//  SimLoc
//
//  Created by Paul Derbyshire on 01/12/2016.
//  Copyright © 2016 derbs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Application : NSObject

@property (nonatomic,strong) NSString *applicationName;
@property (nonatomic,strong) NSString *applicationPath;
@property (nonatomic,strong) NSString *applicationVersion;
@property (nonatomic,strong) NSString *applicationFolderName;
@property (nonatomic,strong) NSString *applicationBundleID;
@property (nonatomic,strong) NSString *applicationIconPath;

@end
