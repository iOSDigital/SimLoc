//
//  MenuController.h
//  SimLoc
//
//  Created by Paul Derbyshire on 30/11/2016.
//  Copyright © 2016 derbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface MenuController : NSObject <NSMenuDelegate>

-(BOOL)initialiseMenu;

@property (nonatomic,strong) NSMenu *mainMenu;

@end
