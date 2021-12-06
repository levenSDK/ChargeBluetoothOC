//
//  StartChargeSuccessResult.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/28.
//

#import "StartChargeSuccessResult.h"
#import "Const.h"

@implementation StartChargeSuccessResult

-(NSDictionary *)payloadToJson:(NSData *)payload{
    const uint8_t *bytes = [payload bytes];
    NSString *orderNum = @"";
    for (int i = 0; i < 6; i ++) {
        int a = bytes[i];
        int b = a >> 4;
        int c = a - (b << 4);
        orderNum = [NSString stringWithFormat:@"%d%d%@",b,c,orderNum];
    }
    NSInteger timestamp = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(6, 6)]];
    return @{@"orderNum":orderNum,@"cd_timestamp":[NSString stringWithFormat:@"%ld",timestamp]};
}

-(NSData *)jsonToPayload:(NSDictionary *)json{
    NSDictionary *dict = json[@"0xA1"];
    NSString *orderNum = dict[@"orderNum"];
    NSString *cd_timestamp = dict[@"cd_timestamp"];
    
    Byte payload_bytes[12] = {0x00};
    
    //@"123456789011"
    /**
     @"123456789011"
     小端存储 8421码
     0x11 0x90 0x78 0x56 0x34 0x12
     */
    int p = 0;
    for (int i = 11; i > 0; i-=2) {
        int a = [[orderNum substringWithRange:NSMakeRange(i, 1)] intValue];
        int b = [[orderNum substringWithRange:NSMakeRange(i-1, 1)] intValue];
        payload_bytes[p++] = b*16 + a;
    }
    
    /*
     @"1627446337425"
     00000001 01111010 11101011 01011100 01011111 10010001
        1       122       235      92       95      145
     */
    NSInteger a = [cd_timestamp integerValue];
    do {
        NSInteger b = a >> 8;
        payload_bytes[p++] = a - (b << 8);
        a = b;
    } while (a > 0);
    NSData *data = [NSData dataWithBytes:&payload_bytes length:sizeof(payload_bytes)];
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
