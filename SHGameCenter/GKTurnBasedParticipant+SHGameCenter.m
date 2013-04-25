
#import "GKTurnBasedParticipant+SHGameCenter.h"

#include "SHGameCenter.privates"

@implementation GKTurnBasedParticipant (SHGameCenter)
#pragma mark -
#pragma mark Getter
-(NSString *)SH_alias; {
  return [SHGameCenter aliasForPlayerId:self.playerID];
}

-(UIImage *)SH_photo; {
  return [SHGameCenter photoForPlayerId:self.playerID];
}


#pragma mark -
#pragma mark Conditions
-(BOOL)SH_isMe; {
  return [self SH_isEqual:GKLocalPlayer.SH_me];
}
#pragma mark -
#pragma mark GKTurnBasedParticipantStatus

-(BOOL)SH_isActiveOrInvited; {
  return self.SH_isActive || self.SH_isInvited || self.SH_isMatching;
}
-(BOOL)SH_isInvited; {
  return self.status == GKTurnBasedParticipantStatusInvited;
}
-(BOOL)SH_isActive; {
  return self.status == GKTurnBasedParticipantStatusActive;
}
-(BOOL)SH_isMatching; {
  return self.status == GKTurnBasedParticipantStatusMatching;
}

-(BOOL)SH_isDone; {
  return self.status == GKTurnBasedParticipantStatusDone;
}


#pragma mark -
#pragma mark GKTurnBasedMatchOutcome
-(BOOL)SH_hasMatchOutcomeNone; {
  return self.matchOutcome == SHTurnBasedMatchOutcomeNone;
}

-(BOOL)SH_hasMatchOutcomeQuit; {
  return self.matchOutcome = SHTurnBasedMatchOutcomeQuit;
}

-(BOOL)SH_hasMatchOutcomeWon; {
  return self.matchOutcome = SHTurnBasedMatchOutcomeWon;
}
-(BOOL)SH_hasMatchOutcomeWithPosition {
  return self.matchOutcome >= SHTurnBasedMatchOutcomeFirst
  && self.matchOutcome <= SHTurnBasedMatchOutcomeTwelvth;
}

#pragma mark -
#pragma mark Equal

#pragma mark -
#pragma mark <SHPlayerProtocol>
#include "SHPlayerProtocol.implementation"

@end
