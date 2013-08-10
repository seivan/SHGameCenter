
#import "GKPlayer+SHGameCenter.h"

#import "SHGameCenter.h"

#include "SHGameCenter.private"

@implementation GKPlayer (SHGameCenter)

#pragma mark - Getter
-(UIImage *)SH_photo; {
  return [SHGameCenter photoForPlayerId:self.playerID];
}



#pragma mark - Equal
#pragma mark -
#pragma mark <SHPlayable>
#include "SHPlayable.implementation"



@end
