//
//  JKWUtils.m
//  JKView
//
//  Created by jinkai on 15/9/9.
//  Copyright (c) 2015年 pioneer. All rights reserved.
//

#import "JKWUtils.h"

@implementation JKWUtils

/**
 *  正则方式获取html中所有img标签src内容
 *
 *  @param str html内容
 *
 *  @return 图片链接地址数组
 */
- (NSArray *) getImgUrlWithString:(NSString *)str {
    NSMutableArray *imglist = [[NSMutableArray alloc]init];
    NSError *err;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"img\\s+src=\"([^\"]*)\""
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&err];
    //    NSTextCheckingResult *m = [regex firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
    //    if (!NSEqualRanges(m.range, NSMakeRange(NSNotFound, 0))) {
    //        NSLog(@"%@", [str substringWithRange:[m rangeAtIndex:1]]);
    //    }
    NSArray *searchResult = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    for (NSTextCheckingResult *item in searchResult) {
        if (!NSEqualRanges(item.range, NSMakeRange(NSNotFound, 0))) {
            NSString *currentImgUrl = [str substringWithRange:[item rangeAtIndex:1]];
            [imglist addObject:currentImgUrl];
        }
    }
    return imglist;
}
/**
 *  替换<img src>为<img esrc>
 *
 *  @param str html内容
 *
 *  @return 输出替换完成后html内容
 */
- (NSString *) replaceImgSrcTagWithString:(NSString *) str
{
    NSError *err;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"img\\s+src"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&err];
    if (!err) {
        NSRange range = NSMakeRange(0, str.length);
        return [regex stringByReplacingMatchesInString:str options:0 range:range withTemplate:@"img esrc"];
    }
    else {
        NSLog(@"err=%@",[err debugDescription]);
    }
    return nil;
}
/**
 *  使用NSScanner方式获得html中所有img标签src内容
 *
 *  @param str html内容
 *
 *  @return 图片链接地址数组
 */
- (NSArray *) scanImgeUrlWithString:(NSString *)str {
    NSMutableArray *imglist = [[NSMutableArray alloc]init];
    NSString *url = nil;
    NSScanner *theScanner = [NSScanner scannerWithString:str];
    // find start of IMG tag
    while (![theScanner isAtEnd]) {
        [theScanner scanUpToString:@"<img" intoString:nil];
        if (![theScanner isAtEnd]) {
            [theScanner scanUpToString:@"src" intoString:nil];
            NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
            [theScanner scanUpToCharactersFromSet:charset intoString:nil];
            [theScanner scanCharactersFromSet:charset intoString:nil];
            [theScanner scanUpToCharactersFromSet:charset intoString:&url];
            // "url" now contains the URL of the img
            [imglist addObject:url];
        }
    }
    return imglist;
}




@end
