#import "MPKitForesee.h"

NSString *const kMPForeseeBaseURLKey = @"rootUrl";
NSString *const kMPForeseeClientIdKey = @"clientId";
NSString *const kMPForeseeSurveyIdKey = @"surveyId";
NSString *const kMPForeseeSendAppVersionKey = @"sendAppVersion";

@interface MPKitForesee() {
    NSString *baseURL;
    NSString *clientId;
    NSString *surveyId;
    BOOL sendAppVersion;
}

@end

@implementation MPKitForesee

+ (NSNumber *)kitCode {
    return @64;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Foresee" className:@"MPKitForesee"];
    [MParticle registerExtension:kitRegister];
}

- (void)setConfiguration:(NSDictionary *)configuration {
    if (!_started || ![self isValidConfiguration:configuration]) {
        return;
    }
    
    _configuration = configuration;
    [self setupWithConfiguration:configuration];
}

#pragma mark Private methods
- (BOOL)isValidConfiguration:(NSDictionary *)configuration {
    BOOL validConfiguration = configuration[kMPForeseeClientIdKey] && configuration[kMPForeseeSurveyIdKey];
    
    return validConfiguration;
}

- (void)setupWithConfiguration:(NSDictionary *)configuration {
    baseURL = configuration[kMPForeseeBaseURLKey] ? configuration[kMPForeseeBaseURLKey] : @"http://survey.foreseeresults.com/survey/display";
    clientId = configuration[kMPForeseeClientIdKey];
    surveyId = configuration[kMPForeseeSurveyIdKey];
    sendAppVersion = [configuration[kMPForeseeSendAppVersionKey] caseInsensitiveCompare:@"true"] == NSOrderedSame;
}

#pragma mark MPKitInstanceProtocol methods
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    MPKitExecStatus *execStatus = nil;
    
    if (![self isValidConfiguration:configuration]) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeRequirementsNotMet];
        return execStatus;
    }
    
    _configuration = configuration;
    _started = YES;
    
    [self setupWithConfiguration:configuration];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
    
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (NSString *)surveyURLWithUserAttributes:(NSDictionary *)userAttributes {
    NSString * (^encodeString)(NSString *) = ^ (NSString *originalString) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSString *encodedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                        (__bridge CFStringRef)originalString,
                                                                                                        NULL,
                                                                                                        (__bridge CFStringRef)@";/?@&+{}<>,=",
                                                                                                        kCFStringEncodingUTF8);
#pragma clang diagnostic pop
        
        return encodedString;
    };
    
    NSMutableString *surveyURL = [[NSMutableString alloc] initWithString:baseURL];
    
    // Client, Survey, and Respondent Ids
    CFUUIDRef UUIDRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *respondentId = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, UUIDRef);
    CFRelease(UUIDRef);
    
    [surveyURL appendFormat:@"?cid=%@&sid=%@&rid=%@", encodeString(clientId), encodeString(surveyId), respondentId];
    
    BOOL cppsIncluded = NO;
    
    // App Version
    if (sendAppVersion) {
        NSDictionary *bundleInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = bundleInfoDictionary[@"CFBundleShortVersionString"];
        
        if (appVersion) {
            [surveyURL appendFormat:@"&cpps=cpp%@app_version%@%@%@", encodeString(@"["), encodeString(@"]"), encodeString(@"="), appVersion];
            cppsIncluded = YES;
        }
    }
    
    // User attributes
    if (userAttributes) {
        NSEnumerator *attributeEnumerator = [userAttributes keyEnumerator];
        NSString *key;
        id value;
        Class NSDateClass = [NSDate class];
        Class NSStringClass = [NSString class];
        
        while ((key = [attributeEnumerator nextObject])) {
            value = userAttributes[key];
            
            if ([value isKindOfClass:NSDateClass]) {
                value = [MPDateFormatter stringFromDateRFC3339:value];
            } else if (![value isKindOfClass:NSStringClass]) {
                value = [value stringValue];
            }
            
            if (cppsIncluded) {
                [surveyURL appendString:@"&"];
            } else {
                [surveyURL appendString:@"&cpps="];
                cppsIncluded = YES;
            }
            
            [surveyURL appendFormat:@"cpp%@%@%@%@%@", encodeString(@"["), encodeString(key), encodeString(@"]"), encodeString(@"="), encodeString(value)];
        }
    }
    
    return surveyURL;
}

@end
