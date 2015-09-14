//
//  JKWBridge.m
//  JKWBridge
//
//  Created by jinkai on 15/9/8.
//  Copyright (c) 2015年 pioneer. All rights reserved.
//

#import "JKWBridge.h"
#import <WebKit/WebKit.h>

const static int ProgessHeight  =  5;

#define JKW_ENABLE_JS_ALERT 1
#define JKW_ENABLE_JS_LOG 1

#define JKW_MSG_Handler @"sendMsgHandler"
#define JKW_CONSOLE_Handler @"consoleHandler"

@interface JKWBridge() <WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>
{
    BOOL debugFlag;
    long _uniqueId;
}

@property (nonatomic,strong) WKWebView *webview;
@property (nonatomic,strong) UIProgressView *progressview;
@property (nonatomic,strong) UIViewController *rootViewController;

@property (nonatomic,strong) NSMutableDictionary *messageHandlers;
@property (nonatomic,strong) NSMutableDictionary *responseCallbacks;

@end

@implementation JKWBridge

#pragma mark init
- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class"
                                 userInfo:nil];
    return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-initWithFrame is not a valid initializer for the class"
                                 userInfo:nil];
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-initWithCoder is not a valid initializer for the class"
                                 userInfo:nil];
    return nil;
}

- (id)initWithFrame:(CGRect)frame
                 withHtmlData:(NSString*)htmlData
                  withBaseURL:(NSURL*)bsURL
                     delegate:(id<JKWBridgeDelegate>)delegate
           rootViewController:(UIViewController *)rootViewController
{
    self = [super initWithFrame:frame];
    if (self) {
        self.rootViewController = rootViewController;
        debugFlag = NO;
        _uniqueId = 0;
        self.messageHandlers = [NSMutableDictionary dictionary];
        self.responseCallbacks = [NSMutableDictionary dictionary];
        
        self.progressview = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, ProgessHeight)];
        self.progressview.tintColor = [UIColor redColor];
        [self addSubview:self.progressview];
        
        WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
        NSString *frameworkBundleID = @"com.jinkai.JKWWebviewBridge";
        NSBundle *frameworkBundle  = [NSBundle bundleWithIdentifier:frameworkBundleID];
        NSString *bridgeJS = [NSString stringWithContentsOfURL:[frameworkBundle URLForResource:@"JKWBridge" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil];
        WKUserScript *bridgeScript = [[WKUserScript alloc] initWithSource:bridgeJS
                                                           injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                        forMainFrameOnly:YES];
        [webViewConfiguration.userContentController addUserScript:bridgeScript];
        [webViewConfiguration.userContentController addScriptMessageHandler:self name:JKW_MSG_Handler];
        [webViewConfiguration.userContentController addScriptMessageHandler:self name:JKW_CONSOLE_Handler];
        
        NSLog(@"%f %f",self.bounds.size.width,self.bounds.size.height);
        self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, ProgessHeight, self.bounds.size.width, self.bounds.size.height-ProgessHeight) configuration:webViewConfiguration];
        self.webview.navigationDelegate = self;
        self.webview.UIDelegate = self;
        
        [self initWebView:self.webview];
        [self insertSubview:self.webview belowSubview:self.progressview];
        
//        [self.webview addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
        [self.webview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.progressview setProgress:0.0f animated:NO];
        
//        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"http://www.sohu.com"]];
//        [self.webview loadRequest:request];
        [self.webview loadHTMLString:htmlData baseURL:bsURL];
        
    }
    return self;
}

#pragma mark Open API

- (void)send:(id)message
{
    [self _sendData:message responseCallback:nil handlerName:nil];
}

- (void)send:(id)message responseCallback:(JKWResponseCallback)responseCallback
{
    [self _sendData:message responseCallback:responseCallback handlerName:nil];
}

- (void)registerHandler:(NSString*)handlerName handler:(JKWHandler)handler
{
    self.messageHandlers[handlerName] = [handler copy];
}

- (void)callHandler:(NSString*)handlerName
{
    [self _sendData:nil responseCallback:nil handlerName:handlerName];
}

- (void)callHandler:(NSString*)handlerName data:(id)data
{
    [self _sendData:data responseCallback:nil handlerName:handlerName];
}

- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(JKWResponseCallback)responseCallback
{
    [self _sendData:data responseCallback:responseCallback handlerName:handlerName];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
       self.progressview.hidden = self.webview.estimatedProgress == 1;
       self.progressview.progress = self.webview.estimatedProgress;
    }
}

#pragma mark - Webview navigation delegate

- (void)webView:(WKWebView *)wv didFinishNavigation:(WKNavigation *)navigation {
//    if (JKW_ENABLE_JS_LOG) {
//        [wv evaluateJavaScript:@"var enableLog = true" completionHandler:nil];
//    }
    
    if (JKW_ENABLE_JS_LOG) {
        [wv evaluateJavaScript:@"var console = {};console.log = function(msg) {window.webkit.messageHandlers.consoleHandler.postMessage(msg);};" completionHandler:nil];
    }
    
    if (!JKW_ENABLE_JS_ALERT) {
        [wv evaluateJavaScript:@"function alert(){}; function prompt(){}; function confirm(){}" completionHandler:nil];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"load webview fail with error %@",[error description]);
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
//    [self.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *openUrl = navigationAction.request.URL;
    NSLog(@"openUrl = %@",openUrl);
    
    if ([openUrl.scheme isEqualToString:@"itms-apps:"]) {
        [[UIApplication sharedApplication] openURL:openUrl];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKScriptMessageHandler delegate

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:JKW_MSG_Handler]) {
        NSLog(@"message.body=%@",message.body);
        [self parseMsgFromJS:message.body];
    }
    else if ([message.name isEqualToString:JKW_CONSOLE_Handler]){
        if ([message.body isKindOfClass:[NSString class]]) {
            NSLog(@"JS Console:%@",message.body);
        }
    }
}

#pragma mark  - WKUIDelegate 
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
     [self.rootViewController presentViewController:alertController animated:YES completion:completionHandler];
}

#pragma mark JSON
- (NSString *)_serializeMessage:(id)message {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:0 error:nil] encoding:NSUTF8StringEncoding];
}

- (NSArray*)_deserializeMessageJSON:(NSString *)messageJSON {
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

#pragma mark private function

- (void)initWebView:(WKWebView *)wv
{
    wv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    wv.autoresizesSubviews = YES;
    
    wv.allowsBackForwardNavigationGestures = YES;
}
//JS -- OBjc
- (void)parseMsgFromJS:(NSString *)msg
{
    NSError *error =nil;
    NSData *jsonData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    id parsedObj = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    if (parsedObj == nil || error != nil) {
        NSLog(@"json parse error");
        return;
    }
    
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        id msgData = nil;

        JKWResponseCallback responseCallback = NULL;
        //response -- do block
        if ([[parsedObj allKeys] containsObject:@"responseId"])
        {
            NSString *responseId = parsedObj[@"responseId"];
            if (responseId) {
                if ([[parsedObj allKeys] containsObject:@"responseData"]) {
                    msgData = parsedObj[@"responseData"];
                }
                
                responseCallback = self.responseCallbacks[responseId];
                responseCallback(msgData);
                [self.responseCallbacks removeObjectForKey:responseId];
            }
        }
        //callback -- send to JS
        else{
            if ([[parsedObj allKeys] containsObject:@"callbackId"]) {
                NSString *msgCallbackId =parsedObj[@"callbackId"];
                NSLog(@"From JS:callbackId = %@",msgCallbackId);
                
                responseCallback = ^(id responseData) {
                    if (responseData == nil) {
                        responseData = [NSNull null];
                    }
                    
                    NSDictionary* msg = @{ @"responseId":msgCallbackId, @"responseData":responseData };
                    [self _dispatchMessage:msg];
                };
            }
            else
            {
                responseCallback = ^(id ignoreResponseData) {
                    // Do nothing
                };
            }
            
            if ([[parsedObj allKeys] containsObject:@"data"]) {
                msgData = parsedObj[@"data"];
            }
            
            JKWHandler handler;
            if ([[parsedObj allKeys] containsObject:@"handlerName"]) {
                NSString *handlerName = parsedObj[@"handlerName"];
                handler = self.messageHandlers[handlerName];
            
                if (handler) {
                    handler(msgData,responseCallback);
                }
                else
                    NSLog(@"error handler %d",__LINE__);
                
            }
        }


    }
    else
    {
        NSLog(@"Msg From JS data Error");
    }
}

- (void) _evaluateJavascript:(NSString *)javascriptCommand {
    [self.webview evaluateJavaScript:javascriptCommand completionHandler:nil];
}


- (void) _dispatchMessage:(NSDictionary *)message
{
    NSString *messageJSON = [self _serializeMessage:message];
    
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    NSLog(@"messageJSON=%@",messageJSON);
    NSString* javascriptCommand = [NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON];
    
    if ([[NSThread currentThread] isMainThread]) {
        [self _evaluateJavascript:javascriptCommand];
        
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _evaluateJavascript:javascriptCommand];
        });
    }
}
//OBjc -- JS
- (void)_sendData:(id)data responseCallback:(JKWResponseCallback)responseCallback handlerName:(NSString*)handlerName {
    NSMutableDictionary* message = [NSMutableDictionary dictionary];
    
    if (data) {
        message[@"data"] = data;
    }
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        self.responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    
    if (handlerName) {
        message[@"handlerName"] = handlerName;
    }
    
    [self _dispatchMessage:message];

}







@end
