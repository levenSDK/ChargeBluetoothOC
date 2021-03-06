//
//  BLEConnection.m
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/25.
//

#import "BLEConnection.h"
#import "BabyBluetooth.h"
#import "ServiceFactory.h"
#import "BLEDataPackage.h"
#import "PeripheralInfo.h"

#import "NSData+CLCRC16.h"
#import "Const.h"

#define channelOnPeropheralView @"peripheralView"

@interface BLEConnection (){
    BabyBluetooth *baby;
    NSMutableArray *peripheralDataArray;
    NSString *chargingCode;
}
@property __block NSMutableArray *services;

@end

@implementation BLEConnection{
    NSMutableData *receiveData;
}


+ (instancetype)shareBLEConnectionManager{
    static BLEConnection *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[BLEConnection alloc]init];
    });
   return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.services = [[NSMutableArray alloc]init];
        peripheralDataArray = [[NSMutableArray alloc]init];
        
        baby = [BabyBluetooth shareBabyBluetooth];
        [self babyDelegate];
    }
    return self;
}

-(CBPeripheral *)getPeripheral{
    if (peripheralDataArray.count > 0) {
        NSDictionary *item = [peripheralDataArray objectAtIndex:0];
        CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
        return peripheral;
    }
    return nil;
}
-(CBCharacteristic *)getCharacteristic{
    if (self.services.count > 0) {
        CBCharacteristic *characteristic = [[[self.services objectAtIndex:0] characteristics]objectAtIndex:0];
        return characteristic;
    }
    return nil;
}


-(CBCharacteristic *)getCharacteristicWrite{
    if (self.services.count > 0) {
        CBCharacteristic *characteristic = [[[self.services objectAtIndex:0] characteristics]objectAtIndex:1];
        return characteristic;
    }
    return nil;
}


-(void)startConnection: (NSString *)code{
    __weak typeof(self) weakSelf = self;
    if (code != nil && code.length != 0) {
        chargingCode = code;
    }
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBManagerStatePoweredOn) {
            NSLog(@"???????????????????????????????????????");
            CLGlobalUserString = [CLGlobalUserString stringByAppendingString:@"???????????????????????????????????????\n"];
            [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_DISPLAY_NOTIFICATION object:nil userInfo:@{@"data":CLGlobalUserString}];
        } else {
            NSLog(@"????????????????????????????????????");
            CLGlobalUserString = [CLGlobalUserString stringByAppendingString:@"????????????????????????????????????\n"];
            [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_DISPLAY_NOTIFICATION object:nil userInfo:@{@"data":CLGlobalUserString}];
        }
        
        [ServiceFactory.shareServiceFactoryManager.delegate bluetoothStateDidChange:central.state];
        
    }];
    //??????????????????????????????
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        CLGlobalUserString = [CLGlobalUserString stringByAppendingFormat:@"??????????????????:%@\n",peripheral.name];
        [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_DISPLAY_NOTIFICATION object:nil userInfo:@{@"data":CLGlobalUserString}];
        //????????????
        if ([peripheral.name containsString:@"neta-"] && [peripheral.name containsString:chargingCode]) {
            NSLog(@"??????????????????:%@",peripheral.name);
            __strong typeof(self) strongSelf = weakSelf;
            NSArray *peripherals = [strongSelf->peripheralDataArray valueForKey:@"peripheral"];
            if(![peripherals containsObject:peripheral]) {
                NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
                [item setValue:peripheral forKey:@"peripheral"];
                [item setValue:RSSI forKey:@"RSSI"];
                [item setValue:advertisementData forKey:@"advertisementData"];
                [strongSelf->peripheralDataArray addObject:item];
            }
            
            [weakSelf havingPeripheral];
        }
    }];
    
    [baby cancelAllPeripheralsConnection];
    baby.scanForPeripherals().begin();
}
-(void)cancelConnection{
    [baby cancelAllPeripheralsConnection];
}
//????????????
-(void)havingPeripheral{
    [baby cancelScan];
    
    //?????????????????????????????????,?????????baby????????????????????????channel??????????????????
    [baby setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"?????????%@--????????????",peripheral.name);
        CLGlobalUserString = [CLGlobalUserString stringByAppendingFormat:@"?????????%@--????????????\n",peripheral.name];
        [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_DISPLAY_NOTIFICATION object:nil userInfo:@{@"data":CLGlobalUserString}];
    }];
    
    //?????????????????????????????????
    [baby setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"?????????%@--????????????",peripheral.name);
        CLGlobalUserString = [CLGlobalUserString stringByAppendingFormat:@"?????????%@--????????????\n",peripheral.name];
        [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_DISPLAY_NOTIFICATION object:nil userInfo:@{@"data":CLGlobalUserString}];
        [[ServiceFactory shareServiceFactoryManager].delegate peripheralConnectedDidChange: NO];
    }];

    //?????????????????????????????????
    [baby setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"?????????%@--????????????",peripheral.name);
        CLGlobalUserString = [CLGlobalUserString stringByAppendingFormat:@"?????????%@--????????????\n",peripheral.name];
        [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_DISPLAY_NOTIFICATION object:nil userInfo:@{@"data":CLGlobalUserString}];
        [[ServiceFactory shareServiceFactoryManager].delegate peripheralConnectedDidChange: NO];

    }];
    
    NSDictionary *item = [peripheralDataArray objectAtIndex:0];
    CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
    baby.having(peripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}

//??????????????????????????????????????????
-(void)babyDelegate{
    __weak typeof(self) weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    //?????????????????????Services?????????
    [baby setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *s in peripheral.services) {
            NSLog(@"Service uuid = %@",s.UUID.UUIDString);
        }
        
        [rhythm beats];
    }];
    //???????????????service???Characteristics?????????
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
//        NSLog(@"===service name:%@",service.UUID);
        if ([service.UUID.UUIDString isEqualToString:@"FF00"]) {
//            NSLog(@"===service name:%@",service.UUID);
            PeripheralInfo *info = [[PeripheralInfo alloc]init];
            [info setServiceUUID:service.UUID];
            info.characteristics = [NSMutableArray arrayWithArray:service.characteristics];
            [weakSelf.services addObject:info];
            [weakSelf startNotifiy];
            [[ServiceFactory shareServiceFactoryManager].delegate peripheralConnectedDidChange: YES];
        }
    }];
    //????????????characteristics?????????
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //????????????characteristics???descriptors?????????
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //????????????Descriptor?????????
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //??????rssi?????????
    [baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"setBlockOnDidReadRSSI:RSSI:%@",RSSI);
    }];
    
    //???????????????????????????block
    [baby setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
//        NSLog(@"uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
    }];
    
    
    //??????beats break??????
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsBreak call");
    }];
    
    //??????beats over??????
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsOver call");
    }];
    
    //????????????->CBCentralManagerScanOptionAllowDuplicatesKey:???????????????Peripheral??????????????????????????????????????????????????????
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
   
    /*????????????->
     CBConnectPeripheralOptionNotifyOnConnectionKey :??????????????????????????????????????????????????????????????????????????????????????????peripheral???????????????????????????????????????key??????
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :?????????????????????????????????????????????????????????????????????????????????peripheral??????????????????????????????????????????????????????key??????
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     ??????????????????????????????key??????????????????????????????peripheral??????????????????????????????
    */
     NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [baby setBabyOptionsAtChannel:channelOnPeropheralView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
//    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
}

-(void)startNotifiy{
    CBPeripheral *peripheral = [self getPeripheral];
    CBCharacteristic *characteristic = [self getCharacteristic];
    if(peripheral.state != CBPeripheralStateConnected) {
        NSLog(@"peripheral????????????????????????????????????");
        return;
    }
    if (characteristic.properties & CBCharacteristicPropertyNotify ||  characteristic.properties & CBCharacteristicPropertyIndicate) {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        [baby notify:peripheral characteristic:characteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
            NSLog(@"notify block new value %@",characteristics);
            if(characteristics.value){
                const u_int8_t *bytes = [characteristics.value bytes];
                Byte magic_byte = bytes[0];
                if (magic_byte == 0xAB) {
                    self->receiveData = [[NSMutableData alloc] initWithCapacity:500];
                    [self->receiveData appendData:characteristics.value];
                }else{
                    [self->receiveData appendData:characteristics.value];
                }

                if(self->receiveData.length>=9){
                    if (![self chechCRC16:self->receiveData]) {
                        NSLog(@"crc???????????????");
                        return;
                    }else{
                        NSLog(@"all notify block new value %@",self->receiveData);
                        NSLog(@"crc????????????");
                        NSData *payload_data = [self->receiveData subdataWithRange:NSMakeRange(9, self->receiveData.length-9)];
                        const u_int8_t *bytesa = [self->receiveData bytes];
                        Byte code = bytesa[6];
                        [[ServiceFactory shareServiceFactoryManager] executeUpWithCode:code payload:payload_data];
                        NSLog(@"code new value %ld",(long)code);
                        
                        CLGlobalUserString = [CLGlobalUserString stringByAppendingFormat:@"all notify block new value %@\n",self->receiveData];
                        [[NSNotificationCenter defaultCenter] postNotificationName:COMMON_DISPLAY_NOTIFICATION object:nil userInfo:@{@"data":CLGlobalUserString}];
                        
                    }
                }else{
                    NSLog(@"crc????????????");
                    return;
                }
                    
                
            }
        }];
    }else{
        NSLog(@"??????characteristic??????nofity?????????");
        return;
    }
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

-(BOOL)chechCRC16:(NSData *)packet{
        NSData *header = [packet subdataWithRange:NSMakeRange(0, 7)];
        NSData *crc16_packet = [packet subdataWithRange:NSMakeRange(7, 2)];
        NSData *payload = [packet subdataWithRange:NSMakeRange(9, packet.length-9)];
        NSData *cal_crc16= [[BLEDataPackage shareBLEDataPackageManager] calculateCRC16WithHeader:header payload:payload];
        if ([[crc16_packet hexadecimalString] isEqualToString: [cal_crc16 hexadecimalString]]) {
            return YES;
        }
    return NO;
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
