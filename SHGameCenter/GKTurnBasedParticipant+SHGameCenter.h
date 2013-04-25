
#import "SHPlayerProtocol.h"

#import "SHGameCenterBlockDefinitions.h"

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

  
  SHTurnBasedMatchOutcomeCustomRange = 0x00FF0000	// game result range available for custom app use
  
};
typedef NSInteger SHTurnBasedMatchOutcome;


@interface GKTurnBasedParticipant (SHGameCenter)
<SHPlayerProtocol>

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

@end
