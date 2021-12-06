//
//  ServiceFactory.h
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/26.
//

#import <Foundation/Foundation.h>
#import "BLEDiagram.h"
#import <CoreBluetooth/CBManager.h>

NS_ASSUME_NONNULL_BEGIN
// 公开方法,executeDown  executeUp 参数是指令编码和payload

/**
 
 execute
 1. 调用createInstance，传入指令编码，返回对应的service实例
 2. 如果指令编码是上行指令，调用 service实例的payloadToJson方法，返回JSON对象
 3. 如果指令编码是下行指令，调用 service实例的jsonToPayload方法，返回payload字节数组
 */
@protocol ServiceFactoryDelegate <NSObject>
- (void)didReceive:(Byte)code json:(NSDictionary *)json;
- (void)peripheralConnectedDidChange:(BOOL)isConnected;
- (void)bluetoothStateDidChange:(CBManagerState)state;
@end

@interface ServiceFactory : NSObject
@property (nonatomic, weak) id<ServiceFactoryDelegate> delegate;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)shareServiceFactoryManager;


//下行
-(void)executeDownWithCode:(Byte)hexCode payload:(NSDictionary *)payload;
//上行
-(void)executeUpWithCode:(Byte)hexCode payload:(NSData *)payload;

@end

NS_ASSUME_NONNULL_END
