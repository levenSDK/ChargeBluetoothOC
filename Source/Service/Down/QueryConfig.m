//
//  QueryConfig.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/28.
//

#import "QueryConfig.h"
#import "Const.h"

@implementation QueryConfig

-(NSData *)jsonToPayload:(NSDictionary *)json{

//    NSDictionary *dict = json[@"0x06"];
//    NSString *device_id = dict[@"device_id"];
//    NSString *HB_period = dict[@"HB_period"];
//    NSString *ble_key = dict[@"ble_key"];
//    NSString *hardwareVersion = dict[@"hardwareVersion"];
//    NSString *softwareVersion = dict[@"softwareVersion"];
//    
//    Byte payload_bytes[57] = {0x00};
//    [super writeStringToBytesArray:payload_bytes :device_id :0];
//    int temp_period = [HB_period intValue];
//    payload_bytes[30] = temp_period;
//    [super writeStringToBytesArray:payload_bytes :ble_key :31];
//    [super writeStringToBytesArray:payload_bytes :hardwareVersion :37];
//    [super writeStringToBytesArray:payload_bytes :softwareVersion :47];
//    NSData *data = [NSData dataWithBytes:&payload_bytes length:sizeof(payload_bytes)];
//    [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":data}];
//    return data;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":@""}];
    return nil;
}

-(NSDictionary *)payloadToJson:(NSData *)payload{
    const uint8_t *bytes = [payload bytes];

    NSString *device_id = [NSString stringWithFormat:@"%s",bytes];
    NSInteger HB_period = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(30, 1)]];
    const uint8_t *ble_key = [[payload subdataWithRange:NSMakeRange(31, 6)] bytes];
    const uint8_t *hardwareVersion = [[payload subdataWithRange:NSMakeRange(37, 10)] bytes];
    const uint8_t *softwareVersion = [[payload subdataWithRange:NSMakeRange(47, 10)] bytes];
    
    NSDictionary *json = @{@"device_id":[self flipOverString:device_id],@"HB_period":[NSNumber numberWithInteger:HB_period],@"ble_key":[self flipOverString:[NSString stringWithFormat:@"%s",ble_key]],
                                                                                                                                        @"hardwareVersion":[self flipOverString:[NSString stringWithFormat:@"%s",hardwareVersion]],
                                                                                                                                                            @"softwareVersion":[self flipOverString:[NSString stringWithFormat:@"%s",softwareVersion]]};
//    NSLog(@"json %@",json);
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

- (NSString *)flipOverString:(NSString *)originStr {
    NSString *result = @"";
    for (NSInteger i = originStr.length -1; i >= 0; i--) {
        NSString *subStr = [originStr substringWithRange:NSMakeRange(i, 1)];
        result = [result stringByAppendingString:subStr];
    }
    return result;
}


@end
