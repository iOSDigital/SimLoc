//
//  Application.m
//  SimLoc
//
//  Created by Paul Derbyshire on 01/12/2016.
//  Copyright © 2016 derbs. All rights reserved.
//

#import "Application.h"

@implementation Application

-(NSString *)description {
	NSMutableString *string = [NSMutableString new];
	[string appendFormat:@"applicationName:         %@",self.applicationName];
	[string appendString:@"\n"];
	[string appendFormat:@"applicationVersion:      %@",self.applicationVersion];
	[string appendString:@"\n"];
	[string appendFormat:@"applicationPath:         %@",self.applicationPath];
	[string appendString:@"\n"];
	[string appendFormat:@"applicationFolderName:   %@",self.applicationFolderName];
	[string appendString:@"\n"];
	[string appendFormat:@"applicationBundleID:     %@",self.applicationBundleID];
	[string appendString:@"\n"];
	[string appendFormat:@"applicationIconPath:     %@",self.applicationIconPath];
	
	return string;
}

@end
