//
//  QueryVehicleWhitelist.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/28.
//

#import "QueryVehicleWhitelist.h"
#import "Const.h"
#import "Const.h"

@implementation QueryVehicleWhitelist

-(NSData *)jsonToPayload:(NSDictionary *)json{
//    NSString *vins = json[@"0x07"];
//    NSArray *vinArr = [vins componentsSeparatedByString:@","];
//    
//    NSUInteger size = vinArr.count * 17;
//    Byte payload_bytes[size];
//    for (NSString *tempVin in vinArr) {
//        [super writeStringToBytesArray:payload_bytes :tempVin :0];
//    }
//    NSData *data = [NSData dataWithBytes:&payload_bytes length:sizeof(payload_bytes)];
//    [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":data}];
//    return data;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":@""}];
    return nil;
}


-(NSDictionary *)payloadToJson:(NSData *)payload{
//    NSString *orderNum = @"";
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    int size = payload.length / 17;
    for(int i=0;i<size;i++){
        const uint8_t *vehicle = [[payload subdataWithRange:NSMakeRange(i*17, 17)] bytes];
        NSString *device_id = [self flipOverString:[NSString stringWithFormat:@"%s",vehicle]];
        [tmpArray addObject:device_id];
        
//        orderNum=[orderNum stringByAppendingString:device_id];
    }
        
    
    
//    const uint8_t *bytes = [payload bytes];

//    NSString *device_id = [NSString stringWithFormat:@"%s",bytes];
//    NSInteger HB_period = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(30, 1)]];
//    const uint8_t *ble_key = [[payload subdataWithRange:NSMakeRange(31, 6)] bytes];
//    const uint8_t *hardwareVersion = [[payload subdataWithRange:NSMakeRange(37, 10)] bytes];
//    const uint8_t *softwareVersion = [[payload subdataWithRange:NSMakeRange(47, 10)] bytes];
//
    NSDictionary *json = @{@"device_id":tmpArray};
                           
//                           ,@"HB_period":[NSNumber numberWithInteger:HB_period],@"ble_key":[self flipOverString:[NSString stringWithFormat:@"%s",ble_key]],
//                                                                                                                                        @"hardwareVersion":[self flipOverString:[NSString stringWithFormat:@"%s",hardwareVersion]],
//                                                                                                                                                            @"softwareVersion":[self flipOverString:[NSString stringWithFormat:@"%s",softwareVersion]]};
    NSLog(@"json %@",json);
    return json;
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
