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
// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:app/VideoStream/websocket.dart';
// import 'package:app/constants/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:app/styles/styles.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:camera/camera.dart';
// import 'package:app/gesture_detector3d.dart';
//
// late List<CameraDescription> _cameras;
//
// class VideoStream extends StatefulWidget {
//   const VideoStream({Key? key}) : super(key: key);
//
//   @override
//   State<VideoStream> createState() => _VideoStreamState();
// }
//
// class _VideoStreamState extends State<VideoStream> {
//   final WebSocket _socket = WebSocket(Constants.videoWebsocketURL);
//   bool _isConnected = false;
//   Timer? picTimer;
//   late CameraController controller;
//   @override
//   void initState() {
//     _loadCam();
//     accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
//         .listen(
//       (AccelerometerEvent event) {
//         if (_isConnected) {
//           _socket.sendMessage(jsonEncode({
//             'x': event.x,
//             'y': event.y,
//             'z': event.z,
//             'timestamp': event.timestamp.microsecondsSinceEpoch,
//             'code': "accelerometer"
//           }));
//         }
//       },
//       onError: (error) {
//         // Logic to handle error
//         // Needed for Android in case sensor is not available
//       },
//       cancelOnError: true,
//     );
//     gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
//       (GyroscopeEvent event) {
//         if (_isConnected) {
//           _socket.sendMessage(jsonEncode({
//             'x': event.x,
//             'y': event.y,
//             'z': event.z,
//             'timestamp': event.timestamp.microsecondsSinceEpoch,
//             'code': "gyroscope"
//           }));
//         }
//       },
//       onError: (error) {
//         // Logic to handle error
//         // Needed for Android in case sensor is not available
//       },
//       cancelOnError: true,
//     );
//     startPictureTimer();
//     super.initState();
//   }
//
//   Future<void> _loadCam() async {
//     _cameras = await availableCameras();
//     controller = CameraController(_cameras[0], ResolutionPreset.medium);
//
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     }).catchError((Object e) {
//       if (e is CameraException) {
//         switch (e.code) {
//           case 'CameraAccessDenied':
//             print(e.code);
//             break;
//           default:
//             print(e.code);
//             break;
//         }
//       }
//     });
//   }
//
//   void connect(BuildContext context) async {
//     _socket.connect();
//     setState(() {
//       _isConnected = true;
//     });
//   }
//
//   void disconnect() {
//     setState(() {
//       _isConnected = false;
//     });
//     _socket.disconnect();
//   }
//
//   void startPictureTimer() {
//     if (picTimer != null && picTimer!.isActive) {
//       return;
//     }
//     picTimer =
//         Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
//       if (_isConnected) {
//         sendPicture();
//       } else {
//         // timer.cancel();
//       }
//     });
//   }
//
//   void sendPicture() async {
//     int timestamp1 = DateTime.now().millisecondsSinceEpoch;
//     final XFile image = await controller.takePicture();
//     int timestamp2 = DateTime.now().millisecondsSinceEpoch;
//     Uint8List imageBytes = await image.readAsBytes();
//
//     Map<String, dynamic> message = {
//       'timestamp1': timestamp1,
//       'timestamp2': timestamp2,
//       'image': base64Encode(imageBytes),
//     };
//     _socket.sendMessage(jsonEncode(message));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("3DGS RealTime Rendering"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Center(
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () => connect(context),
//                     style: Styles.buttonStyle,
//                     child: const Text("Connect"),
//                   ),
//                   ElevatedButton(
//                     onPressed: disconnect,
//                     style: Styles.buttonStyle,
//                     child: const Text("Disconnect"),
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 50.0,
//               ),
//               _isConnected
//                   ? Drag(
//                       StreamBuilder(
//                         stream: _socket.stream,
//                         builder: (context, snapshot) {
//                           if (!snapshot.hasData) {
//                             return const CircularProgressIndicator();
//                           }
//                           if (snapshot.connectionState ==
//                               ConnectionState.done) {
//                             return const Center(
//                               child: Text("Connection Closed !"),
//                             );
//                           }
//                           if (snapshot.data == "Connection Established") {
//                             return const Center(
//                               child: Text("Connection Closed !"),
//                             );
//                           }
//                           //? Working for single frames
//                           return Image.memory(
//                             Uint8List.fromList(
//                               base64Decode(
//                                 (snapshot.data.toString()),
//                               ),
//                             ),
//                             width: 1000,
//                             gaplessPlayback: true,
//                             excludeFromSemantics: true,
//                           );
//                         },
//                       ),
//                       _socket.sendMessage)
//                   : const Text("Initiate Connection")
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//------------------------------------------------------------------------------
// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:app/VideoStream/websocket.dart';
// import 'package:app/constants/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:app/styles/styles.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:camera/camera.dart';
// import 'package:app/gesture_detector3d.dart';
//
// late List<CameraDescription> _cameras;
//
// class VideoStream extends StatefulWidget {
//   const VideoStream({Key? key}) : super(key: key);
//
//   @override
//   State<VideoStream> createState() => _VideoStreamState();
// }
//
// class _VideoStreamState extends State<VideoStream> {
//   final WebSocket _socket = WebSocket(Constants.videoWebsocketURL);
//   bool _isConnected = false;
//   Timer? picTimer;
//   late CameraController controller;
//
//   @override
//   void initState() {
//     _loadCam();
//     accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
//         .listen(
//           (AccelerometerEvent event) {
//         if (_isConnected) {
//           _socket.sendMessage(jsonEncode({
//             'x': event.x,
//             'y': event.y,
//             'z': event.z,
//             'timestamp': event.timestamp.microsecondsSinceEpoch,
//             'code': "accelerometer"
//           }));
//         }
//       },
//       onError: (error) {},
//       cancelOnError: true,
//     );
//     gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
//           (GyroscopeEvent event) {
//         if (_isConnected) {
//           _socket.sendMessage(jsonEncode({
//             'x': event.x,
//             'y': event.y,
//             'z': event.z,
//             'timestamp': event.timestamp.microsecondsSinceEpoch,
//             'code': "gyroscope"
//           }));
//         }
//       },
//       onError: (error) {},
//       cancelOnError: true,
//     );
//     startPictureTimer();
//     super.initState();
//   }
//
//   Future<void> _loadCam() async {
//     _cameras = await availableCameras();
//     controller = CameraController(_cameras[0], ResolutionPreset.medium);
//
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     }).catchError((Object e) {
//       if (e is CameraException) {
//         switch (e.code) {
//           case 'CameraAccessDenied':
//             print(e.code);
//             break;
//           default:
//             print(e.code);
//             break;
//         }
//       }
//     });
//   }
//
//   void connect(BuildContext context) async {
//     _socket.connect();
//     setState(() {
//       _isConnected = true;
//     });
//   }
//
//   void disconnect() {
//     setState(() {
//       _isConnected = false;
//     });
//     _socket.disconnect();
//   }
//
//   void startPictureTimer() {
//     if (picTimer != null && picTimer!.isActive) {
//       return;
//     }
//     picTimer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
//       if (_isConnected) {
//         sendPicture();
//       } else {
//         // timer.cancel();
//       }
//     });
//   }
//
//   void sendPicture() async {
//     int timestamp1 = DateTime.now().millisecondsSinceEpoch;
//     final XFile image = await controller.takePicture();
//     int timestamp2 = DateTime.now().millisecondsSinceEpoch;
//     Uint8List imageBytes = await image.readAsBytes();
//
//     Map<String, dynamic> message = {
//       'timestamp1': timestamp1,
//       'timestamp2': timestamp2,
//       'image': base64Encode(imageBytes),
//     };
//     _socket.sendMessage(jsonEncode(message));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("3DGS RealTime Rendering"),
//         backgroundColor: Colors.blueGrey,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // 视频显示区域
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.blueGrey[50], // 背景颜色
//                   borderRadius: BorderRadius.circular(40), // 圆角边框
//                   border: Border.all(color: Colors.blueGrey), // 边框颜色
//                 ),
//                 child: _isConnected
//                     ? Drag(
//                     StreamBuilder(
//                       stream: _socket.stream,
//                       builder: (context, snapshot) {
//                         if (!snapshot.hasData) {
//                           return const Center(
//                               child: CircularProgressIndicator(),
//                           );
//                         }
//                         if (snapshot.connectionState ==
//                             ConnectionState.done) {
//                           return const Center(
//                             child: Text("Connection Closed !"),
//                           );
//                         }
//                         if (snapshot.data == "Connection Established") {
//                           return const Center(
//                             child: Text("Connection Closed !"),
//                           );
//                         }
//                         return Image.memory(
//                           Uint8List.fromList(
//                             base64Decode(
//                               (snapshot.data.toString()),
//                             ),
//                           ),
//                           width: 1000,
//                           gaplessPlayback: true,
//                           excludeFromSemantics: true,
//                         );
//                       },
//                     ),
//                     _socket.sendMessage)
//                     : const Center(
//                   child: Text(
//                     "Waiting for video connection...",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             // 按钮区
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 SizedBox(
//                   width: 140, // 设定统一宽度
//                   child: ElevatedButton(
//                     onPressed: disconnect,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueGrey, // Disconnect 按钮背景色
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50), // 圆角
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 16.0), // 垂直内边距
//                     ),
//                     child: const Text(
//                       "Disconnect",
//                       style: TextStyle(
//                         color: Colors.white70, // 字体颜色淡化
//                         fontSize: 16, // 字体大小
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 20), // 按钮之间的间距
//                 SizedBox(
//                   width: 140, // 设定统一宽度
//                   child: ElevatedButton(
//                     onPressed: () => connect(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.teal, // Connect 按钮背景色
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50), // 圆角
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 16.0), // 垂直内边距
//                     ),
//                     child: const Text(
//                       "Connect",
//                       style: TextStyle(
//                         color: Colors.white70, // 字体颜色淡化
//                         fontSize: 16, // 字体大小
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------------
// 11/4/2024 ver1
//
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:app/VideoStream/websocket.dart';
// import 'package:app/constants/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:app/styles/styles.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:camera/camera.dart';
// import 'package:app/gesture_detector3d.dart';
//
// late List<CameraDescription> _cameras;
//
// class VideoStream extends StatefulWidget {
//   const VideoStream({Key? key}) : super(key: key);
//
//   @override
//   State<VideoStream> createState() => _VideoStreamState();
// }
//
// class _VideoStreamState extends State<VideoStream> {
//   final WebSocket _socket = WebSocket(Constants.videoWebsocketURL);
//   bool _isConnected = false;
//   Timer? picTimer;
//   late CameraController controller;
//
//   @override
//   void initState() {
//     _loadCam();
//     accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
//         .listen(
//           (AccelerometerEvent event) {
//         if (_isConnected) {
//           _socket.sendMessage(jsonEncode({
//             'x': event.x,
//             'y': event.y,
//             'z': event.z,
//             'timestamp': event.timestamp.microsecondsSinceEpoch,
//             'code': "accelerometer"
//           }));
//         }
//       },
//       onError: (error) {},
//       cancelOnError: true,
//     );
//     gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
//           (GyroscopeEvent event) {
//         if (_isConnected) {
//           _socket.sendMessage(jsonEncode({
//             'x': event.x,
//             'y': event.y,
//             'z': event.z,
//             'timestamp': event.timestamp.microsecondsSinceEpoch,
//             'code': "gyroscope"
//           }));
//         }
//       },
//       onError: (error) {},
//       cancelOnError: true,
//     );
//     startPictureTimer();
//     super.initState();
//   }
//
//   Future<void> _loadCam() async {
//     _cameras = await availableCameras();
//     controller = CameraController(_cameras[0], ResolutionPreset.medium);
//
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     }).catchError((Object e) {
//       if (e is CameraException) {
//         print(e.code);
//       }
//     });
//   }
//
//   void connect(BuildContext context) async {
//     _socket.connect();
//     setState(() {
//       _isConnected = true;
//     });
//   }
//
//   void disconnect() {
//     setState(() {
//       _isConnected = false;
//     });
//     _socket.disconnect();
//   }
//
//   void startPictureTimer() {
//     if (picTimer != null && picTimer!.isActive) {
//       return;
//     }
//     picTimer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
//       if (_isConnected) {
//         sendPicture();
//       }
//     });
//   }
//
//   void sendPicture() async {
//     int timestamp1 = DateTime.now().millisecondsSinceEpoch;
//     final XFile image = await controller.takePicture();
//     int timestamp2 = DateTime.now().millisecondsSinceEpoch;
//     Uint8List imageBytes = await image.readAsBytes();
//
//     Map<String, dynamic> message = {
//       'timestamp1': timestamp1,
//       'timestamp2': timestamp2,
//       'image': base64Encode(imageBytes),
//     };
//     _socket.sendMessage(jsonEncode(message));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("3DGS RealTime Rendering"),
//         backgroundColor: Colors.blueGrey,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // 视频显示区域
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.blueGrey[50], // 背景颜色
//                   borderRadius: BorderRadius.circular(4), // 圆角边框
//                   border: Border.all(color: Colors.blueGrey), // 边框颜色
//                 ),
//                 child: _isConnected
//                     ? Drag(
//                     StreamBuilder(
//                       stream: _socket.stream,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         if (snapshot.connectionState == ConnectionState.active &&
//                             snapshot.hasData) {
//                           return Image.memory(
//                             Uint8List.fromList(
//                               base64Decode(snapshot.data.toString()),
//                             ),
//                             fit: BoxFit.cover,
//                             gaplessPlayback: true,
//                             excludeFromSemantics: true,
//                           );
//                         }
//                         return const Center(
//                           child: Text(
//                             "Connection Closed!",
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         );
//                       },
//                     ),
//                     _socket.sendMessage)
//                     : const Center(
//                   child: Text(
//                     "Waiting for video connection...",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             // 按钮区
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 SizedBox(
//                   width: 140, // 设定统一宽度
//                   child: ElevatedButton(
//                     onPressed: _isConnected ? disconnect : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _isConnected ? Colors.blueGrey : Colors.grey, // Disconnect 按钮背景色
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50), // 圆角
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 16.0), // 垂直内边距
//                     ),
//                     child: const Text(
//                       "Disconnect",
//                       style: TextStyle(
//                         color: Colors.white70, // 字体颜色淡化
//                         fontSize: 16, // 字体大小
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 20), // 按钮之间的间距
//                 SizedBox(
//                   width: 140, // 设定统一宽度
//                   child: ElevatedButton(
//                     onPressed: _isConnected ? null : () => connect(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _isConnected ? Colors.grey : Colors.teal, // Connect 按钮背景色
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50), // 圆角
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 16.0), // 垂直内边距
//                     ),
//                     child: const Text(
//                       "Connect",
//                       style: TextStyle(
//                         color: Colors.white70, // 字体颜色淡化
//                         fontSize: 16, // 字体大小
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//ver2 视频居中，可拖拽，修改按键风格
// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:app/VideoStream/websocket.dart';
// import 'package:app/constants/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:app/styles/styles.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:camera/camera.dart';
// import 'package:app/gesture_detector3d.dart';
//
// late List<CameraDescription> _cameras;
//
// class VideoStream extends StatefulWidget {
//   const VideoStream({Key? key}) : super(key: key);
//
//   @override
//   State<VideoStream> createState() => _VideoStreamState();
// }
//
// class _VideoStreamState extends State<VideoStream> {
//   final WebSocket _socket = WebSocket(Constants.videoWebsocketURL);
//   bool _isConnected = false;
//   Timer? picTimer;
//   late CameraController controller;
//
//   @override
//   void initState() {
//     _loadCam();
//     accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
//           (AccelerometerEvent event) {
//         if (_isConnected) {
//           _socket.sendMessage(jsonEncode({
//             'x': event.x,
//             'y': event.y,
//             'z': event.z,
//             'timestamp': event.timestamp.microsecondsSinceEpoch,
//             'code': "accelerometer"
//           }));
//         }
//       },
//       onError: (error) {},
//       cancelOnError: true,
//     );
//     gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
//           (GyroscopeEvent event) {
//         if (_isConnected) {
//           _socket.sendMessage(jsonEncode({
//             'x': event.x,
//             'y': event.y,
//             'z': event.z,
//             'timestamp': event.timestamp.microsecondsSinceEpoch,
//             'code': "gyroscope"
//           }));
//         }
//       },
//       onError: (error) {},
//       cancelOnError: true,
//     );
//     startPictureTimer();
//     super.initState();
//   }
//
//   Future<void> _loadCam() async {
//     _cameras = await availableCameras();
//     controller = CameraController(_cameras[0], ResolutionPreset.medium);
//
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     }).catchError((Object e) {
//       if (e is CameraException) {
//         print(e.code);
//       }
//     });
//   }
//
//   void connect(BuildContext context) async {
//     _socket.connect();
//     setState(() {
//       _isConnected = true;
//     });
//   }
//
//   void disconnect() {
//     setState(() {
//       _isConnected = false;
//     });
//     _socket.disconnect();
//   }
//
//   void startPictureTimer() {
//     if (picTimer != null && picTimer!.isActive) {
//       return;
//     }
//     picTimer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
//       if (_isConnected) {
//         sendPicture();
//       }
//     });
//   }
//
//   void sendPicture() async {
//     int timestamp1 = DateTime.now().millisecondsSinceEpoch;
//     final XFile image = await controller.takePicture();
//     int timestamp2 = DateTime.now().millisecondsSinceEpoch;
//     Uint8List imageBytes = await image.readAsBytes();
//
//     Map<String, dynamic> message = {
//       'timestamp1': timestamp1,
//       'timestamp2': timestamp2,
//       'image': base64Encode(imageBytes),
//     };
//     _socket.sendMessage(jsonEncode(message));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("3DGS RealTime Rendering"),
//         backgroundColor: Colors.blueGrey[800]?.withOpacity(0.8), // 增加透明度
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // 视频显示区域
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.blueGrey[50]?.withOpacity(0.6), // 增加透明度
//                   borderRadius: BorderRadius.circular(12), // 更大的圆角
//                   border: Border.all(color: Colors.blueGrey.withOpacity(0.4)), // 边框透明度
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: _isConnected
//                     ? Center(
//                   child: Drag(
//                     StreamBuilder(
//                       stream: _socket.stream,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         if (snapshot.connectionState == ConnectionState.active &&
//                             snapshot.hasData) {
//                           return Center(
//                             child: Image.memory(
//                               Uint8List.fromList(
//                                 base64Decode(snapshot.data.toString()),
//                               ),
//                               fit: BoxFit.contain, // 改为 contain 使视频居中
//                               gaplessPlayback: true,
//                               excludeFromSemantics: true,
//                             ),
//                           );
//                         }
//                         return Center(
//                           child: Text(
//                             "Connection Closed!",
//                             style: Styles.statusTextStyle,
//                           ),
//                         );
//                       },
//                     ),
//                     _socket.sendMessage,
//                   ),
//                 )
//                     : Center(
//                   child: Text(
//                     "Waiting for video connection...",
//                     style: Styles.statusTextStyle,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             // 按钮区
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 SizedBox(
//                   width: 140,
//                   child: ElevatedButton(
//                     onPressed: _isConnected ? disconnect : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _isConnected
//                           ? Colors.blueGrey[800]?.withOpacity(0.6)
//                           : Colors.grey.withOpacity(0.4),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     ),
//                     child: const Text(
//                       "Disconnect",
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 SizedBox(
//                   width: 140,
//                   child: ElevatedButton(
//                     onPressed: _isConnected ? null : () => connect(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _isConnected
//                           ? Colors.grey.withOpacity(0.4)
//                           : Colors.teal.withOpacity(0.8),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     ),
//                     child: const Text(
//                       "Connect",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


//ver3 金属风格
// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:app/VideoStream/websocket.dart';
// import 'package:app/constants/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:app/styles/styles.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:camera/camera.dart';
// import 'package:app/gesture_detector3d.dart';
//
// late List<CameraDescription> _cameras;
//
// class VideoStream extends StatefulWidget {
//   const VideoStream({Key? key}) : super(key: key);
//
//   @override
//   State<VideoStream> createState() => _VideoStreamState();
// }
//
// class _VideoStreamState extends State<VideoStream> {
//   final WebSocket _socket = WebSocket(Constants.videoWebsocketURL);
//   bool _isConnected = false;
//   bool isConnectPressed = false; // Track Connect button state
//   bool isDisconnectPressed = false; // Track Disconnect button state
//   Timer? picTimer;
//   late CameraController controller;
//
//   @override
//   void initState() {
//     _loadCam();
//     accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
//           (AccelerometerEvent event) {
//         if (_isConnected) {
//           _socket.sendMessage(jsonEncode({
//             'x': event.x,
//             'y': event.y,
//             'z': event.z,
//             'timestamp': event.timestamp.microsecondsSinceEpoch,
//             'code': "accelerometer"
//           }));
//         }
//       },
//       onError: (error) {},
//       cancelOnError: true,
//     );
//     gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
//           (GyroscopeEvent event) {
//         if (_isConnected) {
//           _socket.sendMessage(jsonEncode({
//             'x': event.x,
//             'y': event.y,
//             'z': event.z,
//             'timestamp': event.timestamp.microsecondsSinceEpoch,
//             'code': "gyroscope"
//           }));
//         }
//       },
//       onError: (error) {},
//       cancelOnError: true,
//     );
//     startPictureTimer();
//     super.initState();
//   }
//
//   Future<void> _loadCam() async {
//     _cameras = await availableCameras();
//     controller = CameraController(_cameras[0], ResolutionPreset.medium);
//
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     }).catchError((Object e) {
//       if (e is CameraException) {
//         print(e.code);
//       }
//     });
//   }
//
//   void connect(BuildContext context) async {
//     _socket.connect();
//     setState(() {
//       _isConnected = true;
//       isConnectPressed = true; // Keep Connect button pressed
//       isDisconnectPressed = false; // Reset Disconnect button
//     });
//   }
//
//   void disconnect() {
//     setState(() {
//       _isConnected = false;
//       isDisconnectPressed = true; // Keep Disconnect button pressed
//       isConnectPressed = false; // Reset Connect button
//     });
//     _socket.disconnect();
//   }
//
//   void startPictureTimer() {
//     if (picTimer != null && picTimer!.isActive) {
//       return;
//     }
//     picTimer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
//       if (_isConnected) {
//         sendPicture();
//       }
//     });
//   }
//
//   void sendPicture() async {
//     int timestamp1 = DateTime.now().millisecondsSinceEpoch;
//     final XFile image = await controller.takePicture();
//     int timestamp2 = DateTime.now().millisecondsSinceEpoch;
//     Uint8List imageBytes = await image.readAsBytes();
//
//     Map<String, dynamic> message = {
//       'timestamp1': timestamp1,
//       'timestamp2': timestamp2,
//       'image': base64Encode(imageBytes),
//     };
//     _socket.sendMessage(jsonEncode(message));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // 按钮颜色
//     final buttonColor = Colors.teal[600]!;
//     final buttonPressedColor = Colors.teal[400]!;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("3DGS RealTime Rendering"),
//         backgroundColor: Colors.blueGrey[800]?.withOpacity(0.8),
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.grey[900]!, Colors.grey[700]!],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // 视频显示区域
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.blueGrey[50]?.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.blueGrey.withOpacity(0.4)),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 16,
//                       offset: Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: _isConnected
//                     ? Center(
//                   child: Drag(
//                     StreamBuilder(
//                       stream: _socket.stream,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         if (snapshot.connectionState == ConnectionState.active &&
//                             snapshot.hasData) {
//                           return Center(
//                             child: Image.memory(
//                               Uint8List.fromList(
//                                 base64Decode(snapshot.data.toString()),
//                               ),
//                               fit: BoxFit.contain,
//                               gaplessPlayback: true,
//                               excludeFromSemantics: true,
//                             ),
//                           );
//                         }
//                         return Center(
//                           child: Text(
//                             "Connection Closed!",
//                             style: Styles.statusTextStyle,
//                           ),
//                         );
//                       },
//                     ),
//                     _socket.sendMessage,
//                   ),
//                 )
//                     : Center(
//                   child: Text(
//                     "Waiting for video connection...",
//                     style: Styles.statusTextStyle,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             // 按钮区
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 SizedBox(
//                   width: 140,
//                   child: ElevatedButton(
//                     onPressed: _isConnected ? disconnect : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: isDisconnectPressed
//                           ? buttonPressedColor
//                           : buttonColor, // Pressed state color
//                       shadowColor: Colors.black.withOpacity(0.3),
//                       elevation: 6,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     ),
//                     child: const Text(
//                       "Disconnect",
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 SizedBox(
//                   width: 140,
//                   child: ElevatedButton(
//                     onPressed: _isConnected ? null : () => connect(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: isConnectPressed
//                           ? buttonPressedColor
//                           : buttonColor, // Pressed state color
//                       shadowColor: Colors.black.withOpacity(0.3),
//                       elevation: 6,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     ),
//                     child: const Text(
//                       "Connect",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
/*
*
1. 颜色方案
主色调：选择深灰色和金属蓝作为主色调。这两种颜色在科技风和实时渲染的应用中具有经典的视觉吸引力。
按钮颜色：使用金属感的深蓝色作为按钮的主要颜色，并在按下后变为更浅的蓝色或者金属绿色，以呼应实时渲染的冷色系。
渐变效果：在视频框背景或按钮背景中，使用蓝绿色渐变，增强界面的层次感，使其看起来更像“屏幕”或“显示器”的效果。
高光/阴影：为按钮和视频框添加更柔和的阴影和浅色高光，以模仿屏幕反光的效果，增强视觉深度。
2. 颜色真值
主背景渐变：[Colors.blueGrey[900]!, Colors.grey[800]!]
按钮默认颜色：Color(0xFF1E3A5F)（深金属蓝）
按钮按下颜色：Color(0xFF3A5F85)（浅金属蓝或蓝绿色）
按钮高光：Color(0xFF78909C)（浅灰蓝）
3. 按钮区分
按钮颜色：将 buttonColor 和 buttonPressedColor 定义为深色，以便在按下时与背景区分开来。
阴影：加深了按钮的阴影颜色 buttonShadowColor，并提高了 elevation 的值为 10，使按钮看起来更加立体。
高光效果：在背景渐变中加入稍亮的色调（蓝灰色和深灰色），以模拟屏幕边缘的光泽效果。

视频框装饰：在视频框的 BoxDecoration 中使用了深色到浅灰色的渐变背景，并增加了深色阴影来模拟屏幕的立体感。
按钮颜色与阴影：定义了 buttonColor（按钮默认颜色）和 buttonPressedColor（按钮按下颜色），使按钮在不同状态下有更强烈的对比。同时增加 shadowColor 和较大的 elevation 来突出按钮。
状态管理：在 connect 和 disconnect 方法中切换 isConnectPressed 和 isDisconnectPressed 的状态，以保持按钮按下后的颜色变化。
这个设计意图是确保按钮在未按下和按下的状态下都能明显区分，同时使视频区域更像是一个屏幕，带有渐变和阴影效果。这样可以突出 3D 实时渲染的科技感。
*
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

late List<CameraDescription> _cameras;

class VideoStream extends StatefulWidget {
  const VideoStream({Key? key}) : super(key: key);

  @override
  State<VideoStream> createState() => _VideoStreamState();
}

class _VideoStreamState extends State<VideoStream> {
  final WebSocket _socket = WebSocket(Constants.videoWebsocketURL);
  bool _isConnected = false;
  bool isConnectPressed = false;
  bool isDisconnectPressed = false;
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

  void connect(BuildContext context) async {
    _socket.connect();
    setState(() {
      _isConnected = true;
      isConnectPressed = true;
      isDisconnectPressed = false;
    });
  }

  void disconnect() {
    setState(() {
      _isConnected = false;
      isDisconnectPressed = true;
      isConnectPressed = false;
    });
    _socket.disconnect();
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
                  child: Text(
                    "Waiting for video connection...",
                    style: Styles.statusTextStyle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            // 按钮区

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: _isConnected ? disconnect : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDisconnectPressed ? buttonPressedColor : buttonColor,
                      shadowColor: buttonShadowColor,
                      elevation: isDisconnectPressed ? 5 : 10, // 按下时降低阴影以增加融合效果
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      "Disconnect",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: _isConnected ? null : () => connect(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConnectPressed ? buttonPressedColor : buttonColor,
                      shadowColor: buttonShadowColor,
                      elevation: isConnectPressed ? 5 : 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      "Connect",
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
