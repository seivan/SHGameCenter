# SHGameCenter

[![Version](http://cocoapod-badges.herokuapp.com/v/SHGameCenter/badge.png)](http://cocoadocs.org/docsets/SHGameCenter)
[![Platform](http://cocoapod-badges.herokuapp.com/p/SHGameCenter/badge.png)](http://cocoadocs.org/docsets/SHGameCenter)


##### Prefixed category convenience selectors on the GameKit framework, also adding blocks instead of delegate calls.


`SHGameCenter` adds class or instance observers on GKTurnBasedMatch for handling matches.
Also authenticate state observers. It deals with caching images as well as display names. Takes of everything!


> This pod is part of many components covering to plug the holes missing from Foundation, UIKit, CoreLocation, GameKit, MapKit and other aspects of an iOS application's architecture. 

- [SHUIKitBlocks](https://github.com/seivan/SHUIKitBlocks)
- [SHFoundationAdditions](https://github.com/seivan/SHFoundationAdditions)
- [SHTestCaseAdditions](https://github.com/seivan/SHTestCaseAdditions)
- [SHMessageUIBlocks](https://github.com/seivan/SHMessageUIBlocks)

##Install
```ruby
pod 'SHGameCenter'
```

##Dependency Status

| Library        | Tests           | Version  | Platform  |
| ------------- |:-------------:| -----:|  -----:| 
| [SHFastEnumerationProtocols](https://github.com/seivan/SHFastEnumerationProtocols)| [![Build Status](https://travis-ci.org/seivan/SHFastEnumerationProtocols.png?branch=master)](https://travis-ci.org/seivan/SHFastEnumerationProtocols)| [![Version](http://cocoapod-badges.herokuapp.com/v/SHFastEnumerationProtocols/badge.png)](http://cocoadocs.org/docsets/SHFastEnumerationProtocols) | [![Platform](http://cocoapod-badges.herokuapp.com/p/SHFastEnumerationProtocols/badge.png)](http://cocoadocs.org/docsets/SHFastEnumerationProtocols) |

## GKLocalPlayer <SHPlayable>

###Api

```objective-c
#pragma mark - Authentication
//handles on foreground notifications
+(void)SH_authenticateWithLoginViewControllerBlock:(SHGameViewControllerBlock)theLoginViewControllerBlock
                                     didLoginBlock:(SHGameCompletionBlock)theLoginBlock
                                    didLogoutBlock:(SHGameCompletionBlock)theLogoutBlock
                                    withErrorBlock:(SHGameErrorBlock)theErrorBlock;

#pragma mark - Properties
#pragma mark - Player Getters
+(GKLocalPlayer *)SH_me;
+(void)SH_requestFriendsWithBlock:(SHGameListsBlock)theBlock;

```
###Usage 
```objective-c
  __weak SHSessionViewController * blockSelf = self;
  [GKLocalPlayer SH_authenticateWithLoginViewControllerBlock:^(UIViewController *viewController) {
    [blockSelf presentViewController:viewController animated:YES completion:nil];
  } didLoginBlock:^{
    [blockSelf performSegueWithIdentifier:@"SHLoggedIn" sender:self];
  } didLogoutBlock:^{
    [blockSelf dismissViewControllerAnimated:NO completion:nil];
  } withErrorBlock:^(NSError *error) {
    [blockSelf showAlertWithError:error];
  }];

```

## GKPlayer <SHPlayable>

###Api

```objective-c
#pragma mark - Getter
@property(nonatomic,readonly) UIImage * SH_photo;

```

##GKTurnBasedMatch

###Api

```objective-c
#pragma mark - Participant Getters
@property(nonatomic,readonly) GKTurnBasedParticipant  * SH_meAsParticipant;
@property(nonatomic,readonly) NSArray                 * SH_participantsWithoutMe;
@property(nonatomic,readonly) NSArray                 * SH_participantsWithoutCurrent;
@property(nonatomic,readonly) NSArray                 * SH_participantsNextOrder;
@property(nonatomic,readonly) NSArray                 * SH_playerIdentifiers;


#pragma mark - Conditions
@property(nonatomic,readonly) BOOL SH_isMyTurn;
//Participants who are neither active nor invited - e.g done, declined and etc
@property(nonatomic,readonly) BOOL SH_hasIncompleteParticipants;

@property(nonatomic,readonly) BOOL SH_isMatchStatusOpen;
@property(nonatomic,readonly) BOOL SH_isMatchStatusMatching;
@property(nonatomic,readonly) BOOL SH_isMatchStatusEnded;
@property(nonatomic,readonly) BOOL SH_isMatchStatusUnknown;



#pragma mark - Observer
-(void)SH_setObserver:(id)theObserver
  matchEventTurnBlock:(SHGameMatchEventTurnBlock)theMatchEventTurnBlock
 matchEventEndedBlock:(SHGameMatchEventEndedBlock)theMatchEventEndedBlock;

+(void)SH_setObserver:(id)theObserver
matchEventTurnBlock:(SHGameMatchEventTurnBlock)theMatchEventTurnBlock
matchEventEndedBlock:(SHGameMatchEventEndedBlock)theMatchEventEndedBlock
matchEventInvitesBlock:(SHGameMatchEventInvitesBlock)theMatchEventInvitesBlock;



#pragma mark - Preloaders

+(void)SH_requestMatchesWithBlock:(SHGameListsBlock)theMatchesBlock
              andFriendsWithBlock:(SHGameListsBlock)theFriendsBlock
              withCompletionBlock:(SHGameCompletionBlock)theCompletionBlock;


#pragma mark - Player
-(void)SH_requestPlayersWithBlock:(SHGameListsBlock)theBlock;


#pragma mark - Equal
-(BOOL)SH_isEqualToMatch:(id)object;


#pragma mark - Match Getters
+(void)SH_requestMatchesWithBlock:(SHGameListsBlock)theBlock;




#pragma mark - Match Setters
-(void)SH_resignWithBlock:(SHGameMatchBlock)theBlock;

-(void)SH_deleteWithBlock:(SHGameMatchBlock)theBlock;

```

###Usage 

#### Instance
```objective-c
  __weak TELMatchShowViewController *blockSelf = self;
  [self.match SH_setObserver:self matchEventTurnBlock:^(GKTurnBasedMatch *match, BOOL didBecomeActive) {
    [blockSelf handleTurnEventForMatch:match didBecomeActive:didBecomeActive];
    
  } matchEventEndedBlock:^(GKTurnBasedMatch *match) {
    blockSelf.txtView.text = @"ENDED";
  }];
```

#### Class

```objective-c
  [GKTurnBasedMatch SH_setObserver:self matchEventTurnBlock:^(GKTurnBasedMatch *match, BOOL didBecomeActive) {
    
    
    BOOL isInList = [self.orderedSetsOfMatches containsObject:match];
    
    if(isInList)
      [self.orderedSetsOfMatches replaceObjectAtIndex:[self.orderedSetsOfMatches
                                                       indexOfObject:match]
                                           withObject:match];
    else
      [self.orderedSetsOfMatches addObject:match];

    
    NSArray * indexPaths = @[[NSIndexPath
                              indexPathForRow:[self.orderedSetsOfMatches indexOfObject:match]
                              inSection:0]];
    
    if(self.currentSelectedOrderedSet == self.orderedSetsOfMatches)
      [self.viewCollection performBatchUpdates:^{
        if(isInList)
          [self.viewCollection reloadItemsAtIndexPaths:indexPaths];
        else
          [self.viewCollection insertItemsAtIndexPaths:indexPaths];
      } completion:nil];

  } matchEventEndedBlock:^(GKTurnBasedMatch *match) {
    
  } matchEventInvitesBlock:^(NSArray *playersToInvite) {

  }];

```

##GKTurnBasedParticipant <SHPlayable>

###Api
```objective-c
enum {
  SHTurnBasedMatchOutcomeNone         = 0,        // Participants who are not done with a match have this state
  SHTurnBasedMatchOutcomeQuit         = 1,        // Participant quit
  SHTurnBasedMatchOutcomeWon          = 2,        // Participant won
  SHTurnBasedMatchOutcomeLost         = 3,        // Participant lost
  SHTurnBasedMatchOutcomeTied         = 4,        // Participant tied
  SHTurnBasedMatchOutcomeTimeExpired  = 5,        // Game ended due to time running out
  SHTurnBasedMatchOutcomeFirst        = 6,
  SHTurnBasedMatchOutcomeSecond       = 7,
  SHTurnBasedMatchOutcomeThird        = 8,
  SHTurnBasedMatchOutcomeFourth       = 9,
  SHTurnBasedMatchOutcomeFifth        = 10,
  SHTurnBasedMatchOutcomeSixth        = 11,
  SHTurnBasedMatchOutcomeSeventh      = 12,
  SHTurnBasedMatchOutcomeEighth       = 13,
  SHTurnBasedMatchOutcomeNinth        = 14,
  SHTurnBasedMatchOutcomeTenth        = 16,
  SHTurnBasedMatchOutcomeEleventh     = 17,
  SHTurnBasedMatchOutcomeTwelvth      = 18,

  
  SHTurnBasedMatchOutcomeCustomRange = 0x00FF0000 // game result range available for custom app use
  
};
typedef NSInteger SHTurnBasedMatchOutcome;


#pragma mark -
#pragma mark Getter
@property(nonatomic,readonly) NSString * SH_alias;
@property(nonatomic,readonly) UIImage  * SH_photo;

#pragma mark -
#pragma mark Conditions
@property(nonatomic,readonly) BOOL SH_isMe;

#pragma mark -
#pragma mark GKTurnBasedParticipantStatus
@property(nonatomic,readonly) BOOL SH_isActiveOrInvited;
@property(nonatomic,readonly) BOOL SH_isInvited;
@property(nonatomic,readonly) BOOL SH_isActive;
@property(nonatomic,readonly) BOOL SH_isMatching;
@property(nonatomic,readonly) BOOL SH_isDone;

#pragma mark -
#pragma mark GKTurnBasedMatchOutcome
@property(nonatomic,readonly) BOOL SH_hasMatchOutcomeNone;
@property(nonatomic,readonly) BOOL SH_hasMatchOutcomeQuit;
@property(nonatomic,readonly) BOOL SH_hasMatchOutcomeWon;
@property(nonatomic,readonly) BOOL SH_hasMatchOutcomeWithPosition;

```


SHGameCenter is © 2013 [Seivan](http://www.github.com/seivan) and may be freely
distributed under the [MIT license](http://opensource.org/licenses/MIT).
See the [`LICENSE.md`](https://github.com/seivan/SHGameCenter/blob/master/LICENSE.md) file.
