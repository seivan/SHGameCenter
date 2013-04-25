
#import "SHPlayerProtocol.h"
#import "SHGameCenterBlockDefinitions.h"

@interface GKPlayer (SHGameCenter)
<SHPlayerProtocol>
#pragma mark -
#pragma mark Getter

@property(nonatomic,readonly) UIImage * SH_photo;
@end
