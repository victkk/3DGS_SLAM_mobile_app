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


/*
* 顶部的渐变标题栏宛若晨曦中的霞光，从柔和的粉色过渡到清新的蓝色，犹如初升的朝阳映照在海天交接之处。
中心的视频框纯净如一方静谧的湖泊，安然地位于画面中央，与四周环境和谐共生，彰显出一种沉静而不失生动的美感。
按钮设计更显灵动，流动的粉蓝渐变仿佛微风拂过湖面，激起一层层涟漪，圆润的边角与精致的阴影交相辉映，仿若远山朦胧中的烟云。
按钮旁提示文字低调素雅，以浅灰呈现，若隐若现间引导用户进入体验，带来一种身临其境的宁静之感。
整体色调柔和，既有自然的清新之美，又不失科技的未来感。
此设计如一首清晨的诗，带领用户从现实进入虚拟之境，让操作不再是冷冰冰的指令，而是一种心灵上的共鸣与沉浸。
* */
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
    final buttonGradient = LinearGradient(
      colors: [Color(0xFFF8BBD0), Color(0xFFB3E5FC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: buttonGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              "3DGS RealTime Rendering",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1))],
              ),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8BBD0).withOpacity(0.6),
              Color(0xFFE1BEE7).withOpacity(0.4),
              Color(0xFFB3E5FC).withOpacity(0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 12),
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
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
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
                      Container(
                        width: 160,
                        decoration: BoxDecoration(
                          gradient: buttonGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: Offset(0, 10),
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
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: const Text(
                            "Start",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1))],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please rotate to landscape for a better experience.",
                        style: TextStyle(
                          color: Colors.grey.shade800,
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
                    color: Colors.grey.shade800,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 160,
                  decoration: BoxDecoration(
                    gradient: buttonGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isConnected ? endConnection : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
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
                        shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1))],
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
