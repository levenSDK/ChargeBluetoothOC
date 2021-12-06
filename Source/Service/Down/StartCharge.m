//
//  StartCharge.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/28.
//

#import "StartCharge.h"
#import "Const.h"

@implementation StartCharge

-(NSData *)jsonToPayload:(NSDictionary *)json{
    NSString *orderNum = json[@"0x03"];
    Byte payload_bytes[6] = {0x00};
    int p = 0;
    for (int i = 11; i > 0; i-=2) {
        int a = [[orderNum substringWithRange:NSMakeRange(i, 1)] intValue];
        int b = [[orderNum substringWithRange:NSMakeRange(i-1, 1)] intValue];
        payload_bytes[p++] = b*16 + a;
    }
    NSData *data = [NSData dataWithBytes:&payload_bytes length:sizeof(payload_bytes)];
    [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":data}];
    return data;
}

@end
