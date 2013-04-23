//
//  GKLocalPlayer+SHGameCenter.m
//
//  Created by Seivan Heidari on 4/11/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "NSEnumerable+Utilities.h"
#import <BlocksKit/BlocksKit.h>

#import "SHGameCenter.h"
#import "GKLocalPlayer+SHGameCenter.h"
#import "GKTurnBasedMatch+SHGameCenter.h"
#import "SHPlayerProtocol.h"

@interface SHLocalPlayerManager : NSObject

@property(nonatomic,assign)   BOOL                       moveToGameCenter;
@property(nonatomic,assign)   BOOL                       isAuthenticated;
@property(nonatomic,assign)   NSNotification           * notificationEnterForeground;

@property(nonatomic,copy) SHGameAttributesBlock          matchesAndFriendsBlock;

@property(nonatomic,copy) SHGameNotificationWillEnterForegroundBlock    notificationBlock;


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
    self.notificationEnterForeground = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
      self.notificationEnterForeground = note;
      [GKLocalPlayer SH_requestWithNotificationEnterForegroundBlock:self.notificationBlock matchesAndFriendsWithBlock:self.matchesAndFriendsBlock];
    }];

  }
  
  return self;
}

-(void)dealloc; {
  [NSNotificationCenter.defaultCenter removeObserver:self.notificationEnterForeground];
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
  
  [self.localPlayer setAuthenticateHandler:^(UIViewController * viewController, NSError * error) {
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
#pragma mark Preloaders
+(void)SH_requestMatchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock; {
  NSAssert(theBlock, @"Must pass a SHGameAttributesBlock");
  
  [GKTurnBasedMatch SH_requestMatchesWithBlock:^(NSOrderedSet * list, NSError * error) {
    NSMutableDictionary   * attributeForMatches           = @{}.mutableCopy;
    attributeForMatches[SHGameCenterSetKey]  = list ? list : @[].toOrderedSet;
    if(error)               attributeForMatches[SHGameCenterErrorKey] = error;
    
    [self SH_requestFriendsWithBlock:^(NSOrderedSet * list, NSError * error) {
      NSMutableDictionary * attributeForFriends           = @{}.mutableCopy;
      attributeForFriends[SHGameCenterSetKey]  = list ? list : @[].toOrderedSet;
      if(error)             attributeForFriends[SHGameCenterErrorKey] = error;
      
      NSMutableSet * setOfPlayerIds = @[].toSet.mutableCopy;
      
      [attributeForMatches[SHGameCenterSetKey] each:^(GKTurnBasedMatch * match) {
        [setOfPlayerIds addObjectsFromArray:match.SH_playerIdentifiers.array];
      }];
      
      NSOrderedSet * friendsPlayerIds = [((NSOrderedSet*)attributeForFriends[SHGameCenterSetKey]) map:^id(GKPlayer * player) {
        return player.playerID;
      }];
      [setOfPlayerIds addObjectsFromArray:friendsPlayerIds.array];
      
      [SHGameCenter updateCachePlayersFromPlayerIdentifiers:setOfPlayerIds.copy withCompletionBlock:^{
        theBlock(@{SHGameCenterAttributeMatchesKey : attributeForMatches,
                 SHGameCenterAttributeFriendsKey : attributeForFriends,
                 });
        


      }];
      
      
    }];
  }];

}

+(void)SH_requestWithNotificationEnterForegroundBlock:(SHGameNotificationWillEnterForegroundBlock)theWillEnterForegroundBlock
                           matchesAndFriendsWithBlock:(SHGameAttributesBlock)theBlock; {
  
  NSAssert(theWillEnterForegroundBlock, @"Must pass a SHGameNotificationWillEnterForegroundBlock");
  SHLocalPlayerManager.sharedManager.notificationBlock = theWillEnterForegroundBlock;
  theWillEnterForegroundBlock(SHLocalPlayerManager.sharedManager.notificationEnterForeground);
  [self SH_requestMatchesAndFriendsWithBlock:theBlock];
  SHLocalPlayerManager.sharedManager.matchesAndFriendsBlock = theBlock;
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

#pragma mark -
#pragma mark Equal <SHPlayerProtocol>
-(BOOL)isEqualToParticipant:(id)object; {
  BOOL isEqual = NO;
  if([object respondsToSelector:@selector(playerID)])
    isEqual = [self.playerID isEqualToString:((id<SHPlayerProtocol>)object).playerID];
  else
    isEqual = [super isEqual:object];
  return isEqual;
}

-(BOOL)isEqualToPlayer:(id)object; {
  return [self isEqualToPlayer:object];
}


@end
