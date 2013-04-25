
#import <GameKit/GameKit.h>

#pragma mark -
#pragma mark Authentication
typedef void(^SHGameAuthenticationBlock)(BOOL isAuthenticated, NSError * error);

#pragma mark - 
#pragma mark - Lists: Matches or Friends,
typedef void(^SHGameListsBlock)(NSOrderedSet * responseSet, NSError * error);

#pragma mark - 
#pragma mark Bootstrap Lists, Matchens and Friends with errors
typedef void(^SHGameAttributesBlock)(NSDictionary * attributes);
typedef void (^SHGameNotificationWillEnterForegroundBlock)(NSNotification * notification);
typedef void (^SHGameCompletionBlock)(void);

#pragma mark - 
#pragma mark GKTurnBasedMatch
typedef void(^SHGameMatchBlock)(GKTurnBasedMatch * match, NSError * error);

#pragma mark - <GKTurnBasedEventHandlerDelegate>
typedef void(^SHGameMatchEventInvitesBlock)(NSOrderedSet * playersToInvite);
typedef void(^SHGameMatchEventTurnBlock)(GKTurnBasedMatch * match, BOOL didBecomeActive);
typedef void(^SHGameMatchEventEndedBlock)(GKTurnBasedMatch * match);