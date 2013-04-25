
#import "SHGameCenterBlockDefinitions.h"

#pragma mark -
#pragma mark Keys
static NSString * const SHGameCenterErrorKey = @"SHGameCenterError";
static NSString * const SHGameCenterSetKey   = @"SHGameCenterSetKey";

static NSString * const SHGameCenterAttributeFriendsKey   = @"SHGameCenterAttributeFriendsKey";
static NSString * const SHGameCenterAttributeMatchesKey   = @"SHGameCenterAttributeMatchesKey";

@interface GKLocalPlayer (SHGameCenter)


#pragma mark -
#pragma mark Authentication
//handles on foreground notifications
+(void)SH_authenticateWithBlock:(SHGameAuthenticationBlock)theBlock
                     andLoginViewController:(void(^)(UIViewController * viewController))loginViewControllerHandler;

#pragma mark -
#pragma mark Preloaders
//Just use one of these
+(void)SH_requestWithNotificationEnterForegroundBlock:(SHGameNotificationWillEnterForegroundBlock)theWillEnterForegroundBlock matchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock;

+(void)SH_requestMatchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock;

+(void)SH_recursiveRequestMatchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock continuouslyEverySecond:(NSUInteger)theSeconds;

#pragma mark -
#pragma mark Player Getters
+(GKLocalPlayer *)SH_me;
+(void)SH_requestFriendsWithBlock:(SHGameListsBlock)theBlock;


@end
