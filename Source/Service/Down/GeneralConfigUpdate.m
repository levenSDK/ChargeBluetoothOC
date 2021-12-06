//
//  GeneralConfigUpdate.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/26.
//

#import "GeneralConfigUpdate.h"
#import "Const.h"

@implementation GeneralConfigUpdate

-(NSData *)jsonToPayload:(NSDictionary *)json{
    NSDictionary *dict = json[@"0x01"];
    NSString *device_id = dict[@"device_id"];
    NSString *HB_period = dict[@"HB_period"];
    NSString *ble_key = dict[@"ble_key"];
    
    Byte payload_bytes[37] = {0x00};
    [super writeStringToBytesArray:payload_bytes :device_id :0];
    int temp_period = [HB_period intValue];
    //payload_bytes[30] = HB_period 转换成byte
    payload_bytes[30] = temp_period;
    [super writeStringToBytesArray:payload_bytes :ble_key :31];
    NSData *data = [NSData dataWithBytes:&payload_bytes length:sizeof(payload_bytes)];
    [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":data}];
    return data;
}

@end
