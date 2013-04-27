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
  [GKLocalPlayer SH_authenticateWithBlock:^(BOOL isAuthenticated, NSError *error) {
    
  } andLoginViewController:^(UIViewController *viewController) {
    
  }];
}
@end