
#import "SHGameCenterBlockDefinitions.h"

#pragma mark -
#pragma mark Keys
static NSString * const SHGameCenterErrorKey = @"SHGameCenterError";
static NSString * const SHGameCenterSetKey   = @"SHGameCenterSetKey";

static NSString * const SHGameCenterAttributeFriendsKey   = @"SHGameCenterAttributeFriendsKey";
static NSString * const SHGameCenterAttributeMatchesKey   = @"SHGameCenterAttributeMatchesKey";


@interface GKTurnBasedMatch (SHGameCenter)

#pragma mark -
#pragma mark Participant Getters
@property(nonatomic,readonly) GKTurnBasedParticipant  * SH_meAsParticipant;
@property(nonatomic,readonly) NSOrderedSet            * SH_participantsWithoutMe;
@property(nonatomic,readonly) NSOrderedSet            * SH_participantsWithoutCurrentParticipant;
@property(nonatomic,readonly) NSOrderedSet            * SH_nextParticipantsInLine;
@property(nonatomic,readonly) NSOrderedSet            * SH_playerIdentifiers;

#pragma mark -
#pragma mark Conditions
@property(nonatomic,readonly) BOOL SH_isMyTurn;
//Participants who are neither active nor invited - e.g done, declined and etc
@property(nonatomic,readonly) BOOL SH_hasIncompleteParticipants;

@property(nonatomic,readonly) BOOL SH_isMatchStatusOpen;
@property(nonatomic,readonly) BOOL SH_isMatchStatusMatching;
@property(nonatomic,readonly) BOOL SH_isMatchStatusEnded;
@property(nonatomic,readonly) BOOL SH_isMatchStatusUnknown;


#pragma mark -
#pragma mark Observer
-(void)SH_setObserver:(id)theObserver
  matchEventTurnBlock:(SHGameMatchEventTurnBlock)theMatchEventTurnBlock
 matchEventEndedBlock:(SHGameMatchEventEndedBlock)theMatchEventEndedBlock;

+(void)SH_setObserver:(id)theObserver
matchEventTurnBlock:(SHGameMatchEventTurnBlock)theMatchEventTurnBlock
matchEventEndedBlock:(SHGameMatchEventEndedBlock)theMatchEventEndedBlock
matchEventInvitesBlock:(SHGameMatchEventInvitesBlock)theMatchEventInvitesBlock;


#pragma mark -
#pragma mark Preloaders
//Just use one of these
+(void)SH_requestWithNotificationEnterForegroundBlock:(SHGameNotificationWillEnterForegroundBlock)theWillEnterForegroundBlock matchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock;

+(void)SH_requestMatchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock;

+(void)SH_recursiveRequestMatchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock continuouslyEverySecond:(NSUInteger)theSeconds;


#pragma mark -
#pragma mark Player
-(void)SH_requestPlayersWithBlock:(SHGameListsBlock)theBlock;

#pragma mark -
#pragma mark Equal
-(BOOL)SH_isEqualToMatch:(id)object;

#pragma mark -
#pragma mark Match Getters
+(void)SH_requestMatchesWithBlock:(SHGameListsBlock)theBlock;



#pragma mark -
#pragma mark Match Setters
-(void)SH_resignWithBlock:(SHGameMatchBlock)theBlock;

-(void)SH_deleteWithBlock:(SHGameMatchBlock)theBlock;


#pragma mark -
#pragma mark Helpers
-(NSOrderedSet *)SH_rejectParticipants:(NSSet *)theParticipantsToRject;


@end
