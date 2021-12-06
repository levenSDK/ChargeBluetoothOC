//
//  QueryHistoricalOrders.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/28.
//

#import "QueryHistoricalOrders.h"
#import "Const.h"
@implementation QueryHistoricalOrders

-(NSData *)jsonToPayload:(NSDictionary *)json{
    NSString *eight = json[@"0x08"];
    if (eight.length) {
        Byte payload_bytes[1] = {0x00};
        [super writeStringToBytesArray:payload_bytes :eight :0];
        NSData *data = [NSData dataWithBytes:&payload_bytes length:sizeof(payload_bytes)];
        [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":data}];
        return data;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":@""}];
    return nil;
//    Byte datas[1] = {0x00};
//    return [NSData dataWithBytes:datas length:1];
}


-(NSDictionary *)payloadToJson:(NSData *)payload{
    if (payload.length == 0) {
        return  nil;
    }
    const uint8_t *bytes = [payload bytes];
    NSString *orderNum = @"";
    for (int i = 0; i < 6; i ++) {
        int a = bytes[i];
        int b = a >> 4;
        int c = a - (b << 4);
        orderNum = [NSString stringWithFormat:@"%d%d%@",b,c,orderNum];
    }
    
    NSInteger temperature = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(6, 1)]];
    NSInteger total = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(7, 2)]];
    NSInteger voltage = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(9, 2)]];
    NSInteger electricity = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(11, 2)]];
    NSInteger last_timestamp = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(13, 6)]];
    NSInteger length = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(19, 1)]];
    NSInteger start_timestamp = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(20, 6)]];
    NSInteger end_timestamp = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(26, 6)]];
    NSInteger section_total = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(32, 2)]];
    
    NSDictionary *json = @{@"orderNum":orderNum,@"temperature":[NSNumber numberWithInteger:temperature],@"total":[NSNumber numberWithInteger:total],
                           @"voltage":[NSNumber numberWithInteger:voltage],
                           @"electricity":[NSNumber numberWithInteger:electricity],
                           @"last_timestamp":[NSNumber numberWithInteger:last_timestamp],
                           @"length":[NSNumber numberWithInteger:length],
                           @"start_timestamp":[NSNumber numberWithInteger:start_timestamp],
                           @"end_timestamp":[NSNumber numberWithInteger:end_timestamp],
                           @"section_total":[NSNumber numberWithInteger:section_total]};
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
