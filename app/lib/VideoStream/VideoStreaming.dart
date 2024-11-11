// /*
//  * @Author: vic123 zhangzc_efz@163.com
//  * @Date: 2024-09-03 16:48:14
//  * @LastEditors: vic123 zhangzc_efz@163.com
//  * @LastEditTime: 2024-09-12 19:25:31
//  * @FilePath: \app\lib\VideoStream\VideoStreaming.dart
//  * @Description:
//  *
//  * Copyright (c) 2024 by vic123, All Rights Reserved.
//  */
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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
  bool isStartPressed = false;
  bool isEndPressed = false;
  Timer? picTimer;
  late CameraController controller;

  @override
  void initState() {
    _loadCam();
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
    startPictureTimer();
    super.initState();
  }

  Future<void> _loadCam() async {
    _cameras = await availableCameras();
    controller = CameraController(_cameras[0], ResolutionPreset.medium);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        print(e.code);
      }
    });
  }

  void startConnection(BuildContext context) async {
    _socket.connect();
    setState(() {
      _isConnected = true;
      isStartPressed = true;
      isEndPressed = false;
    });
    // 锁定横屏模式
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void endConnection() {
    setState(() {
      _isConnected = false;
      isEndPressed = true;
      isStartPressed = false;
    });
    _socket.disconnect();
    // 恢复自由旋转模式
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void startPictureTimer() {
    if (picTimer != null && picTimer!.isActive) {
      return;
    }
    picTimer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
      if (_isConnected) {
        sendPicture();
      }
    });
  }

  void sendPicture() async {
    int timestamp1 = DateTime.now().millisecondsSinceEpoch;
    final XFile image = await controller.takePicture();
    int timestamp2 = DateTime.now().millisecondsSinceEpoch;
    Uint8List imageBytes = await image.readAsBytes();

    Map<String, dynamic> message = {
      'timestamp1': timestamp1,
      'timestamp2': timestamp2,
      'image': base64Encode(imageBytes),
    };
    _socket.sendMessage(jsonEncode(message));
  }

  @override
  Widget build(BuildContext context) {
    // 颜色定义
    final buttonColor = Color(0xFF1E3A5F); // 默认按钮颜色
    final buttonPressedColor = Colors.blueGrey[100]!.withOpacity(0.7); // 浅色与视频框匹配
    final buttonShadowColor = Colors.black.withOpacity(0.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text("3DGS RealTime Rendering"),
        backgroundColor: Colors.blueGrey[700],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.grey[800]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 视频显示区域
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueGrey[800]!, Colors.grey[700]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueGrey[600]!.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: _isConnected
                    ? Center(
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
                              excludeFromSemantics: true,
                            ),
                          );
                        }
                        return Center(
                          child: Text(
                            "Connection Closed!",
                            style: Styles.statusTextStyle,
                          ),
                        );
                      },
                    ),
                    _socket.sendMessage,
                  ),
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => startConnection(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          shadowColor: buttonShadowColor,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 48),
                        ),
                        child: const Text(
                          "Start",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please rotate to landscape for a better experience.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Column(
              children: [
                Text(
                  "Drag to zoom and pan the video.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: _isConnected ? endConnection : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEndPressed ? buttonPressedColor : buttonColor,
                      shadowColor: buttonShadowColor,
                      elevation: isEndPressed ? 5 : 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      "End",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

