
## Login

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



SHGameCenter is © 2013 [Seivan](http://www.github.com/seivan) and may be freely
distributed under the [MIT license](http://opensource.org/licenses/MIT).
See the [`LICENSE.md`](https://github.com/seivan/SHGameCenter/blob/master/LICENSE.md) file.
