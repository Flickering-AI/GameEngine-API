//
//  ThinkingGameEngineApi.h
//  engine
//
//  Created by liulongbing on 2022/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThinkingGameEngineApi : NSObject

- (void)setCustomerLibInfo:(NSString *)libName libVersion:(NSString *)libVersion;

- (void)calibrateTime:(NSTimeInterval)timeStampMillis;

- (void)calibrateTimeWithNtp:(NSString *)ntpServer;

- (void)enableTrackLog:(BOOL)enableLog;

- (void)sharedInstance:(NSString *)config;

- (void)track:(NSString *)obj;

- (void)trackEvent:(NSString *)obj;

- (void)timeEvent:(NSString *)obj;

- (void)login:(NSString *)obj;

- (void)logout:(NSString *)obj;

- (void)identify:(NSString *)obj;

- (void)userSet:(NSString *)obj;

- (void)userUnset:(NSString *)obj;

- (void)userSetOnce:(NSString *)obj;

- (void)userAdd:(NSString *)obj;

- (void)userDel:(NSString *)obj;

- (void)userAppend:(NSString *)obj;

- (void)userUniqAppend:(NSString *)obj;

- (void)setSuperProperties:(NSString *)obj;

- (void)unsetSuperProperty:(NSString *)obj;

- (void)clearSuperProperties:(NSString *)obj;

- (void)flush:(NSString *)obj;

- (void)setTrackStatus:(NSString *)obj;

- (void)enableAutoTrack:(NSString *)obj;

- (NSString *)getPresetProperties:(NSString *)obj;

- (NSString *)getSuperProperties:(NSString *)obj;

- (NSString *)getDistinctId:(NSString *)obj;

- (NSString *)getDeviceId:(NSString *)obj;

- (void)setAutoTrackProperties:(NSString *)obj;

- (void)enableThirdPartySharing:(NSString *)obj;

@end

NS_ASSUME_NONNULL_END
