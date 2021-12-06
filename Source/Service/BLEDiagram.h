//
//  BLEDiagram.h
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLEDiagram : NSObject

-(NSData *)jsonToPayload:(NSDictionary *)json;
-(NSDictionary *)payloadToJson:(NSData *)payload;

-(void)writeStringToBytesArray:(Byte [_Nullable])payloadData :(NSString *)str :(int)startIndex;

- (NSString *)reversalString:(NSString *)originString;
@end

NS_ASSUME_NONNULL_END
