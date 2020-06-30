#import "Smartad.h"
#import "RCTUtils.h"

NSString *const kSmartAdInterstitialAdNotReady = @"smartAdInterstitialAdNotReady";
NSString *const kSmartAdInterstitialAdLoaded = @"smartAdInterstitialAdLoaded";
NSString *const kSmartAdInterstitialAdFailedToLoad = @"smartAdInterstitialAdFailedToLoad";
NSString *const kSmartAdInterstitialAdShown = @"smartAdInterstitialAdShown";
NSString *const kSmartAdInterstitialAdFailedToShow = @"smartAdInterstitialAdFailedToShow";
NSString *const kSmartAdInterstitialAdClicked = @"smartAdInterstitialAdClicked";
NSString *const kSmartAdInterstitialAdDismissed = @"smartAdInterstitialAdDismissed";
//NSString *const kSmartAdInterstitialAdVideoEvent = @"smartAdInterstitialAdVideoEvent";

#define kBaseURL @"https://mobile.smartadserver.com"

@interface Smartad () <SASInterstitialManagerDelegate>

@property SASInterstitialManager *interstitialManager;
//@property (nonatomic, strong) SASNativeAd *nativeAd;
@end

@implementation Smartad {
    RCTResponseSenderBlock _requestInterstitialCallback;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents {
    return @[
        kSmartAdInterstitialAdNotReady,
        kSmartAdInterstitialAdLoaded,
        kSmartAdInterstitialAdFailedToLoad,
        kSmartAdInterstitialAdShown,
        kSmartAdInterstitialAdFailedToShow,
        kSmartAdInterstitialAdClicked,
        kSmartAdInterstitialAdDismissed,
        //kSmartAdInterstitialAdVideoEvent 
    ];
}

RCT_EXPORT_METHOD(initializeInterstitial:(nonnull NSInteger *)kInterstitialSiteID kInterstitialPageID:(nonnull NSString *)kInterstitialPageID kInterstitialFormatID:(nonnull NSInteger *)kInterstitialFormatID kInterstitialKeywordTargeting:(nullable NSString *)kInterstitialKeywordTargeting)
{
    [[SASConfiguration sharedInstance] configureWithSiteId:kInterstitialSiteID baseURL:kBaseURL];
        
    #ifdef DEBUG
        SASAdPlacement *placement = [SASAdPlacement
            adPlacementWithTestAd:SASAdPlacementTestInterstitialMRAID
        ];
    #else
        SASAdPlacement *placement = [SASAdPlacement
        adPlacementWithSiteId:kInterstitialSiteID
                       pageId:kInterstitialPageID
                     formatId:kInterstitialFormatID
             keywordTargeting:kInterstitialKeywordTargeting
        ];
    #endif
    self.interstitialManager = [[SASInterstitialManager alloc] initWithPlacement:placement delegate:self];
}

RCT_EXPORT_METHOD(loadInterstitialAd)
{
    if (self.interstitialManager != nil) {
        [self.interstitialManager load];
    } else {
        [self sendEventWithName:kSmartAdInterstitialAdFailedToLoad body:nil];
    }
}

RCT_EXPORT_METHOD(showInterstitialAd)
{
    if (self.interstitialManager != nil && self.interstitialManager.adStatus == SASAdStatusReady) {
        
        UIViewController* vc = RCTPresentedViewController();
        [self.interstitialManager showFromViewController:vc];
    } else if (self.interstitialManager.adStatus == SASAdStatusExpired) {
        NSLog(@"Interstitial has expired and cannot be shown anymore.");
        [self sendEventWithName:kSmartAdInterstitialAdNotReady body:nil];
    } else {
        [self sendEventWithName:kSmartAdInterstitialAdNotReady body:nil];
    }
}

RCT_EXPORT_METHOD(onDestroy)
{}

RCT_EXPORT_METHOD(reset)
{}


- (void)interstitialManager:(SASInterstitialManager *)manager didFailToLoadWithError: (NSError *)error {
    NSLog(@"Interstitial did fail to load with error: %@", [error localizedDescription]);
    [self sendEventWithName:kSmartAdInterstitialAdFailedToLoad body:nil];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didAppearFromViewController: (UIViewController *)controller {
    NSLog(@"Interstitial did appear");
    [self sendEventWithName:kSmartAdInterstitialAdShown body:nil];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didFailToShowWithError: (NSError *)error {
    NSLog(@"Interstitial did fail to show with error: %@", [error localizedDescription]);
    [self sendEventWithName:kSmartAdInterstitialAdFailedToShow body:nil];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didDisappearFromViewController: (UIViewController *)controller {
    NSLog(@"Interstitial did disappear");
    [self sendEventWithName:kSmartAdInterstitialAdDismissed body:nil];
}

- (void)interstitialManager:(SASInterstitialManager *)manager shouldHandleURL: (NSURL *)URL {
    NSLog(@"Interstitial should Handle url");
    [self sendEventWithName:kSmartAdInterstitialAdClicked body:nil];
}

/* - (void)interstitialManager:(SASInterstitialManager *)manager didSendVideoEvent: (SASVideoEvent *)videoEvent {
    NSLog(@"Interstitial did send video event: %li", (long)videoEvent);
    [self sendEventWithName:kSmartAdInterstitialAdVideoEvent body:nil];
} */


/* - (void)rewardedVideoManager:(SASRewardedVideoManager *)manager willPresentModalViewFromViewController: (UIViewController *)controller {
    NSLog(@"RewardedVideo will present modal");
    
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager willDismissModalViewFromViewController: (UIViewController *)controller {
    NSLog(@"RewardedVideo will modal view ");
    
} */

- (void)interstitialManager:(SASInterstitialManager *)manager didLoadAd:(SASAd *)ad {
    NSLog(@"Interstitial has been loaded and is ready to be shown");

    // Find Ad vignette
    /* SASNativeVideoAd *castedAd = (SASNativeVideoAd *)ad;
    if (castedAd.posterImageUrl) {
        NSDictionary *extraParameters = ad.extraParameters;
        NSLog(@"Vignette is found at: %@", [castedAd.posterImageUrl absoluteString]);
        [self sendEventWithName:kSmartAdVignette body:@{@"url":[castedAd.posterImageUrl absoluteString], @"extraparams":extraParameters}];
    } */

    [self sendEventWithName:kSmartAdInterstitialAdLoaded body:nil];
}

@end
