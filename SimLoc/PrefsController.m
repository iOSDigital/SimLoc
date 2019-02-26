//
//  PrefsController.m
//  SimLoc
//
//  Created by Paul Derbyshire on 06/12/2016.
//  Copyright © 2016 derbs. All rights reserved.
//

#import "PrefsController.h"

@interface PrefsController ()

@end

@implementation PrefsController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(IBAction)savePrefs:(NSButton *)sender {
	[[NSUserDefaults standardUserDefaults] synchronize];
	[sender.window close];
}


@end
