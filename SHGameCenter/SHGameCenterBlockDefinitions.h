
#import <GameKit/GameKit.h>

#pragma mark -
#pragma mark Authentication
typedef void(^SHGameViewControllerBlock)(UIViewController * viewController);

#pragma mark - 
#pragma mark - Lists: Matches or Friends,
typedef void(^SHGameListsBlock)(NSArray * response, NSError * error);

typedef void(^SHGameErrorBlock)(NSError * error);
typedef void(^SHGameCompletionBlock)(void);

#pragma mark - 
#pragma mark GKTurnBasedMatch
typedef void(^SHGameMatchBlock)(GKTurnBasedMatch * match, NSError * error);

#pragma mark - <GKTurnBasedEventHandlerDelegate>
typedef void(^SHGameMatchEventInvitesBlock)(NSArray * playersToInvite);
typedef void(^SHGameMatchEventTurnBlock)(GKTurnBasedMatch * match, BOOL didBecomeActive);
typedef void(^SHGameMatchEventEndedBlock)(GKTurnBasedMatch * match);