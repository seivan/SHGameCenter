

#import "NSOrderedSet+SHFastEnumerationProtocols.h"
#import "NSArray+SHFastEnumerationProtocols.h"
#import "GKLocalPlayer+SHGameCenter.h"

#include "SHGameCenter.private"

@interface SHLocalPlayerManager : NSObject

@property(nonatomic,assign)   BOOL                       moveToGameCenter;
@property(nonatomic,assign)   BOOL                       isAuthenticated;


#pragma mark -
#pragma mark Singleton Methods
+(instancetype)sharedManager;
@end

@implementation SHLocalPlayerManager

#pragma mark -
#pragma mark Privates

#pragma mark -
#pragma mark Init & Dealloc
-(instancetype)init; {
  self = [super init];
  if (self) {
    self.isAuthenticated = NO;

  }
  
  return self;
}

+(instancetype)sharedManager; {
  static SHLocalPlayerManager *_sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[SHLocalPlayerManager alloc] init];
  });
  
  return _sharedInstance;
  
}


@end

@interface GKLocalPlayer(Privates)
#pragma mark -
#pragma mark Player Getters
+(void)SH_requestWithoutCacheFriendsWithBlock:(SHGameListsBlock)theBlock;
@end

@implementation GKLocalPlayer (SHGameCenter)
#pragma mark -
#pragma mark Authentication
+(void)SH_authenticateWithLoginViewControllerBlock:(SHGameViewControllerBlock)theLoginViewControllerBlock
                                     didLoginBlock:(SHGameCompletionBlock)theLoginBlock
                                    didLogoutBlock:(SHGameCompletionBlock)theLogoutBlock
                                    withErrorBlock:(SHGameErrorBlock)theErrorBlock; {

  if(SHLocalPlayerManager.sharedManager.moveToGameCenter == YES) {
    SHLocalPlayerManager.sharedManager.moveToGameCenter = NO;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:/me"]];
  }
  
  [self.SH_me setAuthenticateHandler:^(UIViewController * viewController, NSError * error) {
    if(viewController) {
      if(SHLocalPlayerManager.sharedManager.isAuthenticated)
        theLogoutBlock();
      SHLocalPlayerManager.sharedManager.isAuthenticated = self.SH_me.isAuthenticated;
      theLoginViewControllerBlock(viewController);
    }
    else if([error.domain isEqualToString:GKErrorDomain]
            && error.code == GKErrorCancelled
            && SHLocalPlayerManager.sharedManager.moveToGameCenter == NO) {
      if(SHLocalPlayerManager.sharedManager.isAuthenticated)
        theLogoutBlock();

      SHLocalPlayerManager.sharedManager.isAuthenticated = self.SH_me.isAuthenticated;
      SHLocalPlayerManager.sharedManager.moveToGameCenter = YES;
    }
    else if (error && error.code != GKErrorCancelled) {
      if(SHLocalPlayerManager.sharedManager.isAuthenticated)
        theLogoutBlock();
      SHLocalPlayerManager.sharedManager.isAuthenticated = self.SH_me.isAuthenticated;
      theErrorBlock(error);
    }
    else {
      if(self.SH_me.isAuthenticated != SHLocalPlayerManager.sharedManager.isAuthenticated)
        theLoginBlock();
      
      SHLocalPlayerManager.sharedManager.isAuthenticated = self.SH_me.isAuthenticated;
      
    }
  }];
  
}

#pragma mark -
#pragma mark Player Getters
+(GKLocalPlayer *)SH_me; {
  return self.localPlayer;
}

+(void)SH_requestFriendsWithBlock:(SHGameListsBlock)theBlock; {
  [self.SH_me loadFriendsWithCompletionHandler:^(NSArray *friends, NSError *error) {
    if(error) dispatch_async(dispatch_get_main_queue(), ^{
      theBlock(nil,error);
    });
    else
      [SHGameCenter updateCachePlayersFromPlayerIdentifiers:friends
                                          withResponseBlock:theBlock withCachedBlock:nil];
    
  }];

}

#pragma mark -
#pragma mark Privates
#pragma mark -
#pragma mark Player Getters
+(void)SH_requestWithoutCacheFriendsWithBlock:(SHGameListsBlock)theBlock; {
  [self.SH_me loadFriendsWithCompletionHandler:^(NSArray * friends, NSError * error) {
    [self loadPlayersForIdentifiers:friends
              withCompletionHandler:^(NSArray *players, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  theBlock(players, error);
                });
                
              }];
  }];
  
}


@end
