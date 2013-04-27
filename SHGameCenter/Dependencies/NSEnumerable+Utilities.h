@interface NSArray (Utilities)
-(NSOrderedSet *)toOrderedSet;
-(NSSet *)toSet;
@end


@interface NSMutableOrderedSet (Utilities)
-(id)removeAndReturnObject:(id)theObject;
-(id)removeAndReturnObjectAtIndex:(NSUInteger)theIndex;
@end
