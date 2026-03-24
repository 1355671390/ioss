import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PTChannelDelegate {
    
    var serverChannel: PTChannel?
    var peerChannel: PTChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // 1. 初始化 Peertalk 通道
        let channel = PTChannel(delegate: self)
        
        // 2. 监听 2345 端口 (用于 USB 连接)
        channel.listen(onPort: 2345, iPv4Address: INADDR_ANY) { error in
            if let error = error {
                print("DEBUG: USB 监听启动失败: \(error.localizedDescription)")
            } else {
                print("DEBUG: USB 监听已在端口 2345 开启")
                self.serverChannel = channel
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // --- PTChannelDelegate 协议实现 ---

    // 接收到新连接
    func ioFrameChannel(_ channel: PTChannel, didAcceptConnection otherChannel: PTChannel, from address: PTAddress) {
        self.peerChannel = otherChannel
        self.peerChannel?.delegate = self
        print("DEBUG: PC 已通过 USB 连接")
    }

    // 接收到数据帧
    func ioFrameChannel(_ channel: PTChannel, didReceiveFrameType type: UInt32, tag: UInt32, payload: PTData?) {
        if type == 101, let data = payload {
            let message = String(data: data.dispatchData as Data, encoding: .utf8)
            print("DEBUG: 收到来自 PC 的控制消息: \(message ?? "")")
        }
    }
}
