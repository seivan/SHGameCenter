//
//  NSArray+Utilities.h
//  Telepathic
//
//  Created by Seivan Heidari on 10/14/12.
//  Copyright (c) 2012 Seivan Heidari. All rights reserved.
//



@interface NSArray (Utilities)
-(NSOrderedSet *)toOrderedSet;
-(NSSet *)toSet;
@end


@interface NSMutableOrderedSet (Utilities)
-(id)removeAndReturnObject:(id)theObject;
-(id)removeAndReturnObjectAtIndex:(NSUInteger)theIndex;
@end
