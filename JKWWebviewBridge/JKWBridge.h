//
//  JKWBridge.h
//  JKWBridge
//
//  Created by jinkai on 15/9/8.
//  Copyright (c) 2015年 pioneer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JKWBridgeDelegate <NSObject>

@optional

@end

@interface JKWBridge : UIView

typedef void (^JKWResponseCallback)(id responseData);
typedef void (^JKWHandler)(id data, JKWResponseCallback responseCallback);

- (instancetype)initWithFrame:(CGRect)frame
       withHtmlData:(NSString*)htmlData
        withBaseURL:(NSURL*)bsURL
           delegate:(id<JKWBridgeDelegate>)delegate
 rootViewController:(UIViewController *)rootViewController;

- (void)send:(id)message;
- (void)send:(id)message responseCallback:(JKWResponseCallback)responseCallback;
- (void)registerHandler:(NSString*)handlerName handler:(JKWHandler)handler;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(JKWResponseCallback)responseCallback;

@end
