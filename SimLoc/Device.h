//
//  Device.h
//  SimLoc
//
//  Created by Paul Derbyshire on 30/11/2016.
//  Copyright © 2016 derbs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Device : NSObject

@property (nonatomic,strong) NSString *deviceName;
@property (nonatomic,strong) NSString *deviceApplicationsPath;
@property (nonatomic,strong) NSString *deviceVersion;
@property (nonatomic,strong) NSNumber *deviceVersionNumeric;
@property (nonatomic,strong) NSString *deviceState;
@property (nonatomic,strong) NSString *deviceAvailability;
@property (nonatomic,strong) NSString *deviceUUID;
@property (nonatomic,assign) BOOL isBooted;

@end
