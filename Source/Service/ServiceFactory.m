//
//  ServiceFactory.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/26.
//

#import "ServiceFactory.h"
#import "BLEDiagram.h"
#import "BLEDispatcher.h"
#import "LoginCharge.h"
#import "GeneralConfigUpdate.h"
#import "UpdateVehicleWhitelist.h"
#import "StartCharge.h"
#import "QueryChargeState.h"
#import "EndCharge.h"
#import "QueryConfig.h"
#import "QueryVehicleWhitelist.h"
#import "QueryHistoricalOrders.h"

#import "StartChargeSuccessResult.h"
#import "StartChargeFailureResult.h"
#import "EndChargeSuccessResult.h"
#import "EndChargeFailureResult.h"
#import "ChargeStateResult.h"
#import "SyncHistoricalOrder.h"
#import "QueryConfigCallBack.h"
#import "CommonCallBack.h"

@implementation ServiceFactory

+ (instancetype)shareServiceFactoryManager{
    static ServiceFactory *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[ServiceFactory alloc]init];
    });
   return instance;
}

-(void)executeDownWithCode:(Byte)hexCode payload:(NSDictionary *)payload{
    BLEDiagram *instance = [self createInstance:hexCode];
    if (instance != nil) {
        NSData *data = [instance jsonToPayload:payload];
        [[BLEDispatcher shareBLEDispatcherManager] sendWithCode:hexCode data:data];
    }
}

//hexcode 用16进制传过来
-(BLEDiagram *)createInstance:(Byte)hexCode{
    if (hexCode == 0x01) {
        return [GeneralConfigUpdate new];
    }else if (hexCode == 0x02){
        return [UpdateVehicleWhitelist new];
    }else if (hexCode == 0x03){
        return [StartCharge new];
    }else if (hexCode == 0x04){
        return [QueryChargeState new];
    }else if (hexCode == 0x05){
        return [EndCharge new];
    }else if (hexCode == 0x06){
        return [QueryConfig new];
    }else if (hexCode == 0x07){
        return [QueryVehicleWhitelist new];
    }else if (hexCode == 0x08){
        return [QueryHistoricalOrders new];
    }else if (hexCode == 0xA1){
        return [StartChargeSuccessResult new];
    }else if (hexCode == 0xA2){
        return [StartChargeFailureResult new];
    }else if (hexCode == 0xA3){
        return [ChargeStateResult new];
    }else if (hexCode == 0xA4){
        return [EndChargeSuccessResult new];
    }else if (hexCode == 0xA5){
        return [EndChargeFailureResult new];
    }else if (hexCode == 0xA6){
        return [SyncHistoricalOrder new];
    }else if (hexCode == 0xAA){
        return [CommonCallBack new];
    } else if (hexCode == 0x00){
        return [LoginCharge new];
    }
    return nil;
}



-(void)executeUpWithCode:(Byte)hexCode payload:(NSData *)payload{
    BLEDiagram *instance = [self createInstance:hexCode];
    if (instance != nil) {
        NSDictionary *json = [instance payloadToJson:payload];
        [self.delegate didReceive:hexCode json:json];
    }
}





-(NSData *)convertHexStrToData:(NSString *)str{
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    }else{
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i+=2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}
@end
