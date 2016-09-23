#import <Foundation/Foundation.h>
#import "SSCandidate.h"

@interface SSStreetLookup : NSObject

@property (readonly, nonatomic) NSMutableArray<SSCandidate*> *result;
@property (nonatomic) NSString *inputId;
@property (nonatomic) NSString *street;
@property (nonatomic) NSString *street2;
@property (nonatomic) NSString *secondary;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *state;
@property (nonatomic) NSString *zipCode;
@property (nonatomic) NSString *lastline;
@property (nonatomic) NSString *addressee;
@property (nonatomic) NSString *urbanization;
@property (readonly, nonatomic) int maxCandidates;

- (instancetype)initWithFreeformAddress:(NSString*)freeformAddress;
- (void)addToResult:(SSCandidate*)newCandidate;
- (SSCandidate*)getResultAtIndex:(int)index;
- (void)setMaxCandidates:(int)maxCandidates error:(NSError**)error;

@end