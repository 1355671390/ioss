import UIKit
import Flutter
import peertalk

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PTChannelDelegate {

    var serverChannel: PTChannel?
    var peerChannel: PTChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // 初始化 Peertalk 监听
        let channel = PTChannel(delegate: self)

        // 监听手机内部 2345 端口
        channel.listen(onPort: 2345, iPv4Address: INADDR_ANY) { error in
            if let error = error {
                print("USB Listen Failed: \(error.localizedDescription)")
            } else {
                print("USB Listen Started on Port 2345")
                self.serverChannel = channel
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // 接受 PC 连接的回调
    func ioFrameChannel(_ channel: PTChannel, didAcceptConnection otherChannel: PTChannel, from address: PTAddress) {
        self.peerChannel = otherChannel
        self.peerChannel?.delegate = self
        print("PC Connected!")
    }

    // 收到 PC 数据的回调
    func ioFrameChannel(_ channel: PTChannel, didReceiveFrameType type: UInt32, tag: UInt32, payload: PTData?) {
        // 类型 101 定义为简单文本消息
        if type == 101, let data = payload {
            let message = String(data: data.dispatchData as Data, encoding: .utf8)
            print("Received from PC: \(message ?? "")")
        }
    }
}