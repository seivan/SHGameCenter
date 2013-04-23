//
//  GKTurnBasedParticipant+SHGameCenter.m
//
//  Created by Seivan Heidari on 4/11/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//
#import "SHGameCenter.h"

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
  return [self.playerID isEqualToString:GKLocalPlayer.SH_me.playerID];
}
#pragma mark -
#pragma mark GKTurnBasedParticipantStatus

-(BOOL)SH_isActiveOrInvited; {
  return self.SH_isActive || self.SH_isInvited;
}
-(BOOL)SH_isInvited; {
  return self.status == GKTurnBasedParticipantStatusInvited;
}
-(BOOL)SH_isActive; {
  return self.status == GKTurnBasedParticipantStatusActive;
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
#pragma mark Equal <SHPlayerProtocol>
-(BOOL)isEqualToParticipant:(id)object; {
  BOOL isEqual = NO;
  if([object respondsToSelector:@selector(playerID)])
    isEqual = [self.playerID isEqualToString:((id<SHPlayerProtocol>)object).playerID];
  else
    isEqual = [super isEqual:object];
  return isEqual;
}

-(BOOL)isEqualToPlayer:(id)object; {
  return [self isEqualToPlayer:object];
}

@end
