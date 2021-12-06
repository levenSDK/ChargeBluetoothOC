//
//  BLEDispatcher.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/26.
//

#import "BLEDispatcher.h"
#import "BLEConnection.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDataPackage.h"
#import "ServiceFactory.h"
#import "NSData+CLCRC16.h"

@implementation BLEDispatcher{
    NSData *_diagram_data;
}

+ (instancetype)shareBLEDispatcherManager{
    static BLEDispatcher *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[BLEDispatcher alloc]init];
    });
   return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

-(void)sendWithCode:(Byte)hexCode data:(NSData *)data{
    NSData *diagram_data = [[BLEDataPackage shareBLEDataPackageManager] generateWithCode:hexCode payload:data];
//    NSLog(@"===sendWithCode:%@",hexCode);
//    _diagram_data = diagram_data;
    //TODO:----测试完需要删除的代码
//    if (hexCode >= 0xA1) {
//        [self onReceive];
//    };
    
    CBPeripheral *peripheral = [[BLEConnection shareBLEConnectionManager] getPeripheral];
    if (peripheral == nil || peripheral.state != CBPeripheralStateConnected) {
        NSLog(@"外设不存在或者外设出于非连接状态");
        //需要重新连接
        [[BLEConnection shareBLEConnectionManager] startConnection: nil];
    }
    NSLog(@"code %hhu  ; data: %@", hexCode, diagram_data);
    CBCharacteristic *characteristic = [[BLEConnection shareBLEConnectionManager] getCharacteristicWrite];
    if (characteristic != nil) {
        [peripheral writeValue:diagram_data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    } else {
        NSLog(@"characteristic 为空！");
    }

    if(diagram_data.length>20){
        int size = diagram_data.length / 20;
        for(int i=0;i<size;i++){
            NSString *vehicle = [diagram_data subdataWithRange:NSMakeRange(i*20, 20)];
            NSLog(@"===diagram_data:%@",vehicle);
        }
    }
        
    NSLog(@"===diagram_data:%@",diagram_data);
//    [[BLEConnection shareBLEConnectionManager] startNotifiy];
}

////模拟上行的步骤: 1.先模拟下行,得到nsdata,再用上行的方法回传到controller,
-(void)onReceive{
    const u_int8_t *bytes = [_diagram_data bytes];
    Byte magic_byte = bytes[0];
    if (magic_byte == 0xAB) {
        if (![self chechCRC16:_diagram_data]) {
            NSLog(@"crc校验不通过");
            return;
        }
//        NSLog(@"crc校验通过");
        NSData *payload_data = [_diagram_data subdataWithRange:NSMakeRange(9, _diagram_data.length-9)];
        Byte code = bytes[6];
        [[ServiceFactory shareServiceFactoryManager] executeUpWithCode:code payload:payload_data];
    }
}


-(BOOL)chechCRC16:(NSData *)packet{
    NSData *header = [packet subdataWithRange:NSMakeRange(0, 7)];
    NSData *crc16_packet = [packet subdataWithRange:NSMakeRange(7, 2)];
    NSData *payload = [packet subdataWithRange:NSMakeRange(9, packet.length-9)];
    NSData *cal_crc16= [[BLEDataPackage shareBLEDataPackageManager] calculateCRC16WithHeader:header payload:payload];
    if ([[crc16_packet hexadecimalString] isEqualToString: [cal_crc16 hexadecimalString]]) {
        return YES;
    }
    return NO;
}

@end
