//
//  SHPlayerProtocol.h
//  Telepathic
//
//  Created by Seivan Heidari on 4/11/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//


@protocol SHPlayerProtocol <NSObject>
@optional
@property(nonatomic,strong) NSString * playerID;
@required
-(BOOL)isEqualToParticipant:(id)object;
-(BOOL)isEqualToPlayer:(id)object;
@end