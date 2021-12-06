//
//  QueryChargeState.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/28.
//

#import "QueryChargeState.h"
#import "Const.h"

@implementation QueryChargeState

-(NSData *)jsonToPayload:(NSDictionary *)json{
    NSString *four = json[@"0x04"];
    if (four.length) {
        Byte payload_bytes[1] = {0x00};
        [super writeStringToBytesArray:payload_bytes :four :0];
        NSData *data = [NSData dataWithBytes:&payload_bytes length:sizeof(payload_bytes)];
        [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":data}];
        return data;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":@""}];
    return nil;
}

- (NSDictionary *)payloadToJson:(NSData *)payload {
    NSInteger chargeStatus = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(0, 1)]];
    NSInteger chargePointStatus = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(1, 1)]];
    NSDictionary *json = @{@"chargeStatus" : [NSNumber numberWithInteger:chargeStatus], @"chargePointStatus" : [NSNumber numberWithInteger:chargePointStatus]};
    return json;
}

-(NSInteger)byteArrayToInt:(NSData *)data{
    const uint8_t *bytes = [data bytes];
    Byte b[data.length];
    int idx = 0;
    for (int i = data.length-1; i >= 0; i--) {
        b[idx++] = bytes[i];
    }
    NSInteger value=0;
    int a = 0;
    for(int i = 0; i < data.length; i++) {
        int shift= (data.length-1-i) * 8;
        a = b[i];
        value += (long)a << shift;
    }
    return value;
}
@end
