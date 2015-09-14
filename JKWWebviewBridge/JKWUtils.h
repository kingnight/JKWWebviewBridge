//
//  JKWUtils.h
//  JKView
//
//  Created by jinkai on 15/9/9.
//  Copyright (c) 2015年 pioneer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKWUtils : NSObject

- (NSArray *) getImgUrlWithString:(NSString *)str;
- (NSString *) replaceImgSrcTagWithString:(NSString *)str;
- (NSArray *) scanImgeUrlWithString:(NSString *)str;

@end
