#import <Foundation/Foundation.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface GADMAdapterAppLovinRewardBasedVideoAd : NSObject<GADMRewardBasedVideoAdNetworkAdapter>

@end

@interface GADMExtrasAppLovin : NSObject<GADAdNetworkExtras>
@property(nonatomic, assign) NSUInteger requestNumber;
@end
