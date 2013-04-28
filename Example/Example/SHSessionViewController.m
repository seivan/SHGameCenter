//
//  SHSessionViewController.m
//  Example
//
//  Created by Seivan Heidari on 4/27/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "SHSessionViewController.h"

@interface SHSessionViewController ()
@end

@implementation SHSessionViewController
-(void)viewDidAppear:(BOOL)animated; {
  [super viewDidAppear:animated];
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
}




@end