//
//  Device.m
//  SimLoc
//
//  Created by Paul Derbyshire on 30/11/2016.
//  Copyright © 2016 derbs. All rights reserved.
//

#import "Device.h"

@implementation Device

@dynamic isBooted;


-(BOOL)isBooted {
	return [self.deviceState isEqualToString:@"Booted"];
}

-(NSString *)description {
	NSMutableString *string = [NSMutableString new];
	[string appendFormat:@"deviceName:             %@",self.deviceName];
	[string appendString:@"\n"];
	[string appendFormat:@"deviceVersion:          %@",self.deviceVersion];
	[string appendString:@"\n"];
	[string appendFormat:@"deviceState:            %@",self.deviceState];
	[string appendString:@"\n"];
	[string appendFormat:@"deviceAvailability:     %@",self.deviceAvailability];
	[string appendString:@"\n"];
	[string appendFormat:@"deviceUUID:             %@",self.deviceUUID];
	[string appendString:@"\n"];
	[string appendFormat:@"devicePath:             %@",self.devicePath];
	[string appendString:@"\n"];
	[string appendFormat:@"deviceApplicationsPath: %@",self.deviceApplicationsPath];
	
	return string;
}

@end
