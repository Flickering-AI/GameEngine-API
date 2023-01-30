//
//  ThinkingGameEngineApi.m
//  engine
//
//  Created by liulongbing on 2022/11/11.
//

#import "ThinkingGameEngineApi.h"

#if __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#endif


#if __has_include("ThinkingAnalyticsSDK.h")
#import "ThinkingAnalyticsSDK.h"
#endif

@implementation ThinkingGameEngineApi


- (void)setCustomerLibInfo:(NSString *)libName libVersion:(NSString *)libVersion{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    [ThinkingAnalyticsSDK setCustomerLibInfoWithLibName:libName libVersion:libVersion];
    #endif
}

- (void)enableTrackLog:(BOOL)enableLog{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    if(enableLog){
        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    }else{
        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelNone];
    }
    #endif
}

- (void)calibrateTime:(NSTimeInterval)timeStampMillis{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    [ThinkingAnalyticsSDK calibrateTime:timeStampMillis];
    #endif
}

- (void)calibrateTimeWithNtp:(NSString *)ntpServer{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    [ThinkingAnalyticsSDK calibrateTimeWithNtp:ntpServer];
    #endif
}

- (void)sharedInstance:(NSString *)config{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:config];
        NSString* appId = [options objectForKey:@"appId"];
        NSString* serverUrl = [options objectForKey:@"serverUrl"];
        TDConfig *tdConfig = [[TDConfig alloc]init];
        if([options objectForKey:@"timeZone"]){
            tdConfig.defaultTimeZone = [NSTimeZone timeZoneWithName:[options objectForKey:@"timeZone"]];
        }
        NSNumber *mode =[options objectForKey:@"mode"];
        if (mode.intValue == 0) {
            tdConfig.debugMode = ThinkingAnalyticsDebugOff;
        } else if (mode.intValue == 1) {
            tdConfig.debugMode = ThinkingAnalyticsDebug;
        }else if(mode.intValue== 2){
            tdConfig.debugMode = ThinkingAnalyticsDebugOnly;
        }
        if([options objectForKey:@"enableEncrypt"]){
            NSNumber* enableEncrypt = [options objectForKey:@"enableEncrypt"];
            tdConfig.enableEncrypt = enableEncrypt.boolValue;
        }
        if([options objectForKey:@"secretKey"]){
            NSDictionary *secretKey = (NSDictionary *)[options objectForKey:@"secretKey"];
            NSNumber* keyVersion = [secretKey objectForKey:@"version"];
            tdConfig.secretKey = [[TDSecretKey alloc] initWithVersion:keyVersion.intValue publicKey:[secretKey objectForKey:@"publicKey"] asymmetricEncryption:[secretKey objectForKey:@"asymmetricEncryption"] symmetricEncryption:[secretKey objectForKey:@"symmetricEncryption"]];
        }
        [ThinkingAnalyticsSDK startWithAppId:appId
                                     withUrl:serverUrl
                                  withConfig:tdConfig];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)track:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSString *eventName = [options objectForKey:@"eventName"];
        if([self isBlankString:eventName]) return;
        NSDictionary *properties = [options objectForKey:@"properties"];
        NSDate *time;
        if ([options objectForKey:@"time"]) {
            double t = [[options objectForKey:@"time"] doubleValue];
            if(t != 0){
                time = [NSDate dateWithTimeIntervalSince1970:t / 1000.0];
            }
        }
        NSString *timeZone = [options objectForKey:@"timeZone"];
        NSTimeZone *tz = [NSTimeZone timeZoneWithName:timeZone];
        [instance track:eventName properties:properties time:time timeZone:tz];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)trackEvent:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSString *eventName = [options objectForKey:@"eventName"];
        if([self isBlankString:eventName]) return;
        NSDictionary *properties = [options objectForKey:@"properties"];
        NSString *eventId = [options objectForKey:@"eventId"];
        NSDate *time;
        if ([options objectForKey:@"time"]) {
            double t = [[options objectForKey:@"time"] doubleValue];
            if(t != 0){
                time = [NSDate dateWithTimeIntervalSince1970:t / 1000.0];
            }
        }
        NSString *timeZone = [options objectForKey:@"timeZone"];
        NSTimeZone *tz = [NSTimeZone timeZoneWithName:timeZone];
        NSNumber *type = [options objectForKey:@"type"];
        if(type.intValue == 0){
            TDFirstEventModel *firstModel = [[TDFirstEventModel alloc] initWithEventName:eventName firstCheckID:eventId];
            firstModel.properties = properties;
            [firstModel configTime:time timeZone:tz];
            [instance trackWithEventModel:firstModel];
        }else if(type.intValue == 1){
            TDEventModel *updateModel = [[TDUpdateEventModel alloc] initWithEventName:eventName eventID:eventId];
            updateModel.properties = properties;
            [updateModel configTime:time timeZone:tz];
            [instance trackWithEventModel:updateModel];
        }else if(type.intValue == 2){
            TDOverwriteEventModel *overwriteModel = [[TDOverwriteEventModel alloc] initWithEventName:eventName eventID:eventId];
            overwriteModel.properties = properties;
            [overwriteModel configTime:time timeZone:tz];
            [instance trackWithEventModel:overwriteModel];
        }
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)timeEvent:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSString *eventName = [options objectForKey:@"eventName"];
        if([self isBlankString:eventName]) return;
        [instance timeEvent:eventName];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)login:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSString *loginId = [options objectForKey:@"loginId"];
        [instance login:loginId];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)logout:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        [instance logout];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)identify:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSString *distinctId = [options objectForKey:@"distinctId"];
        [instance identify:distinctId];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)userSet:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSDictionary *properties = [options objectForKey:@"properties"];
        if(!properties) return;
        NSDate *time;
        if ([options objectForKey:@"time"]) {
            double t = [[options objectForKey:@"time"] doubleValue];
            if(t != 0){
                time = [NSDate dateWithTimeIntervalSince1970:t / 1000.0];
            }
        }
        [instance user_set:properties withTime:time];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)userUnset:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSArray *properties = [options objectForKey:@"properties"];
        if(!properties) return;
        NSDate *time;
        if ([options objectForKey:@"time"]) {
            double t = [[options objectForKey:@"time"] doubleValue];
            if(t != 0){
                time = [NSDate dateWithTimeIntervalSince1970:t / 1000.0];
            }
        }
        for(int i = 0;i<properties.count;i++){
            [instance user_unset:[properties objectAtIndex:i] withTime:time];
        }
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)userSetOnce:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSDictionary *properties = [options objectForKey:@"properties"];
        if(!properties) return;
        NSDate *time;
        if ([options objectForKey:@"time"]) {
            double t = [[options objectForKey:@"time"] doubleValue];
            if(t != 0){
                time = [NSDate dateWithTimeIntervalSince1970:t / 1000.0];
            }
        }
        [instance user_setOnce:properties withTime:time];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)userAdd:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSDictionary *properties = [options objectForKey:@"properties"];
        if(!properties) return;
        NSDate *time;
        if ([options objectForKey:@"time"]) {
            double t = [[options objectForKey:@"time"] doubleValue];
            if(t != 0){
                time = [NSDate dateWithTimeIntervalSince1970:t / 1000.0];
            }
        }
        [instance user_add:properties withTime:time];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)userDel:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSDate *time;
        if ([options objectForKey:@"time"]) {
            double t = [[options objectForKey:@"time"] doubleValue];
            if(t != 0){
                time = [NSDate dateWithTimeIntervalSince1970:t / 1000.0];
            }
        }
        [instance user_delete:time];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)userAppend:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSDictionary *properties = [options objectForKey:@"properties"];
        if(!properties) return;
        NSDate *time;
        if ([options objectForKey:@"time"]) {
            double t = [[options objectForKey:@"time"] doubleValue];
            if(t != 0){
                time = [NSDate dateWithTimeIntervalSince1970:t / 1000.0];
            }
        }
        [instance user_append:properties withTime:time];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)userUniqAppend:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSDictionary *properties = [options objectForKey:@"properties"];
        if(!properties) return;
        NSDate *time;
        if ([options objectForKey:@"time"]) {
            double t = [[options objectForKey:@"time"] doubleValue];
            if(t != 0){
                time = [NSDate dateWithTimeIntervalSince1970:t / 1000.0];
            }
        }
        [instance user_uniqAppend:properties withTime:time];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)setSuperProperties:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSDictionary *properties = [options objectForKey:@"properties"];
        if(!properties) return;
        [instance setSuperProperties:properties];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)unsetSuperProperty:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSString *property = [options objectForKey:@"property"];
        if(!property) return;
        [instance unsetSuperProperty:property];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)clearSuperProperties:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        [instance clearSuperProperties];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)flush:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        [instance flush];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)enableAutoTrack:(NSString *)obj{
    #if __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSArray *autoTrack = [options objectForKey:@"autoTrack"];
        if(!autoTrack) return;
        ThinkingAnalyticsAutoTrackEventType iOSAutoTrackType = ThinkingAnalyticsEventTypeNone;
        for(int i=0; i < autoTrack.count; i++) {
            NSString* value = autoTrack[i];
            if ([value isEqualToString:@"appInstall"]) {
                iOSAutoTrackType |= ThinkingAnalyticsEventTypeAppInstall;
            } else if ([value isEqualToString:@"appStart"]) {
                iOSAutoTrackType |= ThinkingAnalyticsEventTypeAppStart;
            } else if ([value isEqualToString:@"appEnd"]) {
                iOSAutoTrackType |= ThinkingAnalyticsEventTypeAppEnd;
            } else if ([value isEqualToString:@"appCrash"]) {
                iOSAutoTrackType |= ThinkingAnalyticsEventTypeAppViewCrash;
            }
        }
        [instance enableAutoTrack:iOSAutoTrackType];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)enableThirdPartySharing:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        
        if([options objectForKey:@"types"]){
            NSArray *shareTypes = [options objectForKey:@"types"];
            TAThirdPartyShareType types = TAThirdPartyShareTypeNONE;
            for(int i = 0;i<shareTypes.count;i++){
                NSString* value = shareTypes[i];
                if([@"AppsFlyer" isEqualToString:value]){
                    types |= TAThirdPartyShareTypeAPPSFLYER;
                }else if([@"IronSource" isEqualToString:value]){
                    types |= TAThirdPartyShareTypeIRONSOURCE;
                }else if([@"Adjust" isEqualToString:value]){
                    types |= TAThirdPartyShareTypeADJUST;
                }else if([@"Branch" isEqualToString:value]){
                    types |= TAThirdPartyShareTypeBRANCH;
                }else if([@"TopOn" isEqualToString:value]){
                    types |= TAThirdPartyShareTypeTOPON;
                }else if([@"Tracking" isEqualToString:value]){
                    types |= TAThirdPartyShareTypeTRACKING;
                }else if([@"TradPlus" isEqualToString:value]){
                    types |= TAThirdPartyShareTypeTRADPLUS;
                }
            }
            [instance enableThirdPartySharing:types];
        }else if([options objectForKey:@"type"]){
            NSString* type = [options objectForKey:@"type"];
            NSDictionary* params = [options objectForKey:@"params"];
            TAThirdPartyShareType t = TAThirdPartyShareTypeNONE;
            if([@"AppsFlyer" isEqualToString:type]){
                t = TDThirdPartyShareTypeAPPSFLYER;
            }else if([@"IronSource" isEqualToString:type]){
                t = TDThirdPartyShareTypeIRONSOURCE;
            }else if([@"Adjust" isEqualToString:type]){
                t = TDThirdPartyShareTypeADJUST;
            }else if([@"Branch" isEqualToString:type]){
                t = TDThirdPartyShareTypeBRANCH;
            }else if([@"TopOn" isEqualToString:type]){
                t = TDThirdPartyShareTypeTOPON;
            }else if([@"Tracking" isEqualToString:type]){
                t = TDThirdPartyShareTypeTRACKING;
            }else if([@"TradPlus" isEqualToString:type]){
                t = TDThirdPartyShareTypeTRADPLUS;
            }
            [instance enableThirdPartySharing:t customMap:params];
        }
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (void)setTrackStatus:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        if([options objectForKey:@"status"]){
            NSString *status = [options objectForKey:@"status"];
            TATrackStatus ta_status;
            if([@"pause" isEqualToString:status]){
                ta_status = TATrackStatusPause;
            }else if([@"stop" isEqualToString:status]){
                ta_status = TATrackStatusStop;
            }else if([@"saveOnly" isEqualToString:status]){
                ta_status = TATrackStatusSaveOnly;
            }else if([@"normal" isEqualToString:status]){
                ta_status = TATrackStatusNormal;
            }
            [instance setTrackStatus:ta_status];
        }
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

- (NSString *)getPresetProperties:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        TDPresetProperties *presetProperties = [instance getPresetProperties];
        if(presetProperties){
            NSDictionary *jsonDict = [presetProperties toEventPresetProperties];
            NSMutableDictionary *mInitDict =[[NSMutableDictionary alloc]init];
            [mInitDict setValue:[jsonDict objectForKey:@"#app_version"] forKey:@"#app_version"];
            [mInitDict setValue:[jsonDict objectForKey:@"#bundle_id"] forKey:@"#bundle_id"];
            [mInitDict setValue:[jsonDict objectForKey:@"#carrier"] forKey:@"#carrier"];
            [mInitDict setValue:[jsonDict objectForKey:@"#device_id"] forKey:@"#device_id"];
            [mInitDict setValue:[jsonDict objectForKey:@"#device_model"] forKey:@"#device_model"];
            [mInitDict setValue:[jsonDict objectForKey:@"#fps"] forKey:@"#fps"];
//            [mInitDict setValue:[jsonDict objectForKey:@"#install_time"] forKey:@"#install_time"];
            [mInitDict setValue:[jsonDict objectForKey:@"#manufacturer"] forKey:@"#manufacturer"];
            [mInitDict setValue:[jsonDict objectForKey:@"#network_type"] forKey:@"#network_type"];
            [mInitDict setValue:[jsonDict objectForKey:@"#os"] forKey:@"#os"];
            [mInitDict setValue:[jsonDict objectForKey:@"#os_version"] forKey:@"#os_version"];
            [mInitDict setValue:[jsonDict objectForKey:@"#ram"] forKey:@"#ram"];
            [mInitDict setValue:[jsonDict objectForKey:@"#screen_height"] forKey:@"#screen_height"];
            [mInitDict setValue:[jsonDict objectForKey:@"#screen_width"] forKey:@"#screen_width"];
            [mInitDict setValue:[jsonDict objectForKey:@"#simulator"] forKey:@"#simulator"];
            [mInitDict setValue:[jsonDict objectForKey:@"#system_language"] forKey:@"#system_language"];
            [mInitDict setValue:[jsonDict objectForKey:@"#zone_offset"] forKey:@"#zone_offset"];
            if ([NSJSONSerialization isValidJSONObject:mInitDict]) {
                NSError *error = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mInitDict options:NSJSONWritingPrettyPrinted error:&error];
                if (error == nil) {
                    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
            }
        }else{
            return @"{}";
        }
        
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
    return @"{}";
}

- (NSString *)getSuperProperties:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSDictionary *jsonDict = [instance currentSuperProperties];
        if(jsonDict){
            if ([NSJSONSerialization isValidJSONObject:jsonDict]) {
                NSError *error = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
                if (error == nil) {
                    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
            }
        }else{
            return @"{}";
        }
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
    return @"{}";
}

- (NSString *)getDistinctId:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        if(instance){
            return [instance getDistinctId];
        }else{
            return [[ThinkingAnalyticsSDK sharedInstance]getDistinctId];
        }
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
    return @"";
}

- (NSString *)getDeviceId:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        if(instance){
            return [instance getDeviceId];
        }else{
            return [[ThinkingAnalyticsSDK sharedInstance]getDeviceId];
        }
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
    return @"";
}

- (void)setAutoTrackProperties:(NSString *)obj{
    #if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
    @try {
        NSDictionary* options = [self dictionaryWithJsonString:obj];
        NSString* appId = [options objectForKey:@"appId"];
        ThinkingAnalyticsSDK *instance = [self getCurrentInstance:appId];
        NSArray *autoTrack = [options objectForKey:@"autoTrack"];
        ThinkingAnalyticsAutoTrackEventType iOSAutoTrackType = ThinkingAnalyticsEventTypeNone;
        for(int i=0; i < autoTrack.count; i++) {
            NSString* value = autoTrack[i];
            if ([value isEqualToString:@"appInstall"]) {
                iOSAutoTrackType |= ThinkingAnalyticsEventTypeAppInstall;
            } else if ([value isEqualToString:@"appStart"]) {
                iOSAutoTrackType |= ThinkingAnalyticsEventTypeAppStart;
            } else if ([value isEqualToString:@"appEnd"]) {
                iOSAutoTrackType |= ThinkingAnalyticsEventTypeAppEnd;
            } else if ([value isEqualToString:@"appCrash"]) {
                iOSAutoTrackType |= ThinkingAnalyticsEventTypeAppViewCrash;
            }
        }
        [instance setAutoTrackProperties:iOSAutoTrackType properties:[options objectForKey:@"properties"]];
    } @catch (NSException *exception) {
        NSLog(@"[ThinkingAnalyticsSDK] error:%@",exception);
    }
    #endif
}

#if __has_include("ThinkingAnalyticsSDK.h") || __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
- (ThinkingAnalyticsSDK *)getCurrentInstance:(NSString *)appId{
    if(appId){
        return [ThinkingAnalyticsSDK sharedInstanceWithAppid:appId];
    }else{
        return [ThinkingAnalyticsSDK sharedInstance];
    }
}
#endif

- (BOOL) isBlankString:(NSString *)string {
    
    if (string == nil || string == NULL) {
        
        return YES;
        
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        
        return YES;
        
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        
        return YES;
        
    }
    
    return NO;
    
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        return [[NSDictionary alloc]init];
    }
    return dic;
}


@end

