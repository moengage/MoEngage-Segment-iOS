#import "SEGMoEngageIntegration.h"
#import <MoEngage/MoEngage.h>
#import "SEGAnalytics.h"

#define SegmentAnonymousIDAttribute @"USER_ATTRIBUTE_SEGMENT_ID"
#define SegmentMoEngageVersion @"4.0.0"

@implementation SEGMoEngageIntegration

#pragma mark- Initialization method

-(id)initWithSettings:(NSDictionary *)settings
{
    if (self = [super init]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.settings = settings;
            NSString *apiKey = [self.settings objectForKey:@"apiKey"];
            
#ifdef DEBUG
            [[MoEngage sharedInstance] initializeDevWithApiKey:apiKey inApplication:[UIApplication sharedApplication] withLaunchOptions:nil openDeeplinkUrlAutomatically:YES];
#else
            [[MoEngage sharedInstance] initializeProdWithApiKey:apiKey inApplication:[UIApplication sharedApplication] withLaunchOptions:nil openDeeplinkUrlAutomatically:YES];
#endif
        });
        
        NSString* segmentAnonymousID = [[SEGAnalytics sharedAnalytics] getAnonymousId];
        if(segmentAnonymousID != nil){
            NSLog(@"Anonymous ID :  %@",segmentAnonymousID);
            [[MoEngage sharedInstance] setUserAttribute:segmentAnonymousID forKey:SegmentAnonymousIDAttribute];
        }
        [[NSUserDefaults standardUserDefaults] setObject:SegmentMoEngageVersion forKey:MoEngage_Segment_SDK_Version];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return self;
}



#pragma mark- Application Life cycle methods

-(void)applicationDidFinishLaunching:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]){
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
    });
}

#pragma mark- Push Notification methods

-(void)registeredForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[MoEngage sharedInstance] setPushToken:deviceToken];
}

- (void)failedToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[MoEngage sharedInstance] didFailToRegisterForPush];
}

- (void)receivedRemoteNotification:(NSDictionary *)userInfo
{
    [[MoEngage sharedInstance] didReceieveNotificationinApplication:[UIApplication sharedApplication] withInfo:userInfo openDeeplinkUrlAutomatically:YES];
}

- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo{
    [[MoEngage sharedInstance] handleActionWithIdentifier:identifier forRemoteNotification:userInfo];
}

#pragma mark- Segment callback methods

- (void)identify:(SEGIdentifyPayload *)payload
{
    @try {
        NSDictionary *moengagePayloadDict = [payload.traits copy];
        
        if (payload.anonymousId != nil) {
            [[MoEngage sharedInstance] setUserAttribute:payload.anonymousId forKey:SegmentAnonymousIDAttribute];
        }
        
        if(payload.userId != nil){
            [[MoEngage sharedInstance] setUserAttribute:payload.userId forKey:USER_ATTRIBUTE_UNIQUE_ID];
        }
        
        NSMutableDictionary *traits = [NSMutableDictionary dictionaryWithDictionary:moengagePayloadDict];
        if(![traits count]){
            return;
        }
        
        if ([traits objectForKey:@"id"]) {
            [[MoEngage sharedInstance] setUserUniqueID:[traits objectForKey:@"id"]];
            [traits removeObjectForKey:@"id"];
        }
        
        if ([traits objectForKey:@"email"]) {
            [[MoEngage sharedInstance] setUserEmailID:[traits objectForKey:@"email"]];
            [traits removeObjectForKey:@"email"];
        }
        
        if ([traits objectForKey:@"name"]) {
            [[MoEngage sharedInstance] setUserName:[traits objectForKey:@"name"]];
            [traits removeObjectForKey:@"name"];
        }
        
        if ([traits objectForKey:@"phone"]) {
            [[MoEngage sharedInstance] setUserMobileNo:[traits objectForKey:@"phone"]];
            [traits removeObjectForKey:@"phone"];
        }
        
        if ([traits objectForKey:@"firstName"]) {
            [[MoEngage sharedInstance] setUserAttribute:[traits objectForKey:@"firstName"] forKey:USER_ATTRIBUTE_USER_FIRST_NAME];
            [traits removeObjectForKey:@"firstName"];
        }
        
        if ([traits objectForKey:@"lastName"]) {
            [[MoEngage sharedInstance] setUserLastName:[traits objectForKey:@"lastName"]];
            [traits removeObjectForKey:@"lastName"];
        }
        
        if ([traits objectForKey:@"gender"]) {
            [[MoEngage sharedInstance] setUserAttribute:[traits objectForKey:@"gender"] forKey:USER_ATTRIBUTE_USER_GENDER];
            [traits removeObjectForKey:@"gender"];
        }
        
        if ([traits objectForKey:@"birthday"]) {
            id birthdayVal = [traits objectForKey:@"birthday"];
            if (birthdayVal != nil){
                [self identifyDateUserAttribute:birthdayVal withKey:USER_ATTRIBUTE_USER_BDAY];
            }
            [traits removeObjectForKey:@"birthday"];
        }
        
        if ([traits objectForKey:@"address"]) {
            [[MoEngage sharedInstance] setUserAttribute:[traits objectForKey:@"address"] forKey:@"address"];
            [traits removeObjectForKey:@"address"];
        }
        
        if ([traits objectForKey:@"age"]) {
            [[MoEngage sharedInstance] setUserAttribute:[traits objectForKey:@"age"] forKey:@"age"];
            [traits removeObjectForKey:@"age"];
        }
        for (NSString *key in [traits allKeys]) {
            id value = [traits objectForKey:key];
            if (value != nil){
                [self identifyDateUserAttribute:value withKey:key];
            }
        }
    }
    @catch (NSException *exception) {
        // Possible if value is an unsupported type in the dictionary
        NSLog(@"Segment - MoEngage - Exception while adding traits is %@", exception);
    }
}

-(void)identifyDateUserAttribute:(id)value withKey:(NSString*)attr_name{
    if ([value isKindOfClass:[NSString class]]) {
        NSDate* converted_date = [SEGMoEngageIntegration dateFromISOdateStr:value];
        if (converted_date != nil) {
            [[MoEngage sharedInstance] setUserAttributeTimestamp:[converted_date timeIntervalSince1970] forKey:attr_name];
            return;
        }
    }
    [[MoEngage sharedInstance] setUserAttribute:value forKey:attr_name];
}

-(void)alias:(SEGAliasPayload *)payload{
    @try{
        id newID = payload.theNewId;
        if (newID != nil){
            if ([[MoEngage sharedInstance] respondsToSelector:@selector(setAlias:)]){
                [[MoEngage sharedInstance] setAlias:newID];
            }
        }
    }
    @catch(NSException *exception) {
        NSLog(@"Segment - MoEngage - Exception while setAlias is %@", exception);
    }
}

- (void)track:(SEGTrackPayload *)payload
{
    @try{
        if (payload.properties != nil) {
            MOPayloadBuilder* moe_payload = [[MOPayloadBuilder alloc] init];
            NSMutableDictionary* finalTrackDict = [NSMutableDictionary dictionaryWithDictionary:payload.properties];
            
            for (NSString* key in payload.properties.allKeys) {
                id val = [payload.properties valueForKey:key];
                if (val == nil || val == [NSNull null]) {
                    continue;
                }
                else if ([val isKindOfClass:[NSString class]]){
                    NSDate* converted_date = [SEGMoEngageIntegration dateFromISOdateStr:val];
                    if (converted_date != nil) {
                        [moe_payload setDate:converted_date forKey:key];
                        [finalTrackDict removeObjectForKey:key];
                    }
                }
            }
            
            moe_payload.eventDict = finalTrackDict;
            [[MoEngage sharedInstance] trackEvent:payload.event builderPayload:moe_payload];
        }
        else{
            [[MoEngage sharedInstance] trackEvent:payload.event andPayload:nil];
        }
    }
    @catch(NSException* exception){
        NSLog(@"Segment - MoEngage - Exception while Tracking Event : %@", exception);
    }
}

- (void)flush
{
    [[MoEngage sharedInstance] syncNow];
}


- (void)reset
{
    [[MoEngage sharedInstance] resetUser];
}

#pragma mark- Utils

+(NSDate*)dateFromISOdateStr:(NSString*)isoDateStr{
    if (isoDateStr != nil) {
        static NSDateFormatter *dateFormatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'";
            dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        });
        return [dateFormatter dateFromString:isoDateStr];
    }
    return nil;
}
@end
