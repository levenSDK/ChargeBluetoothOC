//
//  UpdateVehicleWhitelist.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/27.
//

#import "UpdateVehicleWhitelist.h"
#import "Const.h"

@implementation UpdateVehicleWhitelist

-(NSData *)jsonToPayload:(NSDictionary *)json{
    NSString *vins = json[@"0x02"];
    NSArray *vinArr = [vins componentsSeparatedByString:@","];
    
    NSUInteger size = vinArr.count * 17;
    Byte payload_bytes[size];
    int i=0;
    for (NSString *tempVin in vinArr) {
        [super writeStringToBytesArray:payload_bytes :tempVin :i*17];
        i++;
    }
    NSData *data = [NSData dataWithBytes:&payload_bytes length:sizeof(payload_bytes)];
    [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":data}];
    return data;
}

@end
