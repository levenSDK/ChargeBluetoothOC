//
//  BLEConnection.h
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/25.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN
/**
 处理蓝牙发现设备,连接和中断
 */
@interface BLEConnection : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

//发现蓝牙设备
+ (instancetype)shareBLEConnectionManager;
//开始连接
-(void)startConnection: (NSString *)code;//connect
//断开连接
-(void)cancelConnection;//disconnect
//接收通知
-(void)startNotifiy;//notifiy


//获取已连接的外设
-(CBPeripheral *)getPeripheral;
//获取已连接的外设的特征
-(CBCharacteristic *)getCharacteristic;

//获取已连接的外设的特征-读写
-(CBCharacteristic *)getCharacteristicWrite;
@end

NS_ASSUME_NONNULL_END
