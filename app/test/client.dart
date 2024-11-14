/*
 * @Author: vic123 zhangzc_efz@163.com
 * @Date: 2024-09-03 16:48:14
 * @LastEditors: vic123 zhangzc_efz@163.com
 * @LastEditTime: 2024-09-09 18:42:56
 * @FilePath: \app\test\client.dart
 * @Description: 
 * 
 * Copyright (c) 2024 by vic123, All Rights Reserved. 
 */
import 'package:web_socket_channel/io.dart';

main() async {
  var channel = IOWebSocketChannel.connect(Uri.parse('ws://192.168.2.38:5000'));

  channel.stream.listen((message) {
    print(message);
    channel.sink.add('received!');
    // channel.sink.close(status.goingAway);
  });
}
