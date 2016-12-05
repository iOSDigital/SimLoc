//
//  MenuController.h
//  SimLoc
//
//  Created by Paul Derbyshire on 30/11/2016.
//  Copyright © 2016 derbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

typedef void (^folderSizeBlock)(NSNumber *folderSize);


@protocol MenuControllerDelegate;


@interface MenuController : NSObject <NSMenuDelegate>

-(BOOL)initialiseMenu;

@property (nonatomic,strong) NSMenu *mainMenu;
@property (nonatomic,weak) id<MenuControllerDelegate> delegate;
@end



@protocol MenuControllerDelegate <NSObject>
@optional
-(void)menuControllerDidSelectPreferences:(MenuController *)sender;
@end
