#import "SHFastEnumerationProtocols.h"

#import "GKTurnBasedMatch+SHGameCenter.h"
#import "SHGameCenter.h"
#include "SHGameCenter.private"

@interface GKLocalPlayer()

#pragma mark - Player Getters
+(void)SH_requestWithoutCacheFriendsWithBlock:(SHGameListsBlock)theBlock;
@end

static NSString * const SHGameMatchEventTurnKey     = @"SHGameMatchEventTurnKey";
static NSString * const SHGameMatchEventEndedKey    = @"SHGameMatchEventEndedKey";
static NSString * const SHGameMatchEventInvitesKey  = @"SHGameMatchEventInvitesKey";

@interface SHTurnBasedMatchManager : NSObject
<GKTurnBasedEventHandlerDelegate>
@property(nonatomic,strong) NSMapTable          * mapAllMatchesBlocks;
@property(nonatomic,strong) NSMapTable          * mapMatchBlocks;

//@property(nonatomic,assign)   NSNotification           * notificationEnterForeground;
//
//@property(nonatomic,copy) SHGameNotificationWillEnterForegroundBlock    notificationBlock;



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
    
    //    self.notificationEnterForeground = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
    //      self.notificationEnterForeground = note;
    ////      [GKTurnBasedMatch SH_requestWithNotificationEnterForegroundBlock:self.notificationBlock matchesAndFriendsWithBlock:self.matchesAndFriendsBlock];
    //    }];
    
  }
  
  return self;
}

-(void)dealloc; {
  //  [NSNotificationCenter.defaultCenter removeObserver:self.notificationEnterForeground];
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
  for (NSDictionary * blocks in self.mapAllMatchesBlocks.objectEnumerator) {
    SHGameMatchEventInvitesBlock block = blocks[SHGameMatchEventInvitesKey];
    block(playersToInvite);
  }
  
}

-(void)handleTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive; {
  
  [SHGameCenter updateCachePlayersFromPlayerIdentifiers:match.SH_playerIdentifiers withResponseBlock:nil withCachedBlock:^(NSError *error) {
    if(error == nil) {
      for (NSDictionary * blocks in self.mapAllMatchesBlocks.objectEnumerator) {
        SHGameMatchEventTurnBlock block = blocks[SHGameMatchEventTurnKey];
        block(match, didBecomeActive);
      }
      
      for (NSDictionary * blocks in self.mapMatchBlocks.objectEnumerator) {
        NSDictionary * matchBlock = blocks[match.matchID];
        SHGameMatchEventTurnBlock block = matchBlock[SHGameMatchEventTurnKey];
        if(block)
          block(match, didBecomeActive);
      }
      
    }
    
  }];
  
  
}

// handleMatchEnded is called when the match has ended.
-(void)handleMatchEnded:(GKTurnBasedMatch *)match; {
  
  [SHGameCenter updateCachePlayersFromPlayerIdentifiers:match.SH_playerIdentifiers withResponseBlock:nil withCachedBlock:^(NSError *error) {
    for (NSDictionary * blocks in self.mapAllMatchesBlocks.objectEnumerator) {
      SHGameMatchEventEndedBlock block = blocks[SHGameMatchEventEndedKey];
      block(match);
    }
    
    for (NSDictionary * blocks in self.mapMatchBlocks.objectEnumerator) {
      NSDictionary * matchBlock = blocks[match.matchID];
      SHGameMatchEventEndedBlock block = matchBlock[SHGameMatchEventEndedKey];
      if(block)
        block(match);
    }
    
  }];
  
}

@end

@interface GKTurnBasedMatch (Privates)
#pragma mark -
#pragma mark Privates
#pragma mark -
#pragma mark Getters
+(void)SH_requestWithoutCacheMatchesWithBlock:(SHGameListsBlock)theBlock;

#pragma mark -
#pragma mark Helpers
+(NSArray *)SH_collectPlayerIdsFromMatches:(NSArray *)theMatches
                               withFriends:(NSArray *)theFriends;

+(NSArray *)SH_filterOutFriendsFromPlayers:(NSArray *)thePlayers
                             withFriendIds:(NSArray *)theFriends;


+(NSArray *)SH_sortParticipants:(NSArray *)theParticipants withSelector:(SEL)theSelector;
@end

@implementation GKTurnBasedMatch (SHGameCenter)


#pragma mark - Player Getters
-(GKTurnBasedParticipant *)SH_meAsParticipant; {
  return [self.participants SH_find:^BOOL(GKTurnBasedParticipant * participant) {
    return [participant SH_isEqual:GKLocalPlayer.SH_me];
  }];
}

-(NSArray *)SH_participantsWithoutMe; {
  NSArray * participantsWithoutMe = nil;
  if(self.SH_meAsParticipant)
    participantsWithoutMe = [self SH_rejectParticipants:@[self.SH_meAsParticipant]];
  else
    participantsWithoutMe = self.participants;
  return [GKTurnBasedMatch SH_sortParticipants:participantsWithoutMe withSelector:@selector(lastTurnDate)];
}

-(NSArray *)SH_participantsWithoutCurrentParticipant; {
  NSArray * participantsWithoutCurrentParticipant = nil;
  if(self.currentParticipant)
    participantsWithoutCurrentParticipant = [self SH_rejectParticipants:@[self.currentParticipant]];
  else
    participantsWithoutCurrentParticipant = self.participants;
  
  return [GKTurnBasedMatch SH_sortParticipants:participantsWithoutCurrentParticipant withSelector:@selector(lastTurnDate)];
}

-(NSArray *)SH_nextParticipantsInLine; {
  return [GKTurnBasedMatch SH_sortParticipants:self.participants withSelector:@selector(lastTurnDate)];
}


-(NSArray *)SH_playerIdentifiers; {
  return [self.participants SH_map:^id(GKTurnBasedParticipant * obj) { return obj.playerID; }];
}


#pragma mark - Observer
-(void)SH_setObserver:(id)theObserver
  matchEventTurnBlock:(SHGameMatchEventTurnBlock)theMatchEventTurnBlock
 matchEventEndedBlock:(SHGameMatchEventEndedBlock)theMatchEventEndedBlock; {
  
  NSAssert(theObserver, @"Must pass an observer!");
  
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



#pragma mark -
#pragma mark Preloaders
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
      
      
      //Fetch and cache players via playerIds
      [SHGameCenter updateCachePlayersFromPlayerIdentifiers:playerIds withResponseBlock:^(NSArray *response, NSError *error) {
        
        theFriendsBlock([self SH_filterOutFriendsFromPlayers:response withFriendIds:friends],
                        error);
        dispatch_async(dispatch_get_main_queue(), ^{
          theCompletionBlock();
        });
        
      } withCachedBlock:nil];
      
    }];
    
  }];
  
  
}


//+(void)SH_requestWithNotificationEnterForegroundBlock:(SHGameNotificationWillEnterForegroundBlock)theWillEnterForegroundBlock
//                           matchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock; {
//
//  NSAssert(theWillEnterForegroundBlock, @"Must pass a SHGameNotificationWillEnterForegroundBlock");
//  SHTurnBasedMatchManager.sharedManager.notificationBlock = theWillEnterForegroundBlock;
//  theWillEnterForegroundBlock(SHTurnBasedMatchManager.sharedManager.notificationEnterForeground);
//  [self SH_requestMatchesAndFriendsWithBlock:theBlock];
//  SHTurnBasedMatchManager.sharedManager.matchesAndFriendsBlock = theBlock;
//}
//
//+(void)SH_recursiveRequestMatchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock continuouslyEverySecond:(NSUInteger)theSeconds; {
//  if(theSeconds < 3) theSeconds = 2;
//  dispatch_async(dispatch_get_main_queue(), ^{
//    [self SH_requestMatchesAndFriendsWithBlock:theBlock];
//  });
//  double delayInSeconds = 2.0;
//  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//  dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
//    [self SH_recursiveRequestMatchesAndFriendsWithBlock:theBlock continuouslyEverySecond:theSeconds];
//  });
//
//}




#pragma mark -
#pragma mark Conditions
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
-(BOOL)SH_isEqualToMatch:(id)object; {
  BOOL isEqual = NO;
  if([object respondsToSelector:@selector(matchID)])
    isEqual = [self.matchID isEqualToString:((GKTurnBasedMatch *)object).matchID];
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

#pragma mark - Helpers
-(NSArray *)SH_rejectParticipants:(NSArray *)theParticipantsToRject; {
  NSParameterAssert([theParticipantsToRject SH_all:^BOOL(id<SHPlayable> obj) {
    return [obj conformsToProtocol:@protocol(SHPlayable)];
  }]);
  
  return [self.participants SH_reject:^BOOL(GKTurnBasedParticipant * participant) {
    return[theParticipantsToRject SH_find:^BOOL(GKTurnBasedParticipant * participantToRemove) {
      return [participant SH_isEqual:participantToRemove];
    }];
  }];
}


#pragma mark - Privates


#pragma mark - Match Getters
+(void)SH_requestWithoutCacheMatchesWithBlock:(SHGameListsBlock)theBlock; {
  [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      theBlock(matches, error);
    });
    
    
  }];
}


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


+(NSArray *)SH_sortParticipants:(NSArray *)theParticipants withSelector:(SEL)theSelector; {
  return [theParticipants sortedArrayUsingComparator:^NSComparisonResult(GKTurnBasedParticipant * obj1, GKTurnBasedParticipant * obj2) {
    NSComparisonResult result = NSOrderedSame;
    if([obj1 performSelector:theSelector] == nil)       result = NSOrderedAscending;
    else if ([obj2 performSelector:theSelector]  == nil) result = NSOrderedDescending;
    else if(result == NSOrderedSame)   result = [
                                                 [obj1 performSelector:theSelector]
                                                 compare:[obj2 performSelector:theSelector]
                                                 ];
    return result;
  }];
}






@end
