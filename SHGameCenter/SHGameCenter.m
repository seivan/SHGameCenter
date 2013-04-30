#import "NSEnumerable+Utilities.h"
#import "NSSet+BlocksKit.h"
#import "SHGameCenter.h"

#include "SHGameCenter.private"

static NSString * const SHGameMatchEventTurnKey     = @"SHGameMatchEventTurnKey";
static NSString * const SHGameMatchEventEndedKey    = @"SHGameMatchEventEndedKey";
static NSString * const SHGameMatchEventInvitesKey  = @"SHGameMatchEventInvitesKey";

@interface SHGameCenter ()
@property(nonatomic,strong) NSMapTable          * mapBlocks;
@property(nonatomic,strong) NSMutableDictionary * cachePlayers;

#pragma mark -
#pragma mark Singleton Methods
+(instancetype)sharedManager;
@end


@implementation SHGameCenter
#pragma mark -
#pragma mark Init & Dealloc
-(instancetype)init; {
  self = [super init];
  if (self) {
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
#pragma mark Cache
//Need to clean this mess up
+(void)updateCachePlayersFromPlayerIdentifiers:(NSSet *)thePlayerIdentifiers
                           withCompletionBlock:(SHGameCompletionBlock)theBlock; {

  thePlayerIdentifiers = [thePlayerIdentifiers reject:^BOOL(id obj) { return obj == [NSNull null]; }];
  
  if ([self containsPlayersFromPlayerIdentifiers:thePlayerIdentifiers]) {
    theBlock();
    theBlock = nil;
  }
  
  
  [GKPlayer loadPlayersForIdentifiers:thePlayerIdentifiers.allObjects withCompletionHandler:^(NSArray *players, NSError *error) {
    
    if(error)
      [self updateCachePlayersFromPlayerIdentifiers:thePlayerIdentifiers withCompletionBlock:theBlock];
    
    else {
      [self addToCacheFromPlayers:players.toSet];
      if ([self containsPlayersFromPlayerIdentifiers:thePlayerIdentifiers]) {
        if(theBlock) theBlock();
      }
      else
        [self updateCachePlayersFromPlayerIdentifiers:thePlayerIdentifiers
                                  withCompletionBlock:theBlock];
    }
    
  }];

}


#pragma mark -
#pragma mark Getters

+(NSString *)aliasForPlayerId:(NSString *)thePlayerId; {
//  NSAssert(thePlayerId, @"Must pass an playerID");
  return SHGameCenter.sharedManager.cachePlayers[thePlayerId][@"alias"];
}

+(UIImage *)photoForPlayerId:(NSString *)thePlayerId; {
//  NSAssert(thePlayerId, @"Must pass an playerID");
  return SHGameCenter.sharedManager.cachePlayers[thePlayerId][@"photo"];
}


#pragma mark -
#pragma mark Privates
#pragma mark -
#pragma mark Cache

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




@end