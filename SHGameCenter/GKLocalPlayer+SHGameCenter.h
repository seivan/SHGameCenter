
#import "SHGameCenterBlockDefinitions.h"


@interface GKLocalPlayer (SHGameCenter)


#pragma mark -
#pragma mark Authentication
//handles on foreground notifications
+(void)SH_authenticateWithBlock:(SHGameAuthenticationBlock)theBlock
                     andLoginViewController:(void(^)(UIViewController * viewController))loginViewControllerHandler;


#pragma mark -
#pragma mark Player Getters
+(GKLocalPlayer *)SH_me;
+(void)SH_requestFriendsWithBlock:(SHGameListsBlock)theBlock;


@end
