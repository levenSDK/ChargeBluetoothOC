//
//  BLEDispatcher.h
//  Neta_BLE
//
//  Created by yannkeynes on 2021/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//调度类,公开一个接口send方法,参数是组装好的payload

/**
 逻辑 : 步骤1.判断是否有充电桩设备连接,如果没有连接跳到步骤2,如果有连接进入步骤3,
 步骤2. 调用bleconnection查找设备,筛选符合条件的设备,点击设备后连接(如果有秘钥,就自动输入并连接)
       步骤3. (确保已经有设备连接),生成header,
       步骤4. 计算crc
       步骤5. 组装header + crc + payload (整个是一个packet)
       步骤6. 调用bleconnection 发送数据报文

   给蓝牙模块配置秘钥以后 还需要输入秘钥才能连接蓝牙吗?
 */


// 公开监听事件方法,
//代码逻辑
//      步骤1. magiccode 等于0xAB 进入步骤2,否则直接忽略
//      步骤2. 做crc校验,如果成功,进入步骤3,否则下行回复充电桩校验失败(0x02),参考文档
//      步骤3. 解析header的报文长度,从第10个字节开始读取完整的报文数据(payload)
//      步骤4. 解析header里的指令编码(上行),
//      步骤5. 调用service层的工厂方法传入指令编码和payload


@interface BLEDispatcher : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)shareBLEDispatcherManager;
-(void)sendWithCode:(Byte)hexCode data:(NSData *)data;
-(void)onReceive;

@end

NS_ASSUME_NONNULL_END
