//
//  NSData+CLCRC16.h
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (CLCRC16)

//Nsdata  CRC 校验 ，返回data
-(NSData*)crc16 ;

//Nsdata 转化成 hex字符串
- (NSString *)hexadecimalString;

@end

NS_ASSUME_NONNULL_END
