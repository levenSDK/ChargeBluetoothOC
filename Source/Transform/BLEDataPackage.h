//
//  BLEDataPackage.h
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//生成header crc校验,payload组装
@interface BLEDataPackage : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)shareBLEDataPackageManager;

-(NSData *)generateWithCode:(Byte)hexCode payload:(NSData *)payload;
//计算crc16
-(NSData *)calculateCRC16WithHeader:(NSData *)header payload:(NSData *)payload;

@end

NS_ASSUME_NONNULL_END
