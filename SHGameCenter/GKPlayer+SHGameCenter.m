
#import "GKPlayer+SHGameCenter.h"

#import "SHGameCenter.h"

#include "SHGameCenter.private"

@implementation GKPlayer (SHGameCenter)
#pragma mark -
#pragma mark Getter

-(UIImage *)SH_photo; {
  return [SHGameCenter photoForPlayerId:self.playerID];
}


#pragma mark -
#pragma mark Equal

#pragma mark -
#pragma mark <SHPlayerProtocol>
#include "SHPlayerProtocol.implementation"


@end
