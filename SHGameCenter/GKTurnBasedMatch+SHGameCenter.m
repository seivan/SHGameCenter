#import "SHFastEnumerationProtocols.h"

#import "GKTurnBasedMatch+SHGameCenter.h"
#import "SHGameCenter.h"
#include "SHGameCenter.private"

//@interface GKLocalPlayer()
//
//#pragma mark - Player Getters
//+(void)SH_requestWithoutCacheFriendsWithBlock:(SHGameListsBlock)theBlock;
//@end

static NSString * const SHGameMatchEventTurnKey     = @"SHGameMatchEventTurnKey";
static NSString * const SHGameMatchEventEndedKey    = @"SHGameMatchEventEndedKey";
static NSString * const SHGameMatchEventInvitesKey  = @"SHGameMatchEventInvitesKey";

@interface SHTurnBasedMatchManager : NSObject
<GKTurnBasedEventHandlerDelegate>
@property(nonatomic,strong) NSMapTable          * mapAllMatchesBlocks;
@property(nonatomic,strong) NSMapTable          * mapMatchBlocks;



#pragma mark - Singleton Methods
+(instancetype)sharedManager;

@end

@implementation SHTurnBasedMatchManager

#pragma mark - Init & Dealloc
-(instancetype)init; {
  self = [super init];
  if (self) {
    GKTurnBasedEventHandler.sharedTurnBasedEventHandler.delegate = self;
    
    self.mapAllMatchesBlocks  = [NSMapTable weakToStrongObjectsMapTable];
    self.mapMatchBlocks       = [NSMapTable weakToStrongObjectsMapTable];
    
  }
  
  return self;
}


#pragma mark - Singleton Methods
+(instancetype)sharedManager; {
  static SHTurnBasedMatchManager *_sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[SHTurnBasedMatchManager alloc] init];
    
  });
  
  return _sharedInstance;
  
}



#pragma mark - <GKTurnBasedEventHandlerDelegate>
-(void)handleInviteFromGameCenter:(NSArray *)playersToInvite; {
  [self.mapAllMatchesBlocks SH_each:^(NSDictionary * blocks) {
    SHGameMatchEventInvitesBlock block = blocks[SHGameMatchEventInvitesKey];
    block(playersToInvite);
  }];
  
}

-(void)handleTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive; {
  
  
  
  [SHGameCenter updateCachePlayersFromPlayerIdentifiers:match.SH_playerIdentifiers withResponseBlock:nil withCachedBlock:^(NSError *error) {
    if(error == nil) {

      [self.mapAllMatchesBlocks.objectEnumerator.allObjects SH_each:^(NSDictionary * matchBlock) {
        SHGameMatchEventTurnBlock block = matchBlock[SHGameMatchEventTurnKey];
        if(block) block(match, didBecomeActive);
      }];
      
      
      
      [self.mapMatchBlocks.objectEnumerator.allObjects SH_each:^(NSDictionary * matchBlock) {
        NSDictionary * blocks = matchBlock[match.matchID];
        SHGameMatchEventTurnBlock block = blocks[SHGameMatchEventTurnKey];
        if(block) block(match, didBecomeActive);
      }];
      
    }
    
  }];
  
  
}

// handleMatchEnded is called when the match has ended.
-(void)handleMatchEnded:(GKTurnBasedMatch *)match; {
  
  [SHGameCenter updateCachePlayersFromPlayerIdentifiers:match.SH_playerIdentifiers withResponseBlock:nil withCachedBlock:^(NSError *error) {

    [self.mapAllMatchesBlocks.objectEnumerator.allObjects SH_each:^(NSDictionary * matchBlock) {
      SHGameMatchEventEndedBlock block = matchBlock[SHGameMatchEventEndedKey];
      block(match);
    }];
    
    [self.mapMatchBlocks.objectEnumerator.allObjects SH_each:^(NSDictionary * matchBlock) {
      NSDictionary * blocks = matchBlock[match.matchID];
      SHGameMatchEventEndedBlock block = blocks[SHGameMatchEventEndedKey];
      if(block)block(match);
    }];
    
  }];
  
}

@end

@interface GKTurnBasedMatch (Privates)


#pragma mark - Privates


#pragma mark - Helpers
+(NSArray *)SH_collectPlayerIdsFromMatches:(NSArray *)theMatches
                               withFriends:(NSArray *)theFriends;

+(NSArray *)SH_filterOutFriendsFromPlayers:(NSArray *)thePlayers
                             withFriendIds:(NSArray *)theFriends;


+(NSArray *)SH_sortOnLastTurnDateForParticipants:(NSArray *)theParticipants;

@end

@implementation GKTurnBasedMatch (SHGameCenter)


#pragma mark - Player Getters
-(GKTurnBasedParticipant *)SH_meAsParticipant; {
  return [self.participants SH_find:^BOOL(GKTurnBasedParticipant * participant) {
    return [participant SH_isEqual:GKLocalPlayer.SH_me];
  }];
}

-(NSArray *)SH_participantsWithoutMe; {
  return [GKTurnBasedMatch SH_sortOnLastTurnDateForParticipants:
          [self.participants SH_reject:^BOOL(GKTurnBasedParticipant * obj) {
    return [obj SH_isEqual:self.SH_meAsParticipant];
  }]];
}

-(NSArray *)SH_participantsWithoutCurrentParticipant; {
  return [GKTurnBasedMatch SH_sortOnLastTurnDateForParticipants:
          [self.participants SH_reject:^BOOL(GKTurnBasedParticipant * obj) {
    return [obj SH_isEqual:self.currentParticipant];
  }]];
}

-(NSArray *)SH_participantsInOrder; {
  return [GKTurnBasedMatch SH_sortOnLastTurnDateForParticipants:self.participants];
}


-(NSArray *)SH_playerIdentifiers; {
  return [self.participants SH_map:^id(GKTurnBasedParticipant * obj) { return obj.playerID; }];
}


#pragma mark - Observer
-(void)SH_setObserver:(id)theObserver
  matchEventTurnBlock:(SHGameMatchEventTurnBlock)theMatchEventTurnBlock
 matchEventEndedBlock:(SHGameMatchEventEndedBlock)theMatchEventEndedBlock; {
  
  NSParameterAssert(theObserver);
  
  NSMutableDictionary * blocks      = @{}.mutableCopy;
  NSDictionary        * matchBlock  = @{self.matchID : blocks};
  
  if(theMatchEventTurnBlock)    blocks[SHGameMatchEventTurnKey]    = [theMatchEventTurnBlock copy];
  if(theMatchEventEndedBlock)   blocks[SHGameMatchEventEndedKey]   = [theMatchEventEndedBlock copy];
  
  [SHTurnBasedMatchManager.sharedManager.mapMatchBlocks setObject:matchBlock.copy forKey:theObserver];
  
}


+(void)SH_setObserver:(id)theObserver
  matchEventTurnBlock:(SHGameMatchEventTurnBlock)theMatchEventTurnBlock
 matchEventEndedBlock:(SHGameMatchEventEndedBlock)theMatchEventEndedBlock
matchEventInvitesBlock:(SHGameMatchEventInvitesBlock)theMatchEventInvitesBlock; {
  
  NSParameterAssert(theObserver);
  
  NSMutableDictionary * blocks = @{}.mutableCopy;
  
  if(theMatchEventTurnBlock)    blocks[SHGameMatchEventTurnKey]    = [theMatchEventTurnBlock copy];
  if(theMatchEventEndedBlock)   blocks[SHGameMatchEventEndedKey]   = [theMatchEventEndedBlock copy];
  if(theMatchEventInvitesBlock) blocks[SHGameMatchEventInvitesKey] = [theMatchEventInvitesBlock copy];
  
  [SHTurnBasedMatchManager.sharedManager.mapAllMatchesBlocks setObject:blocks.copy forKey:theObserver];
  
}




#pragma mark - Preloaders
+(void)SH_requestMatchesWithBlock:(SHGameListsBlock)theMatchesBlock
              andFriendsWithBlock:(SHGameListsBlock)theFriendsBlock
              withCompletionBlock:(SHGameCompletionBlock)theCompletionBlock; {
  
  NSParameterAssert(theMatchesBlock);
  NSParameterAssert(theFriendsBlock);
  NSParameterAssert(theCompletionBlock);
  
  [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *matchesError) {

    matches = matches ? matches : @[];
    dispatch_async(dispatch_get_main_queue(), ^{
      theMatchesBlock(matches,matchesError);
    });
    
    
    [GKLocalPlayer.localPlayer loadFriendsWithCompletionHandler:^(NSArray *friends, NSError *friendsError) {
      
      friends = friends ? friends : @[];
      if(friendsError) dispatch_async(dispatch_get_main_queue(), ^{
        theFriendsBlock(friends, friendsError);
        theCompletionBlock();
      });
      
      NSArray * playerIds = [self SH_collectPlayerIdsFromMatches:matches withFriends:friends];
      
      

      [SHGameCenter updateCachePlayersFromPlayerIdentifiers:playerIds withResponseBlock:^(NSArray *response, NSError *error) {
        
        theFriendsBlock([self SH_filterOutFriendsFromPlayers:response
                                               withFriendIds:friends],
                        error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
          theCompletionBlock();
        });
        
      } withCachedBlock:nil];
      
    }];
    
  }];
  
  
}





#pragma mark - Conditions
-(BOOL)SH_isMyTurn; {
  return [self.currentParticipant SH_isEqual:GKLocalPlayer.SH_me];
}
-(BOOL)SH_hasIncompleteParticipants; {
  return [self.participants SH_any:^BOOL(GKTurnBasedParticipant * participant) {
    return participant.SH_isActiveOrInvited == NO;
  }];
}

-(BOOL)SH_isMatchStatusOpen; {
  return self.status == GKTurnBasedMatchStatusOpen;
}
-(BOOL)SH_isMatchStatusMatching; {
  return self.status == GKTurnBasedMatchStatusMatching;
}
-(BOOL)SH_isMatchStatusEnded; {
  return self.status == GKTurnBasedMatchStatusEnded;
}

-(BOOL)SH_isMatchStatusUnknown; {
  return self.status == GKTurnBasedMatchStatusUnknown;
}


#pragma mark - Player
-(void)SH_requestPlayersWithBlock:(SHGameListsBlock)theBlock; {
  [SHGameCenter updateCachePlayersFromPlayerIdentifiers:self.SH_playerIdentifiers
                                      withResponseBlock:theBlock withCachedBlock:nil];
  
}





#pragma mark - Equal
-(BOOL)SH_isEqualToMatch:(GKTurnBasedMatch *)theMatch; {
  BOOL isEqual = NO;
  if([theMatch respondsToSelector:@selector(matchID)])
    isEqual = [self.matchID isEqualToString:theMatch.matchID];
  return isEqual;
}


#pragma mark - Match Getters
+(void)SH_requestMatchesWithBlock:(SHGameListsBlock)theBlock; {
  [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
    NSMutableSet * playerIdentifiers = @[].mutableCopy;
    [matches SH_each:^(GKTurnBasedMatch * match) {
      [playerIdentifiers addObjectsFromArray:match.SH_playerIdentifiers];
    }];
    
    if(error)dispatch_async(dispatch_get_main_queue(), ^{
      theBlock(nil,error);
    });
    else
      [SHGameCenter updateCachePlayersFromPlayerIdentifiers:playerIdentifiers.copy withResponseBlock:nil withCachedBlock:^(NSError *error){
        theBlock(matches, error);
      }];
    
  }];
}




#pragma mark - Match Setters
//Need to refactor here. Things are still uncertain.
-(void)SH_resignWithBlock:(SHGameMatchBlock)theBlock; {
  //  [self.participants each:^(GKTurnBasedParticipant * participant) {
  //    participant.matchOutcome = GKTurnBasedMatchOutcomeQuit;
  //  }];
  
  //  if(self.SH_isMatchStatusEnded)
  //    theBlock(self,nil);
  //  else
  [self endMatchInTurnWithMatchData:self.matchData completionHandler:^(NSError *error) {
    if(error)
      [self participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
          theBlock(self, error);
        });
        
      }];
    else dispatch_async(dispatch_get_main_queue(), ^{
      theBlock(self, error);
    });
    
    
  }];
  
  
  
}

-(void)SH_deleteWithBlock:(SHGameMatchBlock)theBlock; {
  [self SH_resignWithBlock:^(GKTurnBasedMatch *match, NSError *error) {
    if(error) theBlock(match, error);
    else
      [self removeWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
          theBlock(self, error);
        });
      }];
  }];
  
}


#pragma mark - Privates


#pragma mark - Helpers
+(NSArray *)SH_collectPlayerIdsFromMatches:(NSArray *)theMatches
                               withFriends:(NSArray *)theFriends; {
  
  // Collect all playerIDs.
  NSMutableArray * setOfPlayerIds = @[].mutableCopy;
  [theMatches SH_each:^(GKTurnBasedMatch * match) {
    [setOfPlayerIds addObjectsFromArray:match.SH_playerIdentifiers];
  }];
  [setOfPlayerIds addObjectsFromArray:theFriends];
  
  return setOfPlayerIds;
}

+(NSArray *)SH_filterOutFriendsFromPlayers:(NSArray *)thePlayers
                             withFriendIds:(NSArray *)theFriendIds; {
  //Find all players that are friends
  NSArray * unfilteredFriends = [theFriendIds SH_map:^id(NSString * playerIdentifier) {
    return [thePlayers SH_find:^BOOL(GKPlayer * player) {
      return [player.playerID isEqualToString:playerIdentifier];
    }];
  }];
  
  //Get rid  of all NSNulls and set the friendsAttribute
  return [unfilteredFriends SH_reject:^BOOL(id obj) {
    return obj == [NSNull null];
  }];
  
}


+(NSArray *)SH_sortOnLastTurnDateForParticipants:(NSArray *)theParticipants; {
  return [theParticipants sortedArrayUsingComparator:^NSComparisonResult(GKTurnBasedParticipant * obj1, GKTurnBasedParticipant * obj2) {
    NSComparisonResult result = NSOrderedSame;
    if(obj1.lastTurnDate == nil)       result = NSOrderedAscending;
    else if (obj2.lastTurnDate  == nil) result = NSOrderedDescending;
    else if(result == NSOrderedSame)   result = [obj1.lastTurnDate compare:obj2.lastTurnDate];
    return result;
  }];
}






@end
