//
//  SHGameCenter.h
//  Telepathic
//
//  Created by Seivan Heidari on 4/11/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "GKPlayer+SHGameCenter.h"
#import "GKLocalPlayer+SHGameCenter.h"
#import "GKTurnBasedMatch+SHGameCenter.h"
#import "GKTurnBasedParticipant+SHGameCenter.h"
#import "SHGameCenterBlockDefinitions.h"


@interface SHGameCenter : NSObject

#pragma mark -
#pragma mark Observer
+(void)setObserver:(id)theObserver matchEventTurnBlock:(SHGameMatchEventTurnBlock)theMatchEventTurnBlock
matchEventEndedBlock:(SHGameMatchEventEndedBlock)theMatchEventEndedBlock
matchEventInvitesBlock:(SHGameMatchEventInvitesBlock)theMatchEventInvitesBlock;


#pragma mark -
#pragma mark Cache
//Caching is already taken care of in other selectors in this library. But this could be handy if you want to interact outside of the library
+(void)updateCachePlayersFromPlayerIdentifiers:(NSSet *)thePlayerIdentifiers
               withCompletionBlock:(SHGameCompletionBlock)theBlock;

#pragma mark -
#pragma mark Getters
+(NSString *)aliasForPlayerId:(NSString *)thePlayerId;
+(UIImage *)photoForPlayerId:(NSString *)thePlayerId;
@end
