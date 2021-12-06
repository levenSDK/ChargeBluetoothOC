//
//  SyncHistoricalOrder.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/28.
//

#import "SyncHistoricalOrder.h"
#import "Const.h"

@implementation SyncHistoricalOrder

-(NSDictionary *)payloadToJson:(NSData *)payload{
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

-(NSData *)jsonToPayload:(NSDictionary *)json{
    NSDictionary *dict = json[@"0xA6"];
    NSString *orderNum = dict[@"orderNum"];
    NSInteger temperature = [dict[@"temperature"] integerValue];
    NSInteger total = [dict[@"total"] integerValue];
    NSInteger voltage = [dict[@"voltage"] integerValue];
    NSInteger electricity = [dict[@"electricity"] integerValue];
    NSInteger last_timestamp = [dict[@"last_timestamp"] integerValue];
    NSInteger length = [dict[@"length"] integerValue];
    NSInteger start_timestamp = [dict[@"start_timestamp"] integerValue];
    NSInteger end_timestamp = [dict[@"end_timestamp"] integerValue];
    NSInteger section_total = [dict[@"section_total"] integerValue];
    
    Byte previous[34] = {0x00};
    int p = 0;
    for (int i = 11; i > 0; i-=2) {
        int a = [[orderNum substringWithRange:NSMakeRange(i, 1)] intValue];
        int b = [[orderNum substringWithRange:NSMakeRange(i-1, 1)] intValue];
        previous[p++] = b*16 + a;
    }
    
    previous[p++] = temperature;
    
    do {
        NSInteger b = total >> 8;
        previous[p++] = total - (b << 8);
        total = b;
    } while (total > 0);
    //电压
    do {
        NSInteger b = voltage >> 8;
        previous[p++] = voltage - (b << 8);
        voltage = b;
    } while (voltage > 0);
    //电流
    do {
        NSInteger b = electricity >> 8;
        previous[p++] = electricity - (b << 8);
        electricity = b;
    } while (electricity > 0);
    
    do {
        NSInteger b = last_timestamp >> 8;
        previous[p++] = last_timestamp - (b << 8);
        last_timestamp = b;
    } while (last_timestamp > 0);
    
    previous[p++] = length;
    
    do {
        NSInteger b = start_timestamp >> 8;
        previous[p++] = start_timestamp - (b << 8);
        start_timestamp = b;
    } while (start_timestamp > 0);
    
    do {
        NSInteger b = end_timestamp >> 8;
        previous[p++] = end_timestamp - (b << 8);
        end_timestamp = b;
    } while (end_timestamp > 0);
    
    do {
        NSInteger b = section_total >> 8;
        previous[p++] = section_total - (b << 8);
        section_total = b;
    } while (section_total > 0);
    NSData *data = [NSData dataWithBytes:&previous length:34];
    [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":data}];
    return data;
}

-(NSData *)intToByteArrayWithInt:(NSInteger)src length:(int)length{
    Byte b[length];
    for (int i = 0; i < length; i++){
        b[length - i - 1] = (Byte)((src >> 8 * i) & 0xff);
    }
    return [NSData dataWithBytes:&b length:sizeof(b)];
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
