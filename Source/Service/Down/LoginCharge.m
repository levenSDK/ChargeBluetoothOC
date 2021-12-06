//
//  LoginCharge.m
//  BluetoothOC
//
//  Created by yunzhanghu913 on 2021/11/27.
//

#import "LoginCharge.h"
#import "Const.h"

@implementation LoginCharge

-(NSData *)jsonToPayload:(NSDictionary *)json{
    NSString *secretKey = json[@"0x00"];
    Byte payload_bytes[6] = {0x00};
    int p = 0;
    for (int i = 5; i >= 0; i-=1) {
        NSString *a = [secretKey substringWithRange:NSMakeRange(i, 1)];
        const char *aNum = [a cStringUsingEncoding:NSASCIIStringEncoding];
        char result = aNum[0];
        payload_bytes[p++] = result;
    }
    NSData *data = [NSData dataWithBytes:&payload_bytes length:sizeof(payload_bytes)];
    [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_NOTIFICATION object:nil userInfo:@{@"data":data}];
    return data;
}

@end
