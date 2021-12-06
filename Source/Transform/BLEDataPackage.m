//
//  BLEDataPackage.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/25.
//

#import "BLEDataPackage.h"
#import "NSData+CLCRC16.h"


static NSInteger sequence_id;

@implementation BLEDataPackage

+ (instancetype)shareBLEDataPackageManager{
    static BLEDataPackage *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[BLEDataPackage alloc]init];
    });
   return instance;
}

-(instancetype)init{
    if (self = [super init]) {
        sequence_id = 0;
    }
    return self;
}

-(NSData *)generateHeaderWithCode:(Byte)hexCode payloadLength:(NSInteger)payloadLength{
    Byte header[7] = {0x0};
    //Magic byte
    header[0] = 0xAB;
    //Version ACK_flag Err_flag Reversed
    header[1] = 1;
    //Payload length
    header[2] = (Byte)(payloadLength - (payloadLength >> 8 << 8));
    header[3] = (Byte)(payloadLength >> 8);
    //Sequence id
    sequence_id += 1;
    if (sequence_id > 65535) {
        sequence_id = 0;
    }
    header[4] = (Byte)(sequence_id - (sequence_id >> 8 << 8));
    header[5] = (Byte)(sequence_id >> 8);
    //Command_ID
    header[6] = hexCode;
    return [NSData dataWithBytes:&header length:sizeof(header)];
}

-(NSData *)calculateCRC16WithHeader:(NSData *)header payload:(NSData *)payload{
    
    NSMutableData* diagramData = [NSMutableData data];
    [diagramData appendData:header];
    [diagramData appendData:payload];
    
    NSData *crc = [diagramData crc16];
    const uint8_t *crcBytes = [crc bytes];
    Byte b[2] = {crcBytes[0],crcBytes[1]};
    return [NSData dataWithBytes:&b length:sizeof(b)];
}

-(NSData *)generateWithCode:(Byte)hexCode payload:(NSData *)payload{
    NSData *headerWithoutCRC16 = [self generateHeaderWithCode:hexCode payloadLength:payload.length];
    NSData *crc16 = [self calculateCRC16WithHeader:headerWithoutCRC16 payload:payload];
    
    NSMutableData* diagramData = [NSMutableData data];
    [diagramData appendData:headerWithoutCRC16];//ab100c00 0100a1
    [diagramData appendData:crc16];//8b6c
    [diagramData appendData:payload];//119078 56341291 5f5ceb7a 01
    return diagramData;
}



//从字符串中取字节数组
-(Byte*)stringToByte:(NSString*)string {
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    NSUInteger length = hexString.length;
    Byte *bytes = (Byte*)malloc(length);
    int j=0;
    for(int i=0;i<[hexString length];i++) {
        int int_ch;
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;

        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;

        int_ch = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        NSLog(@"int_ch=%d",int_ch);
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    return bytes;
}

//普通字符串转换为十六进制的。
- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }else{
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
}

@end
