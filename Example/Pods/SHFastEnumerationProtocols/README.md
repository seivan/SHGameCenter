SHFastEnumerationProtocols
==========
[![Build Status](https://travis-ci.org/seivan/SHFastEnumerationProtocols.png?branch=master)](https://travis-ci.org/seivan/SHFastEnumerationProtocols)
[![Version](http://cocoapod-badges.herokuapp.com/v/SHFastEnumerationProtocols/badge.png)](http://cocoadocs.org/docsets/SHFastEnumerationProtocols)
[![Platform](http://cocoapod-badges.herokuapp.com/p/SHFastEnumerationProtocols/badge.png)](http://cocoadocs.org/docsets/SHFastEnumerationProtocols)


Overview
--------
NSFastEnumeration helpers and enumeration blocks through a protocol on foundation collection classes.
Helpers for both keyed, index and unordered collection objects.
Converting to other collection classes through dot notation.
Block based callers for enumeration. 
Tested and ready. 

* NSArray and NSMutableArray
* NSOrderedSet and NSMutableOrderedSet
* NSSet, NSMutableSet and NSCountedset
* NSHashTable 
* NSDictionary and NSMutableDictionary 
* NSMapTable

TODO: NSIndexSet, NSMutableIndexSet and NSEnumerator. 
TODO: Keyed protocols


API
----------

#### [SHFastEnumerationProtocols](https://github.com/seivan/SHFastEnumerationProtocols#api-1)



Installation
------------

```ruby
pod 'SHFastEnumerationProtocols'
```

***

Setup
-----

Put this either in specific files or your project prefix file

```objective-c
#import "<CollectionClass>+SHFastEnumerationProtocols.h"
```
or for all classes
```objective-c
#import "SHFastEnumerationProtocols.h"
```


API
-----

```objective-c

#pragma mark - Block Definitions

//obj is the key for keyed indexed classes (NSDictionary, NSMapTable)
typedef void (^SHIteratorBlock)(id obj);
typedef void (^SHIteratorWithIndexBlock)(id obj, NSInteger index) ;

typedef id (^SHIteratorReturnIdBlock)(id obj);
typedef id (^SHIteratorReduceBlock)(id memo, id obj);

typedef BOOL (^SHIteratorReturnTruthBlock)(id obj);

#pragma mark - <SHFastEnumerationBlocks>
@protocol SHFastEnumerationBlocks <NSObject>
@required
-(void)SH_each:(SHIteratorBlock)theBlock;
-(void)SH_concurrentEach:(SHIteratorBlock)theBlock;
-(instancetype)SH_map:(SHIteratorReturnIdBlock)theBlock; //Collect
-(id)SH_reduceValue:(id)theValue withBlock:(SHIteratorReduceBlock)theBlock; //Inject/FoldLeft
-(id)SH_find:(SHIteratorReturnTruthBlock)theBlock; //Match
-(instancetype)SH_findAll:(SHIteratorReturnTruthBlock)theBlock; //Select/Filter
-(instancetype)SH_reject:(SHIteratorReturnTruthBlock)theBlock; //!Select/Filter
-(BOOL)SH_all:(SHIteratorReturnTruthBlock)theBlock; //Every
-(BOOL)SH_any:(SHIteratorReturnTruthBlock)theBlock; //Some
-(BOOL)SH_none:(SHIteratorReturnTruthBlock)theBlock; // !Every
@end

#pragma mark - <SHFastEnumerationProperties>
@protocol SHFastEnumerationProperties <NSObject>
@required
@property(nonatomic,readonly) BOOL           SH_isEmpty;

@property(nonatomic,readonly) NSArray      * SH_toArray;
@property(nonatomic,readonly) NSSet        * SH_toSet;
@property(nonatomic,readonly) NSOrderedSet * SH_toOrderedSet;

//The objects are the values while the key will either be an NSNumber index (from ordered)
//or a counted key (unordereD)
@property(nonatomic,readonly) NSDictionary * SH_toDictionary;
@property(nonatomic,readonly) NSMapTable   * SH_toMapTableWeakToWeak;
@property(nonatomic,readonly) NSMapTable   * SH_toMapTableWeakToStrong;
@property(nonatomic,readonly) NSMapTable   * SH_toMapTableStrongToStrong;
@property(nonatomic,readonly) NSMapTable   * SH_toMapTableStrongToWeak;

@property(nonatomic,readonly) NSHashTable  * SH_toHashTableWeak;
@property(nonatomic,readonly) NSHashTable  * SH_toHashTableStrong;

//https://gist.github.com/seivan/6086183
@property(nonatomic,readonly) NSDecimalNumber  * SH_collectionAvg;
@property(nonatomic,readonly) NSDecimalNumber  * SH_collectionSum;
@property(nonatomic,readonly) id                 SH_collectionMax;
@property(nonatomic,readonly) id                 SH_collectionMin;

@end

#pragma mark - <SHFastEnumerationOrderedBlocks>
@protocol SHFastEnumerationOrderedBlocks <NSObject>
@required
-(void)SH_eachWithIndex:(SHIteratorWithIndexBlock)theBlock;
@end

#pragma mark - <SHFastEnumerationOrderedProperties>
@protocol SHFastEnumerationOrderedProperties <NSObject>
@required
@property(nonatomic,readonly) id SH_firstObject;
@property(nonatomic,readonly) id SH_lastObject;
@end


#pragma mark - <SHFastEnumerationOrdered>
@protocol SHFastEnumerationOrdered <NSObject>
@required
-(instancetype)SH_reverse;
@end


#pragma mark - <SHMutableFastEnumerationBlocks>
@protocol SHMutableFastEnumerationBlocks <NSObject>
@required
-(void)SH_modifyMap:(SHIteratorReturnIdBlock)theBlock;
-(void)SH_modifyFindAll:(SHIteratorReturnTruthBlock)theBlock;
-(void)SH_modifyReject:(SHIteratorReturnTruthBlock)theBlock;
@end


#pragma mark - <SHMutableFastEnumerationOrdered>
@protocol SHMutableFastEnumerationOrdered <NSObject>
@required
-(void)SH_modifyReverse;
-(id)SH_popObjectAtIndex:(NSInteger)theIndex;
-(id)SH_popFirstObject;
-(id)SH_popLastObject;
@end


```


Contact
-------

If you end up using SHFastEnumerationProtocols in a project, I'd love to hear about it.

email: [seivan.heidari@icloud.com](mailto:seivan.heidari@icloud.com)  
twitter: [@seivanheidari](https://twitter.com/seivanheidari)

## License

SHFastEnumerationProtocols is © 2013 [Seivan](http://www.github.com/seivan) and may be freely
distributed under the [MIT license](http://opensource.org/licenses/MIT).
See the [`LICENSE.md`](https://github.com/seivan/SHFastEnumerationProtocols/blob/master/LICENSE.md) file.

