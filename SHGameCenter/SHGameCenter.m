
#import "SHFastEnumerationProtocols.h"
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
+(void)updateCachePlayersFromPlayerIdentifiers:(NSArray *)thePlayerIdentifiers
                             withResponseBlock:(SHGameListsBlock)theResponseBlock
                               withCachedBlock:(SHGameErrorBlock)theCachedBlock; {
  
  NSString * assertMessage = @"Need either responseBlock or cachedBlock";
  
  __block SHGameErrorBlock theCachedBlockOrError = [theCachedBlock copy];
  if(theCachedBlockOrError == nil)
    NSAssert(theResponseBlock, assertMessage);
  if(theResponseBlock == nil)
    NSAssert(theCachedBlockOrError, assertMessage);
  
  
  thePlayerIdentifiers = [thePlayerIdentifiers SH_reject:^BOOL(id obj) { return obj == [NSNull null]; }];
  
  if ([self containsPlayersFromPlayerIdentifiers:thePlayerIdentifiers] && theCachedBlockOrError) {
    dispatch_async(dispatch_get_main_queue(), ^{
      theCachedBlockOrError(nil);
      theCachedBlockOrError = nil;
      
      
    });
    
    
  }
  
  
  [GKPlayer loadPlayersForIdentifiers:thePlayerIdentifiers withCompletionHandler:^(NSArray *players, NSError *error) {
    
    [self addToCacheFromPlayers:players];
    BOOL isCached = [self containsPlayersFromPlayerIdentifiers:thePlayerIdentifiers];
    if (isCached && theResponseBlock) dispatch_async(dispatch_get_main_queue(), ^{
      theResponseBlock(players,error);
    });
    
    else if (isCached && theCachedBlockOrError) dispatch_async(dispatch_get_main_queue(), ^{
      theCachedBlockOrError(error);
    });
    
    
    
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
  return [thePlayerIdentifiers SH_all:^BOOL(NSString * playerIdentifier) {
    return SHGameCenter.sharedManager.cachePlayers[playerIdentifier] != nil;
  }];
  
}

+(void)addToCacheFromPlayers:(NSSet*)thePlayers; {
  
  
  [thePlayers SH_each:^(GKPlayer * player) {
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