//
//  AppDelegate.m
//  SimLoc
//
//  Created by Paul Derbyshire on 30/11/2016.
//  Copyright © 2016 derbs. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuController.h"


@interface AppDelegate ()
@property (nonatomic,strong) MenuController *menuController;
@property (nonatomic,strong) NSWindowController *preferencesController;
@end



@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.menuController = [MenuController new];
	self.menuController.delegate = self;
	[self.menuController initialiseMenu];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	
}


- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
	return self.menuController.mainMenu;
}


-(void)menuControllerDidSelectPreferences:(MenuController *)sender {
	self.preferencesController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"PreferencesWindowID"];
	[self.preferencesController showWindow:nil];
}

@end
