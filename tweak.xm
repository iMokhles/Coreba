
@interface CorebaHelper : NSObject
+ (void)addMapsShortCuts;
+ (void)addPhotosShortCuts;
@end

@implementation CorebaHelper
+ (void)addMapsShortCuts {

	UIApplicationShortcutIcon *directionsIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"action-home-OrbHW"];
	UIApplicationShortcutIcon *markIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"action-drop-pin-OrbHW"];

	UIMutableApplicationShortcutItem *directionHome = [[UIMutableApplicationShortcutItem alloc] initWithType:@"com.apple.Maps.directions" localizedTitle:[[NSBundle mainBundle] localizedStringForKey:@"QUICK_ACTION_DIRECTIONS_HOME" value:@"" table:@"InfoPlist-OrbHW"] localizedSubtitle:nil icon:directionsIcon userInfo:nil];
	UIMutableApplicationShortcutItem *markLocation = [[UIMutableApplicationShortcutItem alloc] initWithType:@"com.apple.Maps.mark-my-location" localizedTitle:[[NSBundle mainBundle] localizedStringForKey:@"QUICK_ACTION_MARK_MY_LOCATION" value:@"" table:@"InfoPlist-OrbHW"] localizedSubtitle:nil icon:markIcon userInfo:nil];
    UIMutableApplicationShortcutItem *shareLocation = [[UIMutableApplicationShortcutItem alloc] initWithType:@"com.apple.Maps.share-location" localizedTitle:[[NSBundle mainBundle] localizedStringForKey:@"QUICK_ACTION_SEND_MY_LOCATION" value:@"" table:@"InfoPlist-OrbHW"] localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeShare] userInfo:nil];
    UIMutableApplicationShortcutItem *searchNearBy = [[UIMutableApplicationShortcutItem alloc] initWithType:@"com.apple.Maps.search-nearby" localizedTitle:[[NSBundle mainBundle] localizedStringForKey:@"QUICK_ACTION_SEARCH_NEARBY" value:@"" table:@"InfoPlist-OrbHW"] localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeSearch] userInfo:nil];
    [[UIApplication sharedApplication] setShortcutItems: @[ directionHome, markLocation, shareLocation, searchNearBy ]];
}
+ (void)addPhotosShortCuts {

	NSURL *lastImageURL = [DCIMImageWellUtilities cameraPreviewWellImageFileURL];
	NSData *imageData = [[NSData alloc] initWithContentsOfURL:lastImageURL];
	PLQuickActionManager *qActionManager = [PLQuickActionManager sharedManager];
	[qActionManager _setCachedMostRecentPhotoData:imageData];
	[qActionManager _setMostRecentPhotoIsInvalid:NO];

	// i don't know why it doesn't work :(
	SBSApplicationShortcutCustomImageIcon *recentSbsIcon = [[SBSApplicationShortcutCustomImageIcon alloc] initWithImagePNGData:[qActionManager _cachedMostRecentPhotoData]];

	UIApplicationShortcutIcon *recentIcon = [[UIApplicationShortcutIcon alloc] initWithSBSApplicationShortcutIcon:recentSbsIcon];
	UIApplicationShortcutIcon *favoruIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"QuickActionFavorite-OrbHW"];
	UIApplicationShortcutIcon *onYearIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"QuickActionAYearAgo-OrbHW"];

	UIMutableApplicationShortcutItem *directionHome = [[UIMutableApplicationShortcutItem alloc] initWithType:@"com.apple.photos.shortcuts.recentphoto" localizedTitle:@"MOST_RECENT_PHOTO" localizedSubtitle:nil icon:recentIcon userInfo:nil];
	UIMutableApplicationShortcutItem *markLocation = [[UIMutableApplicationShortcutItem alloc] initWithType:@"com.apple.photos.shortcuts.favorites" localizedTitle:@"FAVORITES" localizedSubtitle:nil icon:favoruIcon userInfo:nil];
    UIMutableApplicationShortcutItem *shareLocation = [[UIMutableApplicationShortcutItem alloc] initWithType:@"com.apple.photos.shortcuts.oneyearago" localizedTitle:@"ONE_YEAR_AGO" localizedSubtitle:nil icon:onYearIcon userInfo:nil];
    UIMutableApplicationShortcutItem *searchNearBy = [[UIMutableApplicationShortcutItem alloc] initWithType:@"com.apple.photos.shortcuts.search" localizedTitle:@"SEARCH" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeSearch] userInfo:nil];
    [[UIApplication sharedApplication] setShortcutItems: @[ directionHome, markLocation, shareLocation, searchNearBy ]];

}
@end

extern "C" _Bool _UIAccessibilityForceTouchEnabled();

MSHook(_Bool, _UIAccessibilityForceTouchEnabled)
{
	return TRUE;
}

%group mainUI
%hook UIApplication
- (BOOL)_handleDelegateCallbacksWithOptions:(id)arg1 isSuspended:(BOOL)arg2 restoreState:(BOOL)arg3 {

	BOOL handleDelegate = %orig();
	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	if ([bundleIdentifier isEqualToString:@"com.apple.Maps"]) {
		[CorebaHelper addMapsShortCuts];
	} else if ([bundleIdentifier isEqualToString:@"com.apple.mobileslideshow"]) {
		[CorebaHelper addPhotosShortCuts];
	}
		
	return handleDelegate;
}
%end
%end

%group TWMain
%hook TFNTwitterDeviceFeatureSwitches
+ (_Bool)isNewMessageShortcutEnabled {
	return YES;
}
+ (_Bool)areApplicationShortcutsEnabled {
	return YES;
}
%end
%end

%group WAMain

@interface WAVoiceCallViewController : UIViewController
- (void)minimizeWithAnimation:(_Bool)arg1;
@end

@interface WhatsAppAppDelegate : NSObject {
	WAVoiceCallViewController *_activeVoiceCallViewController;
}
@property(readonly, nonatomic) _Bool isCallWindowVisible;
@property(readonly, nonatomic) UITabBarController *tabBarController; // @synthesize 
@property(retain, nonatomic) NSString *chatJID; // @synthesize chatJID=_chatJID;
- (void)revm_PerformLastChat;
- (void)openChatAnimated:(_Bool)arg1 presentKeyboard:(_Bool)arg2;
@end

@interface WAChatSession : NSObject
@property(retain, nonatomic) NSString *contactJID; // @dynamic contactJID;
@end

@interface WAChatStorage : NSObject
- (id)allChatSessions;
@end

@interface WASharedAppData : NSObject
+ (WAChatStorage *)chatStorage;
@end

%hook WhatsAppAppDelegate
- (void)configureShortcutItemsForApplication:(UIApplication *)arg1 {
	%orig;
	NSArray *currentActions = arg1.shortcutItems;
	UIMutableApplicationShortcutItem *lastChatItem = [[UIMutableApplicationShortcutItem alloc] initWithType:@"lastChat" localizedTitle:@"Last Chat" localizedSubtitle:nil icon:nil userInfo:nil];
	NSArray *newActions = [[NSArray alloc] initWithObjects:lastChatItem, nil];
	currentActions = [currentActions arrayByAddingObjectsFromArray:newActions];
	[arg1 setShortcutItems:currentActions];
}
- (void)application:(id)arg1 performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(id)arg3 {
	%orig;
	if ([shortcutItem.type isEqualToString:@"lastChat"]) {
		[self revm_PerformLastChat];
	}
}
%new
- (void)revm_PerformLastChat {
	if ([self isCallWindowVisible]) {
		WAVoiceCallViewController *callVC = MSHookIvar<WAVoiceCallViewController *>(self, "_activeVoiceCallViewController");
		[callVC minimizeWithAnimation:NO];
	}
	WAChatStorage *chatStorage = [%c(WASharedAppData) chatStorage];
	NSArray *allChats = [chatStorage allChatSessions];
	WAChatSession *lastChatSession = [allChats objectAtIndex:1];
	[self setChatJID:lastChatSession.contactJID];
	if (self.tabBarController.selectedViewController.presentedViewController) {
		[[self.tabBarController selectedViewController] dismissViewControllerAnimated:NO completion:nil];
	}
	[self openChatAnimated:YES presentKeyboard:NO];
}
%end
%end

%ctor {
	@autoreleasepool {
		MSHookFunction(_UIAccessibilityForceTouchEnabled, MSHake(_UIAccessibilityForceTouchEnabled));
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UIAccessibilityForceTouchStatusChangedNotification" object:nil];

		NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
		if ([bundleIdentifier isEqualToString:@"com.atebits.Tweetie2"]) {
			%init(TWMain);
		} else if ([bundleIdentifier isEqualToString:@"net.whatsapp.WhatsApp"]) {
			%init(WAMain);
		}
		%init(mainUI);
	}
}
