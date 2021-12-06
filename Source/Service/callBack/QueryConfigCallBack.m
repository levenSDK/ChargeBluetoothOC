//
//  QueryConfigCallBack.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/8/19.
//

#import "QueryConfigCallBack.h"

@interface QueryConfigCallBack ()

@end

@implementation QueryConfigCallBack
//请求数据
//0x01:0xab012500020001c0143667726d76356b3666313778366f6f2d7878334c3941354f4c53334d00003c
//0x02:0xab01220003000254cd383333393030414c3741414147415a554c393333393030414c374141414741
//0x03:0xab0106000400034cc7119078563412
//0x04:0xab010000050004aee8
//0x05:0xab0106000600057b04119078563412
//0x06:0xab010000010006dda8
//0x07:0xab01000001000754b9
//0x08:0xab0100000a00080568






//返回数据
//0x01:0xab1100000f0001c98e code new value 1
//0x01:0xab110000020001b671
//0x01:0xab110000010001d29e

//0x02:0xab110000030002f119  code new value 2
//0x02:0xab1100000200022d43

//推送0x03:0xab0108000000a2057e1190785634120200     code new value 162
//推送0x03:0xab010c000000a1c101119078563412323032313038
//应答0x03:0xab1100001000038962 code new value 3
//应答0x03:0xab1100000300037808



//0x04:0xab1102000500046a320000 code new value 4
//0x04:0xab1102000400042e390000


//推送0xA1:0xab010c000000a1c101119078563412323032313038
//推送0xA2:0xab0108000000a2057e1190785634120200     code new value 162
//推送0xA3:0xab0122000000a35b8ed0d0d0d0d0d0196400dc000a00323032313038013230323130383230323130386400
//推送0xA4:0xab010c000000a417dcd0d0d0d0d0d0323032313038  {"cd_timestamp" = 61779634958386;orderNum = 130130130130130130;}

//0x05:0xab3101000600056b9330  code new value 5
//0x05:0xab310100050005a6b630
//0x05:0xab3101000600056b9330


//0x06:0xab113900010006827c3667726d76356b3666313778366f6f2d7878334c3941354f4c53334d00003c313139323833312e302e480000000000312e302e300000000000 code new value 6
//0x07:0xab113300080007e8e2383333393030414c3741414147415a554c393333393030414c3741414147415a554c0000000000000000000000000000000000 code new value 7
//0x07:0xab113300080007e8e2383333393030414c3741414147415a554c393333393030414c3741414147415a554c0000000000000000000000000000000000


//推送0x08:0xab0108000100a61124119078563412196400dc000a00323032313038013230323130383230323130386400 code new value 166



//应答0x08:0xab1101001100081af401 code new value 8

//应答0x08:0xab11220009000842be119078563412196400dc000a00323032313038013230323130383230323130386400
//应答0x08:0xab1122000a0008b278119078563412196400dc000a00323032313038013230323130383230323130386400
//收到0x08的响应后，如果有订单数据，我方接收到以后，需要作出应答（与其他的不一样），对方收到我方的应答后会从其本地设备中删除该订单
//@{@"0x06":@{@"device_id":@"M3SLO5A9L3xx-oo6x71f6k5vmrg6",@"HB_period":@"60",@"ble_key":@"382911",@"hardwareVersion":@"7L00324",@"softwareVersion":@"7L00324"}},

//0xab113900010006827c3667726d76356b3666313778366f6f2d7878334c3941354f4c53334d00003c313139323833312e302e480000000000312e302e300000000000


-(NSDictionary *)payloadToJson:(NSData *)payload{
    const uint8_t *bytes = [payload bytes];
//    NSString *device_id = @"";
    NSData *adata = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString *device_id =[[ NSString alloc] initWithData:adata encoding:NSUTF8StringEncoding];


//    for (int i = 0; i < 30; i ++) {
//        int a = bytes[i];
//        int b = a >> 4;
//        int c = a - (b << 4);
//        device_id = [NSString stringWithFormat:@"%d%d%@",b,c,device_id];
//    }
    
    NSInteger HB_period = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(30, 1)]];
    NSInteger ble_key = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(31, 6)]];
    NSInteger hardwareVersion = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(37, 10)]];
    NSInteger softwareVersion = [self byteArrayToInt:[payload subdataWithRange:NSMakeRange(47, 10)]];
    
    NSDictionary *json = @{@"device_id":device_id,@"HB_period":[NSNumber numberWithInteger:HB_period],@"ble_key":[NSNumber numberWithInteger:ble_key],
                           @"hardwareVersion":[NSNumber numberWithInteger:hardwareVersion],
                           @"softwareVersion":[NSNumber numberWithInteger:softwareVersion]};
    NSLog(@"json %@",json);
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
