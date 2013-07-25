//
//  SHViewController.m
//  Example
//
//  Created by Seivan Heidari on 4/27/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "SHViewController.h"


@interface SHViewController ()

@end

@implementation SHViewController

-(void)viewDidLoad; {
  [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated; {
  [super viewDidAppear:animated];
}

-(void)didReceiveMemoryWarning;{
  [super didReceiveMemoryWarning];

}

-(void)showAlertWithError:(NSError *)theError; {
  dispatch_async(dispatch_get_main_queue(), ^{

    NSString * title   = theError.localizedDescription;
    NSString * message = theError.localizedRecoverySuggestion;
    NSLog(@"ERROR %@", theError.userInfo);
    NSLog(@"ERROR %@", theError.localizedDescription);
    NSLog(@"ERROR %@", theError.localizedFailureReason);
    NSLog(@"ERROR %@", theError.localizedRecoveryOptions);
    NSLog(@"ERROR %@", theError.localizedRecoverySuggestion);
    
    if(title == nil)   title   = @"Error";
    if(message == nil) message = @"Somethin' ain't right, son.";

    
  });
}



@end
