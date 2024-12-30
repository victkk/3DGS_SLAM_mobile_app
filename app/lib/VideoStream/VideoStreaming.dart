/*
 * @Author: vic123 zhangzc_efz@163.com
 * @Date: 2024-09-03 16:48:14
 * @LastEditors: asandstar zhangzc_efz@163.com
 * @LastEditTime: 2024-12-30 20:30:00
 * @FilePath: \app\lib\VideoStream\VideoStreaming.dart
 * @Description: 3DGS RealTime Rendering Application
 *
 * Copyright (c) 2024 by vic123, All Rights Reserved.
 */

import 'dart:async';
import 'dart:convert';
import 'package:app/VideoStream/websocket.dart';
import 'package:app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:app/styles/styles.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:camera/camera.dart';
import 'package:app/gesture_detector3d.dart';
import 'package:flutter/services.dart';

late List<CameraDescription> _cameras;

class VideoStream extends StatefulWidget {
  const VideoStream({Key? key}) : super(key: key);

  @override
  State<VideoStream> createState() => _VideoStreamState();
}

class _VideoStreamState extends State<VideoStream> {
  final WebSocket _socket = WebSocket(Constants.videoWebsocketURL);
  bool _isConnected = false;
  Timer? picTimer;
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    _loadCam();
    _setupSensors();
    startPictureTimer();

    // 初始化时监听屏幕方向变化并动态调整状态栏模式
    WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
  }

  Future<void> _loadCam() async {
    _cameras = await availableCameras();
    controller = CameraController(_cameras[0], ResolutionPreset.medium);

    await controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  void _setupSensors() {
    accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
          (AccelerometerEvent event) {
        if (_isConnected) {
          _socket.sendMessage(jsonEncode({
            'x': event.x,
            'y': event.y,
            'z': event.z,
            'timestamp': event.timestamp.microsecondsSinceEpoch,
            'code': "accelerometer"
          }));
        }
      },
      onError: (error) {},
      cancelOnError: true,
    );

    gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
          (GyroscopeEvent event) {
        if (_isConnected) {
          _socket.sendMessage(jsonEncode({
            'x': event.x,
            'y': event.y,
            'z': event.z,
            'timestamp': event.timestamp.microsecondsSinceEpoch,
            'code': "gyroscope"
          }));
        }
      },
      onError: (error) {},
      cancelOnError: true,
    );
  }

  void startConnection(BuildContext context) async {
    _socket.connect();
    setState(() {
      _isConnected = true;
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void endConnection() {
    setState(() {
      _isConnected = false;
    });
    _socket.disconnect();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void startPictureTimer() {
    if (picTimer != null && picTimer!.isActive) return;
    picTimer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
      if (_isConnected) {
        sendPicture();
      }
    });
  }

  void sendPicture() async {
    final XFile image = await controller.takePicture();
    Uint8List imageBytes = await image.readAsBytes();

    Map<String, dynamic> message = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'image': base64Encode(imageBytes),
    };
    _socket.sendMessage(jsonEncode(message));
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    const buttonGradient = LinearGradient(
      colors: [Color(0xFF0B184A), Color(0xFF17339F)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });

    return Scaffold(
      appBar: isLandscape
          ? null // 横屏模式下隐藏标题栏
          : PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
    child: Padding(
    padding: const EdgeInsets.only(top: 0), // 增加顶部空白
        child: Container(
          decoration: BoxDecoration(
            gradient: buttonGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "3DGS RealTime Rendering",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1))],
                ),
              ),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF5C91FA).withOpacity(1),
              const Color(0xFF5C91FA).withOpacity(0.5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 添加上下间距
          children: [
            if (!isLandscape) const SizedBox(height: 0), // 调整顶部空隙
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  // color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: _isConnected
                    ? Stack(
                  children: [
                    Center(
                      child: Drag(
                        StreamBuilder(
                          stream: _socket.stream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.connectionState == ConnectionState.active &&
                                snapshot.hasData) {
                              return Center(
                                child: Image.memory(
                                  Uint8List.fromList(
                                    base64Decode(snapshot.data.toString()),
                                  ),
                                  fit: BoxFit.contain,
                                  gaplessPlayback: true,
                                ),
                              );
                            }
                            return const Center(
                              child: Text(
                                "Connection Closed!",
                                style: Styles.statusTextStyle,
                              ),
                            );
                          },
                        ),
                        _socket.sendMessage,
                      ),
                    ),
                    if (isLandscape)


                      Positioned(
                        bottom: 10,
                        right: MediaQuery.of(context).size.width * 0.05,
                        child: Container(
                          width: 80,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: buttonGradient,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: endConnection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              "End",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1))],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
                :Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 添加 VINGS-MONO 的标志
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/icon.png', // VIN 图标路径
                              height: 130,
                            ),
                            const SizedBox(height: 8),
                            // const Text(
                            //   "VINGS-MONO",
                            //   style: TextStyle(
                            //     fontSize: 28,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.white,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      // 添加说明文字
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          "Visual-Inertial\n Gaussian Splatting SLAM\nin Large Scenes",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // 添加学校/实验室的组合图标
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Image.asset(
                          'assets/images/3.png', // 三个图标的组合图路径
                          height: 80, // 根据需要调整大小
                        ),
                      ),
                      // 添加按钮和说明文字
                      Container(
                        width: 180,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: buttonGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => startConnection(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Landscape",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap to view REALTIME updates",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold, // Bold text for emphasis
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),



              ),
            ),
          ],
        ),
      ),
    );
  }
}
