
#import "NSEnumerable+Utilities.h"

@implementation NSArray (Utilities)


-(NSOrderedSet *)toOrderedSet; {
  NSOrderedSet * orderedSet = [NSOrderedSet orderedSetWithArray:self];
  return orderedSet;
}

-(NSSet *)toSet; {
  NSSet * set = [NSSet setWithArray:self];
  return set;
}
@end


@implementation NSMutableOrderedSet (Utilities)
-(id)removeAndReturnObject:(id)theObject; {
  [self removeObject:theObject];
  return theObject;

}

-(id)removeAndReturnObjectAtIndex:(NSUInteger)theIndex; {
  id object = [self objectAtIndex:theIndex];
  [self removeObjectAtIndex:theIndex];
  return object;
}

@end

