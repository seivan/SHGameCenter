//
//  SHGameCenter.m
//
//  Created by Seivan Heidari on 4/11/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "NSEnumerable+Utilities.h"
#import <BlocksKit/BlocksKit.h>


#import "SHGameCenter.h"

static NSString * const SHGameMatchEventTurnKey     = @"SHGameMatchEventTurnKey";
static NSString * const SHGameMatchEventEndedKey    = @"SHGameMatchEventEndedKey";
static NSString * const SHGameMatchEventInvitesKey  = @"SHGameMatchEventInvitesKey";

@interface SHGameCenter ()
<GKTurnBasedEventHandlerDelegate>
@property(nonatomic,strong) NSMapTable          * mapBlocks;
@property(nonatomic,strong) NSMutableDictionary * cachePlayers;

#pragma mark -
#pragma mark Singleton Methods
+(instancetype)sharedManager;
#pragma mark -
#pragma mark Cache
+(void)updateCachePlayersFromMatch:(GKTurnBasedMatch *)theMatch
              withCompletionBlock:(SHGameCompletionBlock)theBlock;

+(BOOL)containsPlayersFromMatch:(GKTurnBasedMatch *)theMatch;
+(BOOL)containsPlayersFromPlayerIdentifiers:(NSSet *)thePlayerIdentifiers;

@end

@implementation SHGameCenter

#pragma mark -
#pragma mark Observer
+(void)setObserver:(id)theObserver
matchEventTurnBlock:(SHGameMatchEventTurnBlock)theMatchEventTurnBlock
matchEventEndedBlock:(SHGameMatchEventEndedBlock)theMatchEventEndedBlock
matchEventInvitesBlock:(SHGameMatchEventInvitesBlock)theMatchEventInvitesBlock; {
  
  NSAssert(theObserver, @"Must pass an observer!");
  
  NSMutableDictionary * blocks = @{}.mutableCopy;
  
  if(theMatchEventTurnBlock)    blocks[SHGameMatchEventTurnKey]    = [theMatchEventTurnBlock copy];
  if(theMatchEventEndedBlock)   blocks[SHGameMatchEventEndedKey]   = [theMatchEventEndedBlock copy];
  if(theMatchEventInvitesBlock) blocks[SHGameMatchEventInvitesKey] = [theMatchEventInvitesBlock copy];
  
  [SHGameCenter.sharedManager.mapBlocks setObject:blocks.copy forKey:theObserver];
  
}

#pragma mark -
#pragma mark Cache
+(void)updateCachePlayersFromPlayerIdentifiers:(NSSet *)thePlayerIdentifiers
                           withCompletionBlock:(SHGameCompletionBlock)theBlock; {
  if ([self containsPlayersFromPlayerIdentifiers:thePlayerIdentifiers]) theBlock();
  
  [GKPlayer loadPlayersForIdentifiers:thePlayerIdentifiers.allObjects withCompletionHandler:^(NSArray *players, NSError *error) {
    
    if(error) [self updateCachePlayersFromPlayerIdentifiers:thePlayerIdentifiers withCompletionBlock:theBlock];
    
    else {
      [self addToCacheFromPlayers:players.toSet];
      if ([self containsPlayersFromPlayerIdentifiers:thePlayerIdentifiers])
        theBlock();
      else
        [self updateCachePlayersFromPlayerIdentifiers:thePlayerIdentifiers
                                  withCompletionBlock:theBlock];
    }
    
  }];

}


#pragma mark -
#pragma mark Getters

+(NSString *)aliasForPlayerId:(NSString *)thePlayerId; {
  NSAssert(thePlayerId, @"Must pass an playerID");
  return SHGameCenter.sharedManager.cachePlayers[thePlayerId][@"alias"];
}

+(UIImage *)photoForPlayerId:(NSString *)thePlayerId; {
  NSAssert(thePlayerId, @"Must pass an playerID");
  return SHGameCenter.sharedManager.cachePlayers[thePlayerId][@"photo"];
}


#pragma mark -
#pragma mark Privates
#pragma mark -
#pragma mark Cache
+(void)updateCachePlayersFromMatch:(GKTurnBasedMatch *)theMatch
               withCompletionBlock:(void (^)(void))theBlock; {
  
  [self updateCachePlayersFromPlayerIdentifiers:theMatch.SH_playerIdentifiers.set withCompletionBlock:theBlock];  
}

+(BOOL)containsPlayersFromMatch:(GKTurnBasedMatch *)theMatch; {
  return [self containsPlayersFromPlayerIdentifiers:theMatch.SH_playerIdentifiers.set];
}

+(BOOL)containsPlayersFromPlayerIdentifiers:(NSSet *)thePlayerIdentifiers; {
  return [thePlayerIdentifiers all:^BOOL(NSString * playerIdentifier) {
    return SHGameCenter.sharedManager.cachePlayers[playerIdentifier] != nil;
  }];

}

+(void)addToCacheFromPlayers:(NSSet*)thePlayers; {

  
  [thePlayers each:^(GKPlayer * player) {
    NSMutableDictionary * playerAttributes = SHGameCenter.sharedManager.cachePlayers[player.playerID];
    
    if(playerAttributes == nil) playerAttributes = @{}.mutableCopy;
    
    playerAttributes[@"alias"] = player.alias;
    SHGameCenter.sharedManager.cachePlayers[player.playerID] = playerAttributes;
    
    if(playerAttributes[@"photo"] == nil )
      [player loadPhotoForSize:GKPhotoSizeSmall
         withCompletionHandler:^(UIImage *photo, NSError *error) {
           if(photo){
             playerAttributes[@"photo"] = photo;
             SHGameCenter.sharedManager.cachePlayers[player.playerID] = playerAttributes;
           }
      }];
    
  }];

  
}


#pragma mark -
#pragma mark Init & Dealloc
-(instancetype)init; {
  self = [super init];
  if (self) {
    GKTurnBasedEventHandler.sharedTurnBasedEventHandler.delegate = self;

    self.mapBlocks    = [NSMapTable weakToStrongObjectsMapTable];
    self.cachePlayers = @{}.mutableCopy;
  }
  
  return self;
}

+(instancetype)sharedManager; {
  static SHGameCenter *_sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[SHGameCenter alloc] init];
    
  });
  
  return _sharedInstance;
  
}


#pragma mark -
#pragma mark <GKTurnBasedEventHandlerDelegate>
-(void)handleInviteFromGameCenter:(NSArray *)playersToInvite; {
  for (NSDictionary * blocks in self.mapBlocks.objectEnumerator) {
    SHGameMatchEventInvitesBlock block = blocks[SHGameMatchEventInvitesKey];
    block(playersToInvite.toOrderedSet);
  }

}

-(void)handleTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive; {
  [SHGameCenter updateCachePlayersFromMatch:match withCompletionBlock:^{
    for (NSDictionary * blocks in self.mapBlocks.objectEnumerator) {
      SHGameMatchEventTurnBlock block = blocks[SHGameMatchEventTurnKey];
      block(match, didBecomeActive);
    }
  }];

  
}

// handleMatchEnded is called when the match has ended.
-(void)handleMatchEnded:(GKTurnBasedMatch *)match; {
  [SHGameCenter updateCachePlayersFromMatch:match withCompletionBlock:^{
    for (NSDictionary * blocks in self.mapBlocks.objectEnumerator) {
      SHGameMatchEventEndedBlock block = blocks[SHGameMatchEventEndedKey];
      block(match);
    }
  }];
  
}


@end