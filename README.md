![Logo](https://github.com/moengage/MoEngage-Segment-iOS/blob/supportForMoEVersion7.0.0/Images/moe_logo_blue.png)
# MoEngage-Segment-iOS

[![Version](https://img.shields.io/cocoapods/v/Segment-MoEngage.svg?style=flat)](http://cocoapods.org/pods/Segment-MoEngage)
[![License](https://img.shields.io/cocoapods/l/Segment-MoEngage.svg?style=flat)](http://cocoapods.org/pods/Segment-MoEngage)


MoEngage integration for analytics-ios.

## Installation:

MoEngage can be integrated via Segment using [CocoaPods](http://cocoapods.org). 
  * Initialise pod with pod init command, this will create a podfile for your project.
  * Update your podfile by adding pod '**Segment-MoEngage**' as shown below:

  ```ruby
  use_frameworks!
  pod 'Segment-MoEngage’
  ```

   * Update the pod. 
   
    pod update

## Setup Segment SDK:

Now head to the the App Delegate, and setup the Segment SDK :

### Objective-C:

 ```
 #import <SEGMoEngageIntegrationFactory.h> // This line is key for MoEngage integration
 #import <SEGAnalytics.h>

 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Add your configuration key from Segment
    SEGAnalyticsConfiguration *config = [SEGAnalyticsConfiguration configurationWithWriteKey:@"configuration key"];
    
    // Add MoEngageIntegrationFactory. Without this data will not come to MoEngage.
    [config use:[SEGMoEngageIntegrationFactory instance]];
    [SEGAnalytics setupWithConfiguration:config];
  }
  ```
 
 
### Swift:

 ```
 import Segment_MoEngage
 ...
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey:  Any]?) -> Bool {
 ...
	 // Add your configuration key from Segment
	 let config = SEGAnalyticsConfiguration(writeKey:"configuration key")
  
	 // Add MoEngageIntegrationFactory. Without this data will not come to MoEngage.
	 config.use(SEGMoEngageIntegrationFactory.instance())
	 SEGAnalytics.setup(with: config)
 ...
 }
 ```

## Setup MoEngage in Segment Dashboard:

To setup MoEngage do the following : 
  1. First get your key([AppID](http://app.moengage.com/v3/#/settings/0/0)) from MoEngage dashboard. 
  2. Go to **Segment dashboard**, go to **Integrations** and select **MoEngage**. 
  3. Enable MoEngage Integration.
  4. Go to MoEngage Settings and enter the MoEngage AppID, obtained in **Step1**.
  5. Save the changes.
  
  ![Segment Dashboard Settings](https://user-images.githubusercontent.com/15011722/31998605-085158de-b9ae-11e7-9729-c637b6bbc083.png)
  
These new settings will take up to an hour to propogate to all of your existing users. For new users it’ll be instanteneous! Segment-MoEngage Integration is a bundled integration, requires client side integration.

## Tracking User Attribute

User attributes are specific traits of a user, like email, username, mobile, gender etc. **identify** lets you tie a user to their actions and record traits about them. It includes a unique User ID and any optional traits you know about them.

 ```[[SEGAnalytics sharedAnalytics] identify:@"a user's id" traits:@{ @"email": @"a user's email address" }];```

For more info refer to this [link](https://segment.com/docs/sources/mobile/ios/#identify).

## Tracking Events

Event tracking is used to track user behaviour in an app. **track** lets you record the actions your users perform. Every action triggers i.e,“event”, which can also have associated attributes.

 ```[[SEGAnalytics sharedAnalytics] track:@"Item Purchased" properties:@{ @"item": @"Sword of Heracles"}];```

That's all you need for tracking data. For more info refer this [link](https://segment.com/docs/sources/mobile/ios/#track).

## Reset Users

The *reset* method clears the SDK’s internal stores for the current user. This is useful for apps where users can log in and out with different identities over time.

 ```[[SEGAnalytics sharedAnalytics] reset];```

For more info refer to this [link](https://segment.com/docs/sources/mobile/ios/#reset).

## Install / Update Differentiation 

Since you might integrate us when your app is already on the App Store, we would need to know whether your app update would be an actual UPDATE or an INSTALL.
To differentiate between those, use one of the method below:

 ```
 //For new Install call following
 [[MoEngage sharedInstance] appStatus:INSTALL];

 //For an app update call following
 [[MoEngage sharedInstance] appStatus:UPDATE];
 ```

For more info on this refer following [link](https://docs.moengage.com/docs/installupdate-differentiation).

## Using features provided in MoEngage SDK

Along with tracking your user's activities, MoEngage iOS SDK also provides additional features which can be used for more effective user engagement:

### Push Notifications:
Push Notifications are a great way to keep your users engaged and informed about your app. You have following options while implementing push notifications in your app:

#### Segment Push Implementation:

1.Follow the directions to register for push using Segment SDK in this [link](https://segment.com/docs/libraries/ios/#how-do-i-use-push-notifications-).

2.In your application’s application:didReceiveRemoteNotification: method, add the following:

 ```[[SEGAnalytics sharedAnalytics] receivedRemoteNotification:userInfo];```

3.If you integrated the application:didReceiveRemoteNotification:fetchCompletionHandler: in your app, add the following to that method:
 
 ```[[SEGAnalytics sharedAnalytics] receivedRemoteNotification:userInfo];```

4.If you implemented handleActionWithIdentifier:forRemoteNotification:, add the following to that method:

 ```[[SEGAnalytics sharedAnalytics] handleActionWithIdentifier:identifier forRemoteNotification:userInfo];```
 
#### MoEngage Push Implementation:
 Follow this link to implement Push Notification in your mobile app using MoEngage SDK : 
 [**Push Notifications**](https://docs.moengage.com/docs/push-notifications)


### In-App Messaging:

In-App Messaging are custom views which you can send to a segment of users to show custom messages or give new offers or take to some specific pages. Follow the link to know more about  inApp Messaging and how to implement it in your application: 
[**InApp NATIV**](https://docs.moengage.com/docs/in-app-nativ)

## Segment Docs:
For more info on using **Segment for iOS** refer to [**Developer Docs**](https://segment.com/docs/sources/mobile/ios/) provided by Segment.
  
## Change Log
See [SDK Change Log](https://github.com/moengage/MoEngage-Segment-iOS/blob/master/CHANGELOG.md) for information on every released version.

## Support
Please visit this repository's [Github issue tracker](https://github.com/moengage/MoEngage-Segment-iOS/issues) for bug reports specific to our iOS SDK.
For other issues and support please contact MoEngage support from your dashboard.
