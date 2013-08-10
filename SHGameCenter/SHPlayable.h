
@protocol SHPlayable <NSObject>
@optional
@property(nonatomic,strong) NSString * playerID;
@required
-(BOOL)SH_isEqual:(id)object;

@end