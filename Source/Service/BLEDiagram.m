//
//  BLEDiagram.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/27.
//

#import "BLEDiagram.h"

@implementation BLEDiagram

-(NSData *)jsonToPayload:(NSDictionary *)json{
    return nil;
}
-(NSDictionary *)payloadToJson:(NSData *)payload{
    return @{};
}

-(void)writeStringToBytesArray:(Byte [])payloadData :(NSString *)str :(int)startIndex{
    int p = startIndex;
    for (int i = str.length-1; i >= 0; i--) {
        payloadData[p++] = [str characterAtIndex:i];
    }
}

- (NSString *)reversalString:(NSString *)originString{
    NSString *resultStr = @"";
    for (NSInteger i = originString.length -1; i >= 0; i--){
      NSString *indexStr = [originString substringWithRange:NSMakeRange(i, 1)];
      resultStr = [resultStr stringByAppendingString:indexStr];
    }
  return resultStr;
}

@end
