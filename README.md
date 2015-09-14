JKWWebviewBridge
=======================

An iOS bridge for sending messages between Obj-C and JavaScript in WKWebview for iOS8+, and include Progress bar show loading status in UIView.

Setup
----------------------------

To use a JKWWebviewBridge in your own project:
  
1) Import framework 

	JKWWebviewBridge.framework:

2) Include header file

	#import "JKWWebviewBridge.h"

3) init

    initWithFrame:(CGRect)frame withHtmlData (NSString*)htmlData withBaseURL:(NSURL*)bsURL delegate:(id<JKWBridgeDelegate>)delegate rootViewController:(UIViewController *)rootViewController

Support 
------------------------------------
iOS 8 +

API Reference
-------------

### ObjC API

##### `initWithFrame:(CGRect)frame withHtmlData (NSString*)htmlData withBaseURL:(NSURL*)bsURL delegate:(id<JKWBridgeDelegate>)delegate rootViewController:(UIViewController *)rootViewController`

Create a JKWBridge View support interaction between Objc and Javascript.


##### `[bridge send:(id)data]`
##### `[bridge send:(id)data responseCallback:(JKWResponseCallback)responseCallback]`

Send a message to javascript. Optionally expect a response by giving a `responseCallback` block.

Example:

	[self.bridge send:@"Hi"];
	[self.bridge send:[NSDictionary dictionaryWithObject:@"Foo" forKey:@"Bar"]];
	[self.bridge send:@"I expect a response!" responseCallback:^(id responseData) {
		NSLog(@"Got response! %@", responseData);
	}];

##### `[bridge registerHandler:(NSString*)handlerName handler:(JKWHandler)handler]`

Register a handler called `handlerName`. The javascript can then call this handler with `WebViewJavascriptBridge.callHandler("handlerName")`.

Example:

	[self.bridge registerHandler:@"getScreenHeight" handler:^(id data, WVJBResponseCallback responseCallback) {
		responseCallback(data);
	}];

##### `[bridge callHandler:(NSString*)handlerName data:(id)data]`
##### `[bridge callHandler:(NSString*)handlerName data:(id)data responseCallback:(JKWResponseCallback)callback]`

Call the javascript handler called `handlerName`. Optionally expect a response by giving a `responseCallback` block.

Example:

	[self.bridge callHandler:@"showAlert" data:@"Hi from ObjC to JS!"];
	[self.bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];


### Javascript API

##### `bridge.send("Hi there!")`
##### `bridge.send({ Foo:"Bar" })`
##### `bridge.send(data, function responseCallback(responseData) { ... })`

Send a message to ObjC. Optionally expect a response by giving a `responseCallback` function.

Example:

	bridge.send("Hi there!")
	bridge.send("Hi there!", function(responseData) {
		alert("I got a response! "+JSON.stringify(responseData))
	})

##### `bridge.registerHandler("handlerName", function(responseData) { ... })`

Register a handler called `handlerName`. The ObjC can then call this handler with `[bridge callHandler:"handlerName" data:@"Foo"]` and `[bridge callHandler:"handlerName" data:@"Foo" responseCallback:^(id responseData) { ... }]`

Example:

	bridge.registerHandler("showAlert", function(data) { alert(data) })
	bridge.registerHandler("getCurrentPageUrl", function(data, responseCallback) {
		responseCallback(document.location.toString())
	})


Thanks
---------------------------

Insights and Many program copy From  [WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge).



