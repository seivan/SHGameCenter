//
//  GKTurnBasedMatch+SHGameCenter.h
//
//  Created by Seivan Heidari on 4/11/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "SHGameCenterBlockDefinitions.h"
#import <GameKit/GameKit.h>

@interface GKTurnBasedMatch (SHGameCenter)

#pragma mark -
#pragma mark Participant Getters
@property(nonatomic,readonly) GKTurnBasedParticipant  * SH_meAsParticipant;
@property(nonatomic,readonly) NSOrderedSet            * SH_participantsWithoutMe;
@property(nonatomic,readonly) NSOrderedSet            * SH_participantsWithoutCurrentParticipant;
@property(nonatomic,readonly) NSOrderedSet            * SH_nextParticipantsInLine;
@property(nonatomic,readonly) NSOrderedSet            * SH_playerIdentifiers;

#pragma mark -
#pragma mark Conditions
@property(nonatomic,readonly) BOOL SH_isMyTurn;
//Participants who are neither active nor invited - e.g done, declined and etc
@property(nonatomic,readonly) BOOL SH_hasIncompleteParticipants;

@property(nonatomic,readonly) BOOL SH_isMatchStatusOpen;
@property(nonatomic,readonly) BOOL SH_isMatchStatusMatching;
@property(nonatomic,readonly) BOOL SH_isMatchStatusEnded;
@property(nonatomic,readonly) BOOL SH_isMatchStatusUnknown;


#pragma mark -
#pragma mark Player
-(void)SH_requestPlayersWithBlock:(SHGameListsBlock)theBlock;

#pragma mark -
#pragma mark Equal
-(BOOL)isEqualToMatch:(id)object;

#pragma mark -
#pragma mark Match Getters
+(void)SH_requestMatchesWithBlock:(SHGameListsBlock)theBlock;



#pragma mark -
#pragma mark Match Setters
-(void)SH_resignWithBlock:(SHGameMatchBlock)theBlock;

-(void)SH_deleteWithBlock:(SHGameMatchBlock)theBlock;


#pragma mark -
#pragma mark Helpers
-(NSOrderedSet *)SH_rejectParticipants:(NSSet *)theParticipantsToRject;


@end
