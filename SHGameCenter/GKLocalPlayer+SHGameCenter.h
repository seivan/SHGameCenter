
#import "SHGameCenterBlockDefinitions.h"


@interface GKLocalPlayer (SHGameCenter)



#pragma mark - Authentication
//handles on foreground notifications
+(void)SH_authenticateWithLoginViewControllerBlock:(SHGameViewControllerBlock)theLoginViewControllerBlock
                                     didLoginBlock:(SHGameCompletionBlock)theLoginBlock
                                    didLogoutBlock:(SHGameCompletionBlock)theLogoutBlock
                                    withErrorBlock:(SHGameErrorBlock)theErrorBlock;

#pragma mark - Properties
#pragma mark - Player Getters
+(GKLocalPlayer *)SH_me;
+(void)SH_requestFriendsWithBlock:(SHGameListsBlock)theBlock;


@end
