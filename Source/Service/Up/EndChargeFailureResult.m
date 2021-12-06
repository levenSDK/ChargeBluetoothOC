//
//  EndChargeFailureResult.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/28.
//

#import "EndChargeFailureResult.h"
#import "Const.h"

@implementation EndChargeFailureResult

-(NSDictionary *)payloadToJson:(NSData *)payload{
    const uint8_t *bytes = [payload bytes];
    NSString *orderNum = @"";
    for (int i = 0; i < 6; i ++) {
        int a = bytes[i];
        int b = a >> 4;
        int c = a - (b << 4);
        orderNum = [NSString stringWithFormat:@"%d%d%@",b,c,orderNum];
    }
    NSInteger failCode = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(6, 2)]];
    NSData *failReason_data = [payload subdataWithRange:NSMakeRange(8, payload.length-8)];
    NSUInteger length = failReason_data.length;
    const uint8_t *failReason_bytes = [failReason_data bytes];
    Byte temp[length];
    int t = 0;
    for (int i = length-1; i >=0; i--) {
        temp[t++] = failReason_bytes[i];
    }
    NSData *reverse_data = [NSData dataWithBytes:&temp length:length];
    NSString *failReason = [[NSString alloc] initWithData:reverse_data encoding:NSUTF8StringEncoding];
    return @{@"orderNum":orderNum,@"failCode":[NSNumber numberWithInteger:failCode],@"failReason":failReason};
}

-(NSData *)jsonToPayload:(NSDictionary *)json{
    NSDictionary *dict = json[@"0xA5"];
    NSString *orderNum = dict[@"orderNum"];
    NSString *failCode = dict[@"failCode"];
    NSString *failReason = dict[@"failReason"];
    
    Byte orderNum_bytes[8] = {0x00};
    int p = 0;
    for (int i = 11; i > 0; i-=2) {
        int a = [[orderNum substringWithRange:NSMakeRange(i, 1)] intValue];
        int b = [[orderNum substringWithRange:NSMakeRange(i-1, 1)] intValue];
        orderNum_bytes[p++] = b*16 + a;
    }
    
    NSInteger a = [failCode integerValue];
    do {
        NSInteger b = a >> 8;
        orderNum_bytes[p++] = a - (b << 8);
        a = b;
    } while (a > 0);
    
    NSData *failReason_data = [failReason dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger length = failReason_data.length;
    const uint8_t *bytes = [failReason_data bytes];
    Byte temp[length];
    int t = 0;
    for (int i = length-1; i >=0; i--) {
        temp[t++] = bytes[i];
    }
    
    NSMutableData *temp_data = [NSMutableData data];
    [temp_data appendData:[NSData dataWithBytes:&orderNum_bytes length:sizeof(orderNum_bytes)]];
    [temp_data appendData:[NSData dataWithBytes:&temp length:length]];
    [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":temp_data}];
    return temp_data;
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
