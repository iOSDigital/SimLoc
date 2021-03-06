//
//  MenuController.m
//  SimLoc
//
//  Created by Paul Derbyshire on 30/11/2016.
//  Copyright © 2016 derbs. All rights reserved.
//
#import "MenuController.h"
#import "Application.h"
#import "Device.h"
#import <QuartzCore/QuartzCore.h>



@interface MenuController ()
@property (nonatomic,strong) NSStatusItem *statusItem;
@property (nonatomic,strong) NSFileManager *fileManager;
@end



@implementation MenuController


-(BOOL)initialiseMenu {
	self.fileManager = [NSFileManager defaultManager];
	
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	self.statusItem.title = @"";
	self.statusItem.image = [NSImage imageNamed:@"iPhone32"];
	[self.statusItem setTarget:self];

	[self setUpMenu];
	
	return YES;
}

-(void)setUpMenu {
	self.mainMenu = [NSMenu new];
	self.mainMenu.delegate = self;

	NSArray <NSDictionary *> *deviceArray = [self deviceArray];
	
	NSPredicate *bootedPredicate = [NSPredicate predicateWithFormat:@"isBooted == YES"];
	NSArray <Device *> *bootedDeviceArray = [[self rawDevicesArray] filteredArrayUsingPredicate:bootedPredicate];
	
	if (bootedDeviceArray.count > 0) {
		NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Booted Devices" action:nil keyEquivalent:@""];
		[self.mainMenu addItem:menuItem];

		[bootedDeviceArray enumerateObjectsUsingBlock:^(Device * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
			NSString *menuString = [NSString stringWithFormat:@"%@ %@",device.deviceName,device.deviceVersion];
			NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:menuString action:@selector(menuItemClicked:) keyEquivalent:@""];
			[menuItem setRepresentedObject:[NSDictionary dictionaryWithObject:device forKey:@"device"]];
			[menuItem setTarget:self];
			[menuItem setImage:[NSImage imageNamed:@"PowerIconGrey"]];
			if (device.isBooted) {
				[menuItem setImage:[NSImage imageNamed:@"PowerIconGreen"]];
			}
			NSMenu *applicationsSubMenu = [self applicationsMenuForDevice:device];
			menuItem.submenu = applicationsSubMenu;
			[self.mainMenu addItem:menuItem];
		}];
		
		[self.mainMenu addItem:[NSMenuItem separatorItem]];
	}
	
	
	[deviceArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull platformDictionary, NSUInteger idx, BOOL * _Nonnull stop) {
		
		NSString *platformKey = [[platformDictionary allKeys] firstObject];
		NSArray <NSDictionary *> *platformDevices = [platformDictionary objectForKey:platformKey];
		
		NSMenuItem *platformMenuItem = [[NSMenuItem alloc] initWithTitle:platformKey action:@selector(menuItemClicked:) keyEquivalent:@""];
		platformMenuItem.target = self;
		NSMenu *subMenu = [[NSMenu alloc] init];
		
		[platformDevices enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dictionary, NSUInteger idx, BOOL * _Nonnull stop) {
			
			NSSortDescriptor *bootedSorter = [NSSortDescriptor sortDescriptorWithKey:@"isBooted" ascending:NO];
			NSSortDescriptor *nameSorter = [NSSortDescriptor sortDescriptorWithKey:@"deviceVersionNumeric" ascending:YES];
			
			NSString *deviceKey = [[dictionary allKeys] firstObject];
			NSArray <Device *> *deviceArray = [dictionary[deviceKey] sortedArrayUsingDescriptors:@[bootedSorter,nameSorter]];
			
			[subMenu addItem:[NSMenuItem separatorItem]];
			
			[deviceArray enumerateObjectsUsingBlock:^(Device * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
				
				BOOL hideEmptySimulators = [[NSUserDefaults standardUserDefaults] boolForKey:@"HideEmptySimulators"];
				NSInteger appCount = [self countApplicationsForDevice:device];

				if (hideEmptySimulators && appCount == 0) {
					// - Do nothing
				}else{
					
					NSString *menuString = [NSString stringWithFormat:@"%@ %@",device.deviceName,device.deviceVersion];
					__block NSMutableAttributedString *menuStringAttr = [self deviceMenuTitleString:device];
					
					NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:menuString action:@selector(menuItemClicked:) keyEquivalent:@""];
					menuItem.attributedTitle = menuStringAttr;
					
					[self folderSizeWithMenuItem:menuItem completion:^(NSNumber *folderSize) {
						NSString *folderSizeString = [NSString stringWithFormat:@"%@MB",folderSize];
						NSAttributedString *folderSizeStringAttr = [[NSAttributedString alloc] initWithString:folderSizeString attributes:[self deviceMenuAttributesDictionary]];
						[menuStringAttr appendAttributedString:folderSizeStringAttr];
						menuItem.attributedTitle = menuStringAttr;
					}];

					[menuItem setRepresentedObject:[NSDictionary dictionaryWithObject:device forKey:@"device"]];
					[menuItem setTarget:self];
					
					[menuItem setImage:[NSImage imageNamed:@"PowerIconGrey"]];
					if (device.isBooted) {
						[menuItem setImage:[NSImage imageNamed:@"PowerIconGreen"]];
					}
					
					// - Get the applications for this device in a submenu
					NSMenu *applicationsSubMenu = [self applicationsMenuForDevice:device];
					menuItem.submenu = applicationsSubMenu;
					[subMenu addItem:menuItem];
				}
				
				
			}];
			
			[platformMenuItem setSubmenu:subMenu];
		}];
		
		[self.mainMenu addItem:platformMenuItem];
		
	}];
	
	
	[self.mainMenu addItem:[NSMenuItem separatorItem]];
	[[self.mainMenu addItemWithTitle:@"Preferences..." action:@selector(showPreferences:) keyEquivalent:@""] setTarget:self];
	[self.mainMenu addItem:[NSMenuItem separatorItem]];
	[[self.mainMenu addItemWithTitle:@"Quit" action:@selector(quitApp:) keyEquivalent:@""] setTarget:self];
	
	self.statusItem.menu = self.mainMenu;
}

-(NSMutableAttributedString *)deviceMenuTitleString:(Device *)device {
	NSString *menuString = [NSString stringWithFormat:@"%@ %@",device.deviceName,device.deviceVersion];
	NSMutableAttributedString *menuStringAttr = [[NSMutableAttributedString alloc] initWithString:menuString attributes:nil];
	
	NSInteger appCount = [self countApplicationsForDevice:device];
	NSString *detailsString = [NSString stringWithFormat:@"\n%lu app%@. ",appCount,(appCount == 1 ? @"" : @"s")];
	NSAttributedString *detailStringAttr = [[NSAttributedString alloc] initWithString:detailsString attributes:[self deviceMenuAttributesDictionary]];
	[menuStringAttr appendAttributedString:detailStringAttr];
	
	return menuStringAttr;
}

-(NSDictionary *)deviceMenuAttributesDictionary {
	NSMutableDictionary *attributesDictionary = [NSMutableDictionary dictionary];
	[attributesDictionary setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	[attributesDictionary setObject:[NSColor lightGrayColor] forKey:NSForegroundColorAttributeName];
	return [attributesDictionary copy];
}


-(NSInteger)countApplicationsForDevice:(Device *)device {
	__block NSString *applicationsPath = [[self containersPathForDevice:device] stringByAppendingPathComponent:@"Bundle/Application"];
	__block NSError *fileError;
	
	NSPredicate *dotPredicate = [NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH %@",@"."];
	NSArray <NSString *> *appsArray = [[self.fileManager contentsOfDirectoryAtPath:applicationsPath error:&fileError] filteredArrayUsingPredicate:dotPredicate];
	if (!appsArray) {
		return 0;
	}
	return appsArray.count;
}

-(NSMenu *)applicationsMenuForDevice:(Device *)device {
	
	NSMenu *applicationsMenu = [[NSMenu alloc] init];

	NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Applications" action:@selector(menuItemClicked:) keyEquivalent:@""];
	[menuItem setRepresentedObject:device];
	[menuItem setTarget:self];
	
	__block NSString *applicationsPath = [[self containersPathForDevice:device] stringByAppendingPathComponent:@"Bundle/Application"];
	__block NSError *fileError;
	
	NSPredicate *dotPredicate = [NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH %@",@"."];
	NSArray <NSString *> *appsArray = [[self.fileManager contentsOfDirectoryAtPath:applicationsPath error:&fileError] filteredArrayUsingPredicate:dotPredicate];
	__block NSMutableArray *applicationsArray = [NSMutableArray new];
	
	[appsArray enumerateObjectsUsingBlock:^(NSString * _Nonnull folderName, NSUInteger idx, BOOL * _Nonnull stop) {
		
		NSString *appPath = [applicationsPath stringByAppendingPathComponent:folderName];
		NSArray <NSString *> *filesArray = [[self.fileManager contentsOfDirectoryAtPath:appPath error:&fileError] filteredArrayUsingPredicate:dotPredicate];
		Application *application = [Application new];
		application.applicationFolderName = folderName;
		application.applicationPath = [[[self containersPathForDevice:device] stringByAppendingPathComponent:@"Data/Application"] stringByAppendingPathComponent:folderName];

		[filesArray enumerateObjectsUsingBlock:^(NSString * _Nonnull fileName, NSUInteger idx, BOOL * _Nonnull stop) {
			if ([fileName containsString:@".app"]) {
				application.applicationName = fileName;
				
				NSString *infoPlistPath = [[[applicationsPath stringByAppendingPathComponent:application.applicationFolderName] stringByAppendingPathComponent:application.applicationName] stringByAppendingPathComponent:@"Info.plist"];
				NSDictionary *infoDictionary = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
				application.applicationBundleID = infoDictionary[@"CFBundleIdentifier"];
				application.applicationVersion = infoDictionary[@"CFBundleShortVersionString"];
				
			}
			// TODO : Get more info from the app bundle's info.plist - icon!
		}];
		[applicationsArray addObject:application];
	}];
	
	NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"applicationName" ascending:YES];
	[applicationsArray sortUsingDescriptors:@[nameSort]];
	
	[applicationsArray enumerateObjectsUsingBlock:^(Application *application, NSUInteger idx, BOOL * stop) {
		
		NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:application.applicationName action:@selector(menuItemClicked:) keyEquivalent:@""];
		
		NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:application,@"application",device,@"device", nil];
		[menuItem setRepresentedObject:dictionary];
		[menuItem setTarget:self];
		[applicationsMenu addItem:menuItem];

	}];
	
	
	return applicationsMenu;
}





-(void)menuWillOpen:(NSMenu *)menu {
	[self setUpMenu];
}



-(IBAction)menuItemClicked:(NSMenuItem *)sender {
	NSDictionary *repDictionary = sender.representedObject;
	__block NSString *fullPath;
	
	Application *application = repDictionary[@"application"];
	Device *device = repDictionary[@"device"];
	
	if (application) {
		// - User chose a specific app
		//fullPath = application.applicationPath;
		NSArray <NSURL *> *applications = [self.fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:device.deviceApplicationsPath] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
		[applications enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			NSURL *infoPlistURL = [obj URLByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
			NSDictionary *infoPlistDictionary = [NSDictionary dictionaryWithContentsOfURL:infoPlistURL];
			NSString *bundleID = infoPlistDictionary[@"MCMMetadataIdentifier"];
			if ([bundleID isEqualToString:application.applicationBundleID]) {
				fullPath = obj.absoluteString;
				if ([self.fileManager fileExistsAtPath:[[fullPath stringByReplacingOccurrencesOfString:@"file:" withString:@""] stringByAppendingPathComponent:@"Documents"]]) {
					fullPath = [fullPath stringByAppendingPathComponent:@"Documents"];
				}else{
					if ([self.fileManager fileExistsAtPath:[[fullPath stringByReplacingOccurrencesOfString:@"file:" withString:@""] stringByAppendingPathComponent:@"Library"]]) {
						fullPath = [fullPath stringByAppendingPathComponent:@"Library"];
					}
				}
				*stop = YES;
			}
		}];
		
	}else{
		// - User chose a specific simulator
		fullPath = device.deviceApplicationsPath;
	}
	
	
	NSURL *fullURL = [NSURL fileURLWithPath:fullPath];
	[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fullURL]];
}

-(NSString *)pathForDevice:(Device *)device {
	NSString *userLibraryPath = [[[self.fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] absoluteString];
	NSString *devicePath = [@"Developer/CoreSimulator/Devices" stringByAppendingPathComponent:device.deviceUUID];
	NSString *fullPath = [userLibraryPath stringByAppendingPathComponent:devicePath];
	
	return [fullPath stringByReplacingOccurrencesOfString:@"file:" withString:@""];
}
-(NSString *)containersPathForDevice:(Device *)device {
	NSString *devicePath = [self pathForDevice:device];
	NSString *containersPath = [devicePath stringByAppendingPathComponent:@"data/Containers"];
	
	return [containersPath stringByReplacingOccurrencesOfString:@"file:" withString:@""];
}


-(NSArray *)rawDevicesArray {
	// - Get the raw list of devices in JSON format
	NSError *parseError;
	NSDictionary *rawDictionary = [NSJSONSerialization JSONObjectWithData:[self runCommand] options:0 error:&parseError];
	NSDictionary *devicesDictionary = [rawDictionary objectForKey:@"devices"];
	NSMutableArray *devicesArray = [NSMutableArray new];
	
	// - Enumerate the dictionary, get all those that start with 'iOS', create a Device object and put into an array
	[devicesDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL * stop) {
		
//		NSRange range = NSMakeRange(0, 3);
//		NSString *keyVersion = [key substringWithRange:range];

//		if ([keyVersion isEqualToString:@"iOS"]) {
		
		NSMutableString *keyVersion = [key componentsSeparatedByString:@"."].lastObject.mutableCopy;
		[keyVersion replaceOccurrencesOfString:@"-" withString:@"." options:0 range:NSMakeRange(0, keyVersion.length)];
		[keyVersion replaceOccurrencesOfString:@"iOS." withString:@"" options:0 range:NSMakeRange(0, keyVersion.length)];

		if ([key containsString:@"iOS"]) {

			[obj enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * stop) {
				Device *device = [Device new];
				device.deviceName = obj[@"name"];
				device.deviceUUID = obj[@"udid"];
				device.deviceState = obj[@"state"];
				device.deviceAvailability = obj[@"availability"];
				device.deviceVersion = keyVersion;
				device.devicePath = [self pathForDevice:device];
				device.deviceApplicationsPath = [[self containersPathForDevice:device] stringByAppendingPathComponent:@"Data/Application"];
				
				NSString *versionNumericString = keyVersion;
				NSNumber *versionNumber = [NSNumber numberWithDouble:versionNumericString.doubleValue];
				device.deviceVersionNumeric = versionNumber;
				
				[devicesArray addObject:device];
			}];
			
		}
		
	}];
	
	return devicesArray;
}

-(void)folderSizeWithMenuItem:(NSMenuItem *)menuItem completion:(folderSizeBlock)completion {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		Device *device = menuItem.representedObject[@"device"];
		
		NSArray *filesArray = [self.fileManager subpathsOfDirectoryAtPath:device.devicePath error:nil];
		NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
		NSString *fileName;
		__block unsigned long long int fileSize = 0;
		
		while (fileName = [filesEnumerator nextObject]) {
			NSDictionary *fileDictionary = [self.fileManager attributesOfItemAtPath:[device.devicePath stringByAppendingPathComponent:fileName] error:nil];
			fileSize += [fileDictionary fileSize];
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			completion(@(fileSize / 1000 / 1000));
		});
	});

}


-(NSArray *)deviceArray {
	
	NSArray *devicesArray = [self rawDevicesArray];
	
	// - Get a set of unique device names
	NSSet *deviceNameSet = [NSSet setWithArray:[devicesArray valueForKey:@"deviceName"]];
	NSArray <NSString *> *deviceNameArray = [[deviceNameSet allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedCompare:)]]];
	
	// - Enumerate, pulling out all those matching each device name into an array of dictionaries
	NSMutableArray *sortedDeviceArray = [NSMutableArray new];
	NSMutableArray *iPhoneArray = [NSMutableArray new];
	NSMutableArray *iPadArray = [NSMutableArray new];
	
	
	[deviceNameArray enumerateObjectsUsingBlock:^(NSString * _Nonnull deviceString, NSUInteger idx, BOOL * _Nonnull stop) {
		NSMutableDictionary *dictionary = [NSMutableDictionary new];
		
		NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"deviceName == %@",deviceString];
		NSArray *filterArray = [devicesArray filteredArrayUsingPredicate:filterPredicate];
		[dictionary setObject:filterArray forKey:deviceString];
		//[sortedDeviceArray addObject:dictionary];
		
		if ([deviceString containsString:@"iPhone"]) {
			[iPhoneArray addObject:dictionary];
		}else{
			[iPadArray addObject:dictionary];
		}
		
	}];
	
	NSDictionary *iphoneDictionary = [NSDictionary dictionaryWithObject:iPhoneArray forKey:@"iPhone"];
	NSDictionary *ipadDictionary = [NSDictionary dictionaryWithObject:iPadArray forKey:@"iPad"];
	[sortedDeviceArray addObject:iphoneDictionary];
	[sortedDeviceArray addObject:ipadDictionary];
	
	return [sortedDeviceArray copy];
}






-(NSData *)runCommand {
	NSPipe* pipe = [NSPipe pipe];
	
	NSTask* task = [[NSTask alloc] init];
	[task setLaunchPath: @"/usr/bin/xcrun"];
	[task setArguments:@[@"simctl",@"list",@"-j",@"devices"]];
	[task setStandardOutput:pipe];
	
	NSFileHandle* file = [pipe fileHandleForReading];
	[task launch];
	
	return [file readDataToEndOfFile];
}



-(IBAction)quitApp:(id)sender {
	[[NSApplication sharedApplication] terminate:self];
}

-(IBAction)showPreferences:(id)sender {
	if ([self.delegate respondsToSelector:@selector(menuControllerDidSelectPreferences:)]) {
		[self.delegate menuControllerDidSelectPreferences:self];
	}
}

@end
