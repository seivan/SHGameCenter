//
//  GKPlayer+SHGameCenter.m
//
//  Created by Seivan Heidari on 4/23/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "GKPlayer+SHGameCenter.h"
#import "SHGameCenter.h"
@implementation GKPlayer (SHGameCenter)
-(UIImage *)SH_photo; {
  return [SHGameCenter photoForPlayerId:self.playerID];
}
@end
