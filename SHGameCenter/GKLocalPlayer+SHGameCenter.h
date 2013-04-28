
#import "SHGameCenterBlockDefinitions.h"


@interface GKLocalPlayer (SHGameCenter)


#pragma mark -
#pragma mark Authentication
//handles on foreground notifications
+(void)SH_authenticateLoggedInBlock:(SHGameCompletionBlock)theLoggedInBlock
                     loggedOutBlock:(SHGameCompletionBlock)theLoggedOutBlock
                     withErrorBlock:(SHGameErrorBlock)theErroBlock
            withLoginViewController:(SHGameViewControllerBlock)theLoginViewControllerBlock;

#pragma mark -
#pragma mark Player Getters
+(GKLocalPlayer *)SH_me;
+(void)SH_requestFriendsWithBlock:(SHGameListsBlock)theBlock;


@end
