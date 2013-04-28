# SHGameCenter - Patterns and convenience selectors with blocks for Game Center

SHGameCenter extends [`GameKit`](http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/GameKit_Guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008304-CH1-SW1)
to add some convenience methods and move the delegate pattern over to blocks that can be used over multiple places. For instance update your list of matches as well as update your currente match. 


## Adding to your project

Add the following to your [`Podfile`](http://docs.cocoapods.org/podfile.html)
and run `pod install`

```
pod 'SHGameCenter'
```

Don't forget to `#import "SHGameCenter.h"` in your prefix file or where it's needed. 

## Login

```objective-c
  __weak SHSessionViewController * blockSelf = self;
  [GKLocalPlayer SH_authenticateLoggedInBlock:^{
    [blockSelf performSegueWithIdentifier:@"SHLoggedIn" sender:self];
  } loggedOutBlock:^{
    [blockSelf dismissViewControllerAnimated:NO completion:nil];
  } withErrorBlock:^(NSError *error) {
    [blockSelf showAlertWithError:error];
  } withLoginViewController:^(UIViewController *viewController) {
    [blockSelf presentViewController:viewController animated:YES completion:nil];
  }];

```

## Fetching Friends (GKPlayer) and Matches (GKTurnBasedMatch) in one go

```objective-c
   __weak MyController * blockSelf = self;
  [GKTurnBasedMatch SH_requestWithNotificationEnterForegroundBlock:^(NSNotification *notification) {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
  } matchesAndFriendsWithBlock:^(NSDictionary *attributes) {
      blockSelf.orderedSetsOfMatches = ((NSOrderedSet*)attributes[SHGameCenterAttributeMatchesKey][SHGameCenterSetKey]).mutableCopy;
      blockSelf.orderedSetsOfFriends = ((NSOrderedSet*)attributes[SHGameCenterAttributeFriendsKey][SHGameCenterSetKey]).mutableCopy;
      [blockSelf reloadData];
      [SVProgressHUD dismiss];
  }];

```

## Keeping track of new and current Match (GKTurnBasedMatch) events  - no need to clean up after observer, self maintained

```objective-c
        __weak MyController * blockSelf = self;
      [GKTurnBasedMatch SH_setObserver:self matchEventTurnBlock:^(GKTurnBasedMatch *match, BOOL didBecomeActive) {
        [blockSelf updateMatch:match];
      } matchEventEndedBlock:^(GKTurnBasedMatch *match) {
      [blockSelf endMatch:match];
      } matchEventInvitesBlock:^(NSOrderedSet *playersToInvite){
      [blockSelf pushMatchWithPlayers:playersToInvite];
      }];

```

## And a ton of convenience properties and selectors on your favourite classes all prefixed with SH_

## License

SHGameCenter is © 2013 [Seivan](http://www.github.com/seivan) and may be freely
distributed under the [MIT license](http://opensource.org/licenses/MIT).
See the [`LICENSE.md`](https://github.com/seivan/SHGameCenter/blob/master/LICENSE.md) file.
