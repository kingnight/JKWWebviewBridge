//
//  ViewController.m
//  JKWWebviewBridgeDemo
//
//  Created by jinkai on 15/9/11.
//  Copyright (c) 2015年 jinkai. All rights reserved.
//

#import "ViewController.h"
#import "JKWWebviewBridge.h"

@interface ViewController ()
@property (nonatomic,strong) JKWBridge *bridge;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *bundleUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSString* htmlData = [[NSString alloc] initWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    
    self.bridge = [[JKWBridge alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height) withHtmlData:htmlData withBaseURL:bundleUrl delegate:nil rootViewController:self];
    
    [self.view addSubview:self.bridge];
    
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [messageButton setTitle:@"Send message" forState:UIControlStateNormal];
    [messageButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:messageButton aboveSubview:self.bridge];
    messageButton.frame = CGRectMake(10, 414, 100, 35);
    messageButton.titleLabel.font = font;
    messageButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:self.bridge];
    callbackButton.frame = CGRectMake(110, 414, 100, 35);
    callbackButton.titleLabel.font = font;
    
    [_bridge registerHandler:@"testObjcHandler" handler:^(id data, JKWResponseCallback responseCallback) {
        NSLog(@"testObjcHandler responded: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
}

- (void)sendMessage:(id)sender {
    [_bridge send:@"A string sent from ObjC to JS" responseCallback:^(id response) {
        NSLog(@"sendMessage got response: %@", response);
    }];
}

- (void)callHandler:(id)sender {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
