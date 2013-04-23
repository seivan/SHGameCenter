//
//  GKTurnBasedMatch+SHGameCenter.m
//
//  Created by Seivan Heidari on 4/11/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//
#import "NSEnumerable+Utilities.h"
#import <BlocksKit/BlocksKit.h>
#import "GKTurnBasedMatch+SHGameCenter.h"
#import "GKLocalPlayer+SHGameCenter.h"
#import "GKTurnBasedParticipant+SHGameCenter.h"

@implementation GKTurnBasedMatch (SHGameCenter)
#pragma mark -
#pragma mark Player Getters
-(GKTurnBasedParticipant *)SH_meAsParticipant; {
  return [self.participants match:^BOOL(GKTurnBasedParticipant * participant) {
    return [participant isEqual:GKLocalPlayer.SH_me];
  }];
}

-(NSOrderedSet *)SH_participantsWithoutMe; {
  NSOrderedSet * participantsWithoutMe = nil;
  if(self.SH_meAsParticipant)
   participantsWithoutMe = [self SH_rejectParticipants:@[self.SH_meAsParticipant].toSet];
  else
    participantsWithoutMe = self.participants.toOrderedSet;
  return participantsWithoutMe;
}

-(NSOrderedSet *)SH_participantsWithoutCurrentParticipant; {
  NSOrderedSet * participantsWithoutCurrentParticipant = nil;
  if(self.currentParticipant)
    participantsWithoutCurrentParticipant = [self SH_rejectParticipants:@[self.currentParticipant].toSet];
  else
    participantsWithoutCurrentParticipant = self.participants.toOrderedSet;
  return  participantsWithoutCurrentParticipant;
}

-(NSOrderedSet *)SH_nextParticipantsInLine; {
  return [self.SH_participantsWithoutCurrentParticipant sortedArrayUsingComparator:^NSComparisonResult(GKTurnBasedParticipant * obj1, GKTurnBasedParticipant * obj2) {
    if(obj1.lastTurnDate == nil)
      return NSOrderedAscending;
    if (obj2.lastTurnDate == nil)
      return NSOrderedDescending;

    return [obj1.lastTurnDate compare:obj2.lastTurnDate];
  }].toOrderedSet;
}

-(NSOrderedSet *)SH_playerIdentifiers; {
  return [self.participants map:^id(GKTurnBasedParticipant * obj) { return obj.playerID; }].toOrderedSet;
}


#pragma mark -
#pragma mark Conditions
-(BOOL)SH_isMyTurn; {
  return [self.currentParticipant isEqualToParticipant:GKLocalPlayer.SH_me];
}
-(BOOL)SH_hasIncompleteParticipants; {
  return [self.participants any:^BOOL(GKTurnBasedParticipant * participant) {
    return participant.SH_isActiveOrInvited == NO;
  }];
}

-(BOOL)SH_isMatchStatusOpen; {
  return self.status == GKTurnBasedMatchStatusOpen;
}
-(BOOL)SH_isMatchStatusMatching; {
  return self.status == GKTurnBasedMatchStatusMatching;
}
-(BOOL)SH_isMatchStatusEnded; {
  return self.status == GKTurnBasedMatchStatusEnded;
}

-(BOOL)SH_isMatchStatusUnknown; {
  return self.status == GKTurnBasedMatchStatusUnknown;
}

#pragma mark -
#pragma mark Player
-(void)SH_requestPlayersWithBlock:(SHGameListsBlock)theBlock; {
  [GKPlayer loadPlayersForIdentifiers:self.SH_playerIdentifiers.array withCompletionHandler:^(NSArray *players, NSError *error) {
    theBlock(players.toOrderedSet, error);
  }];
}




#pragma mark -
#pragma mark Equal
-(BOOL)isEqualToMatch:(id)object; {
  BOOL isEqual = NO;
  if([object respondsToSelector:@selector(matchID)])
   isEqual = [self.matchID isEqualToString:((GKTurnBasedMatch *)object).matchID];
  else
    isEqual = [super isEqual:object];
  return isEqual;
}

#pragma mark -
#pragma mark Match Getters
+(void)SH_requestMatchesWithBlock:(SHGameListsBlock)theBlock; {
  [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
    theBlock(matches.toOrderedSet, error);
  }];
}



#pragma mark -
#pragma mark Match Setters
-(void)SH_resignWithBlock:(SHGameMatchBlock)theBlock; {
  [self.participants each:^(GKTurnBasedParticipant * participant) {
    participant.matchOutcome = GKTurnBasedMatchOutcomeQuit;
  }];
    
//  if(self.SH_isMatchStatusEnded)
//    theBlock(self, nil);
  if(self.SH_isMyTurn) {
     [self endMatchInTurnWithMatchData:self.matchData completionHandler:^(NSError *error) {
      theBlock(self,error);
    }];
  }
  else
    [self participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:^(NSError *error) {
      theBlock(self, error);
    }];
  

}

-(void)SH_deleteWithBlock:(SHGameMatchBlock)theBlock; {
  [self SH_resignWithBlock:^(GKTurnBasedMatch *match, NSError *error) {
    [match removeWithCompletionHandler:^(NSError *error) {
      theBlock(match, error);
    }];
  }];
}
#pragma mark -
#pragma mark Helpers
-(NSOrderedSet *)SH_rejectParticipants:(NSSet *)theParticipantsToRject; {
 return [self.participants reject:^BOOL(GKTurnBasedParticipant * participant) {
   return[theParticipantsToRject match:^BOOL(GKTurnBasedParticipant * participantToRemove) {
     return [participant isEqual:participantToRemove];
   }];
  }].toOrderedSet;
}


@end
