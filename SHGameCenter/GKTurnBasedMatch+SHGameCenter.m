#import "NSEnumerable+Utilities.h"
#import "NSOrderedSet+BlocksKit.h"
#import "NSArray+BlocksKit.h"
#import "NSOrderedSet+BlocksKit.h"
#import "NSSet+BlocksKit.h"

#import "GKTurnBasedMatch+SHGameCenter.h"

#import "SHGameCenter.h"

#include "SHGameCenter.private"

@interface GKLocalPlayer()
#pragma mark -
#pragma mark Player Getters
+(void)SH_requestWithoutCacheFriendsWithBlock:(SHGameListsBlock)theBlock;
@end

static NSString * const SHGameMatchEventTurnKey     = @"SHGameMatchEventTurnKey";
static NSString * const SHGameMatchEventEndedKey    = @"SHGameMatchEventEndedKey";
static NSString * const SHGameMatchEventInvitesKey  = @"SHGameMatchEventInvitesKey";

@interface SHTurnBasedMatchManager : NSObject
<GKTurnBasedEventHandlerDelegate>
@property(nonatomic,strong) NSMapTable          * mapAllMatchesBlocks;
@property(nonatomic,strong) NSMapTable          * mapMatchBlocks;

@property(nonatomic,assign)   NSNotification           * notificationEnterForeground;

@property(nonatomic,copy) SHGameAttributesBlock          matchesAndFriendsBlock;

@property(nonatomic,copy) SHGameNotificationWillEnterForegroundBlock    notificationBlock;


#pragma mark -
#pragma mark Singleton Methods
+(instancetype)sharedManager;

@end

@implementation SHTurnBasedMatchManager
#pragma mark -
#pragma mark Init & Dealloc
-(instancetype)init; {
  self = [super init];
  if (self) {
    GKTurnBasedEventHandler.sharedTurnBasedEventHandler.delegate = self;
    
    self.mapAllMatchesBlocks  = [NSMapTable weakToStrongObjectsMapTable];
    self.mapMatchBlocks       = [NSMapTable weakToStrongObjectsMapTable];
    
    self.notificationEnterForeground = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
      self.notificationEnterForeground = note;
      [GKTurnBasedMatch SH_requestWithNotificationEnterForegroundBlock:self.notificationBlock matchesAndFriendsWithBlock:self.matchesAndFriendsBlock];
    }];

  }
  
  return self;
}

-(void)dealloc; {
  [NSNotificationCenter.defaultCenter removeObserver:self.notificationEnterForeground];
}


#pragma mark -
#pragma mark Singleton Methods
+(instancetype)sharedManager; {
  static SHTurnBasedMatchManager *_sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[SHTurnBasedMatchManager alloc] init];
    
  });
  
  return _sharedInstance;
  
}


#pragma mark -
#pragma mark <GKTurnBasedEventHandlerDelegate>
-(void)handleInviteFromGameCenter:(NSArray *)playersToInvite; {
  for (NSDictionary * blocks in self.mapAllMatchesBlocks.objectEnumerator) {
    SHGameMatchEventInvitesBlock block = blocks[SHGameMatchEventInvitesKey];
    block(playersToInvite.toOrderedSet);
  }
  
}

-(void)handleTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive; {
  
  [SHGameCenter updateCachePlayersFromPlayerIdentifiers:match.SH_playerIdentifiers.set withResponseBlock:nil withCachedBlock:^(NSError *error) {
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
  
  [SHGameCenter updateCachePlayersFromPlayerIdentifiers:match.SH_playerIdentifiers.set withResponseBlock:nil withCachedBlock:^(NSError *error) {
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
+(NSSet *)SH_collectPlayerIdsFromAttributeForMatches:(NSDictionary *)theMatchAttributes
                              attributeForFriends:(NSDictionary *)theFriendAttributes;

+(NSOrderedSet *)SH_filterOutFriendsFromPlayers:(NSOrderedSet *)theSetOfPlayers
                               withFriendIds:(NSOrderedSet *)theSetOfFriendIds;
@end

@implementation GKTurnBasedMatch (SHGameCenter)

#pragma mark -
#pragma mark Player Getters
-(GKTurnBasedParticipant *)SH_meAsParticipant; {
  return [self.participants match:^BOOL(GKTurnBasedParticipant * participant) {
    return [participant SH_isEqual:GKLocalPlayer.SH_me];
  }];
}

-(NSOrderedSet *)SH_participantsWithoutMe; {
  NSOrderedSet * participantsWithoutMe = nil;
  if(self.SH_meAsParticipant)
   participantsWithoutMe = [self SH_rejectParticipants:@[self.SH_meAsParticipant].toSet];
  else
    participantsWithoutMe = self.participants.toOrderedSet;
  return participantsWithoutMe;
}

-(NSOrderedSet *)SH_participantsWithoutCurrentParticipant; {
  NSOrderedSet * participantsWithoutCurrentParticipant = nil;
  if(self.currentParticipant)
    participantsWithoutCurrentParticipant = [self SH_rejectParticipants:@[self.currentParticipant].toSet];
  else
    participantsWithoutCurrentParticipant = self.participants.toOrderedSet;
  return  participantsWithoutCurrentParticipant;
}

-(NSOrderedSet *)SH_nextParticipantsInLine; {  
  return [self.SH_participantsWithoutCurrentParticipant sortedArrayUsingComparator:^NSComparisonResult(GKTurnBasedParticipant * obj1, GKTurnBasedParticipant * obj2) {
    if(obj1.lastTurnDate == nil)
      return NSOrderedAscending;
    if (obj2.lastTurnDate == nil)
      return NSOrderedDescending;

    return [obj1.lastTurnDate compare:obj2.lastTurnDate];
  }].toOrderedSet;
}

-(NSOrderedSet *)SH_playerIdentifiers; {
  return [self.participants map:^id(GKTurnBasedParticipant * obj) { return obj.playerID; }].toOrderedSet;
}

#pragma mark -
#pragma mark Observer
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
  
  NSAssert(theObserver, @"Must pass an observer!");
  
  NSMutableDictionary * blocks = @{}.mutableCopy;
  
  if(theMatchEventTurnBlock)    blocks[SHGameMatchEventTurnKey]    = [theMatchEventTurnBlock copy];
  if(theMatchEventEndedBlock)   blocks[SHGameMatchEventEndedKey]   = [theMatchEventEndedBlock copy];
  if(theMatchEventInvitesBlock) blocks[SHGameMatchEventInvitesKey] = [theMatchEventInvitesBlock copy];
  
  [SHTurnBasedMatchManager.sharedManager.mapAllMatchesBlocks setObject:blocks.copy forKey:theObserver];
  
}

#pragma mark -
#pragma mark Preloaders
+(void)SH_requestMatchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock; {
  NSAssert(theBlock, @"Must pass a SHGameAttributesBlock");
  
  [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
    NSMutableDictionary   * attributeForMatches = @{}.mutableCopy;
    attributeForMatches[SHGameCenterSetKey]     = matches ? matches.toOrderedSet : @[].toOrderedSet;
    if(error)               attributeForMatches[SHGameCenterErrorKey] = error;
    
    [GKLocalPlayer.localPlayer loadFriendsWithCompletionHandler:^(NSArray *friends, NSError *error) {
      NSMutableDictionary * attributeForFriends = @{}.mutableCopy;
      attributeForFriends[SHGameCenterSetKey]   = friends ? friends.toOrderedSet : @[].toOrderedSet;
      if(error)             attributeForFriends[SHGameCenterErrorKey] = error;
      
      
      NSSet * setOfPlayerIds = [self SH_collectPlayerIdsFromAttributeForMatches:attributeForMatches attributeForFriends:attributeForFriends];
      
      //Fetch and cache players via playerIds
      [SHGameCenter updateCachePlayersFromPlayerIdentifiers:setOfPlayerIds withResponseBlock:^(NSOrderedSet *responseSet, NSError *error) {

        
        attributeForFriends[SHGameCenterSetKey] = [self SH_filterOutFriendsFromPlayers:responseSet
                                                                         withFriendIds:attributeForFriends[SHGameCenterSetKey]];
        
        

        theBlock(@{SHGameCenterAttributeMatchesKey : attributeForMatches,
                   SHGameCenterAttributeFriendsKey : attributeForFriends,
                 });

      } withCachedBlock:nil];
      
      
    }];
  }];
  
}

+(void)SH_requestWithNotificationEnterForegroundBlock:(SHGameNotificationWillEnterForegroundBlock)theWillEnterForegroundBlock
                           matchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock; {
  
  NSAssert(theWillEnterForegroundBlock, @"Must pass a SHGameNotificationWillEnterForegroundBlock");
  SHTurnBasedMatchManager.sharedManager.notificationBlock = theWillEnterForegroundBlock;
  theWillEnterForegroundBlock(SHTurnBasedMatchManager.sharedManager.notificationEnterForeground);
  [self SH_requestMatchesAndFriendsWithBlock:theBlock];
  SHTurnBasedMatchManager.sharedManager.matchesAndFriendsBlock = theBlock;
}

+(void)SH_recursiveRequestMatchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock continuouslyEverySecond:(NSUInteger)theSeconds; {
  if(theSeconds < 3) theSeconds = 2;
  dispatch_async(dispatch_get_main_queue(), ^{
    [self SH_requestMatchesAndFriendsWithBlock:theBlock];
  });
  double delayInSeconds = 2.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
    [self SH_recursiveRequestMatchesAndFriendsWithBlock:theBlock continuouslyEverySecond:theSeconds];
  });
  
}




#pragma mark -
#pragma mark Conditions
-(BOOL)SH_isMyTurn; {
  return [self.currentParticipant SH_isEqual:GKLocalPlayer.SH_me];
}
-(BOOL)SH_hasIncompleteParticipants; {
  return [self.participants any:^BOOL(GKTurnBasedParticipant * participant) {
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

#pragma mark -
#pragma mark Player
-(void)SH_requestPlayersWithBlock:(SHGameListsBlock)theBlock; {
  [SHGameCenter updateCachePlayersFromPlayerIdentifiers:self.SH_playerIdentifiers.set
                                      withResponseBlock:theBlock withCachedBlock:nil];
  
}




#pragma mark -
#pragma mark Equal
-(BOOL)SH_isEqualToMatch:(id)object; {
  BOOL isEqual = NO;
  if([object respondsToSelector:@selector(matchID)])
   isEqual = [self.matchID isEqualToString:((GKTurnBasedMatch *)object).matchID];
  return isEqual;
}

#pragma mark -
#pragma mark Match Getters
+(void)SH_requestMatchesWithBlock:(SHGameListsBlock)theBlock; {
  [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
    NSMutableSet * playerIdentifiers = @[].toSet.mutableCopy;
    [matches each:^(GKTurnBasedMatch * match) {
      [playerIdentifiers addObjectsFromArray:match.SH_playerIdentifiers.array];
    }];
    
    if(error)dispatch_async(dispatch_get_main_queue(), ^{
      theBlock(nil,error);
    });
    else 
      [SHGameCenter updateCachePlayersFromPlayerIdentifiers:playerIdentifiers.copy withResponseBlock:nil withCachedBlock:^(NSError *error){
        theBlock(matches.toOrderedSet, error);
      }];

  }];
}



#pragma mark -
#pragma mark Match Setters
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
#pragma mark -
#pragma mark Helpers
-(NSOrderedSet *)SH_rejectParticipants:(NSSet *)theParticipantsToRject; {
 return [self.participants reject:^BOOL(GKTurnBasedParticipant * participant) {
   return[theParticipantsToRject match:^BOOL(GKTurnBasedParticipant * participantToRemove) {
     return [participant SH_isEqual:participantToRemove];
   }];
  }].toOrderedSet;
}

#pragma mark -
#pragma mark Privates

#pragma mark -
#pragma mark Match Getters
+(void)SH_requestWithoutCacheMatchesWithBlock:(SHGameListsBlock)theBlock; {
  [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      theBlock(matches.toOrderedSet, error);
    });

    
  }];
}

#pragma mark -
#pragma mark Helpers
+(NSSet *)SH_collectPlayerIdsFromAttributeForMatches:(NSDictionary *)theMatchAttributes
                                 attributeForFriends:(NSDictionary *)theFriendAttributes; {
  
  // Collect all playerIDs.
  NSMutableSet * setOfPlayerIds = @[].toSet.mutableCopy;
  [theMatchAttributes[SHGameCenterSetKey] each:^(GKTurnBasedMatch * match) {
    [setOfPlayerIds addObjectsFromArray:match.SH_playerIdentifiers.array];
  }];
  NSOrderedSet * friendsPlayerIds = theFriendAttributes[SHGameCenterSetKey];
  [setOfPlayerIds addObjectsFromArray:friendsPlayerIds.array];
  
  return setOfPlayerIds.copy;
}

+(NSOrderedSet *)SH_filterOutFriendsFromPlayers:(NSOrderedSet *)theSetOfPlayers
                                  withFriendIds:(NSOrderedSet *)theSetOfFriendIds; {
  //Find all players that are friends
  NSOrderedSet * unfilteredFriends = [theSetOfFriendIds map:^id(NSString * playerIdentifier) {
    return [theSetOfPlayers match:^BOOL(GKPlayer * player) {
      return [player.playerID isEqualToString:playerIdentifier];
    }];
  }];
  
  //Get rid  of all NSNulls and set the friendsAttribute
  return [unfilteredFriends reject:^BOOL(id obj) {
    return obj == [NSNull null];
  }];
  
}





@end
