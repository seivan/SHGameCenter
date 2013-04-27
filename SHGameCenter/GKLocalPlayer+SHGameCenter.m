#import "NSEnumerable+Utilities.h"

#import "NSOrderedSet+BlocksKit.h"

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



@implementation GKLocalPlayer (SHGameCenter)
#pragma mark -
#pragma mark Authentication
+(void)SH_authenticateWithBlock:(SHGameAuthenticationBlock)theBlock
                     andLoginViewController:(void(^)(UIViewController * viewController))loginViewControllerHandler; {
  if(SHLocalPlayerManager.sharedManager.moveToGameCenter == YES) {
    SHLocalPlayerManager.sharedManager.moveToGameCenter = NO;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:/me"]];
  }
  
  [self.SH_me setAuthenticateHandler:^(UIViewController * viewController, NSError * error) {
    if(viewController) {
      SHLocalPlayerManager.sharedManager.isAuthenticated = self.SH_me.isAuthenticated;
      loginViewControllerHandler(viewController);
    }
    else if([error.domain isEqualToString:GKErrorDomain] && error.code == 2 && SHLocalPlayerManager.sharedManager.moveToGameCenter == NO) {
      SHLocalPlayerManager.sharedManager.isAuthenticated = self.SH_me.isAuthenticated;
      SHLocalPlayerManager.sharedManager.moveToGameCenter = YES;
    }
    else if (error && error.code != 2) {

      SHLocalPlayerManager.sharedManager.isAuthenticated = self.SH_me.isAuthenticated;
      theBlock(GKLocalPlayer.localPlayer.isAuthenticated,error);
    }
    else {
      if(self.SH_me.isAuthenticated != SHLocalPlayerManager.sharedManager.isAuthenticated) theBlock(self.SH_me.isAuthenticated,nil);
      SHLocalPlayerManager.sharedManager.isAuthenticated = self.SH_me.isAuthenticated;
      
    }
    
  }];
}


#pragma mark -
#pragma mark Player Getters
+(GKLocalPlayer *)SH_me; {
  return self.localPlayer.isAuthenticated ? self.localPlayer : nil;
}

+(void)SH_requestFriendsWithBlock:(SHGameListsBlock)theBlock; {
  [self.SH_me loadFriendsWithCompletionHandler:^(NSArray * friends, NSError * error) {
    [self loadPlayersForIdentifiers:friends
                  withCompletionHandler:^(NSArray *players, NSError *error) {
                    theBlock(players.toOrderedSet, error);
                  }];
  }];

}



@end
