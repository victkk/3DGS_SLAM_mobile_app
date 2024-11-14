// import 'package:flutter/material.dart';
//
// class Styles {
//   static final buttonStyle =
//       ElevatedButton.styleFrom(fixedSize: const Size(120.0, 10.0));
//
//   static final buttonStyle2 = ElevatedButton.styleFrom(
//     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.all(
//         Radius.circular(30),
//       ),
//     ),
//     backgroundColor: Colors.blue,
//     minimumSize: const Size(200, 40),
//   );
//
//   static const textStyle = TextStyle(
//       color: Colors.blue,
//       fontFamily: 'Kalam',
//       fontSize: 20,
//       fontWeight: FontWeight.bold);
// }
// import 'package:flutter/material.dart';
//
// class Styles {
//   // 原按钮样式
//   static final buttonStyle =
//   ElevatedButton.styleFrom(fixedSize: const Size(120.0, 10.0));
//
//   // 新增的按钮样式2
//   static final buttonStyle2 = ElevatedButton.styleFrom(
//     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.all(
//         Radius.circular(30),
//       ),
//     ),
//     backgroundColor: Colors.blue,
//     minimumSize: const Size(200, 40),
//   );
//
//   // 新增视频框样式
//   static final videoFrameDecoration = BoxDecoration(
//     color: Colors.blueGrey[50],
//     borderRadius: BorderRadius.circular(20), // 设置较小的圆角
//     border: Border.all(color: Colors.blueGrey),
//   );
//
//   // 原文字样式
//   static const textStyle = TextStyle(
//       color: Colors.blue,
//       fontFamily: 'Kalam',
//       fontSize: 20,
//       fontWeight: FontWeight.bold);
//
//   // 新增状态文字样式
//   static const statusTextStyle = TextStyle(
//       color: Colors.grey, fontSize: 16, fontStyle: FontStyle.italic);
// }
//
//ver2 的统一样式
// import 'package:flutter/material.dart';
//
// class Styles {
//   // 主按钮样式：带透明度、圆角和较大的 padding
//   static final buttonStyle = ElevatedButton.styleFrom(
//     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(30),
//     ),
//     backgroundColor: Colors.teal.withOpacity(0.8), // 使用主色调，带透明度
//     minimumSize: const Size(140, 50), // 保持按钮宽度一致
//   );
//
//   // 禁用按钮样式：灰色，带透明度
//   static final disabledButtonStyle = ElevatedButton.styleFrom(
//     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(30),
//     ),
//     backgroundColor: Colors.grey.withOpacity(0.4), // 浅灰色，带透明度
//     minimumSize: const Size(140, 50),
//   );
//
//   // 视频框样式：淡蓝色背景、轻微圆角和阴影
//   static final videoFrameDecoration = BoxDecoration(
//     color: Colors.blueGrey[50]?.withOpacity(0.6), // 带透明度的淡蓝色
//     borderRadius: BorderRadius.circular(12), // 较大的圆角
//     border: Border.all(color: Colors.blueGrey.withOpacity(0.4)), // 边框带透明度
//     boxShadow: [
//       BoxShadow(
//         color: Colors.black.withOpacity(0.1),
//         blurRadius: 10,
//         offset: Offset(0, 4),
//       ),
//     ],
//   );
//
//   // 原文字样式：用于主标题或重要文字
//   static const textStyle = TextStyle(
//     color: Colors.blueGrey,
//     fontFamily: 'Kalam',
//     fontSize: 20,
//     fontWeight: FontWeight.bold,
//   );
//
//   // 状态文字样式：用于显示状态提示的文字
//   static const statusTextStyle = TextStyle(
//     color: Colors.grey, // 稍微深一点的灰色
//     fontSize: 16,
//     fontStyle: FontStyle.italic,
//   );
//
//   // 按钮文字样式：统一按钮文字颜色和大小
//   static const buttonTextStyle = TextStyle(
//     color: Colors.white, // 白色文字
//     fontSize: 16,
//   );
// }

//ver3 金属风格
import 'package:flutter/material.dart';

class Styles {
  // 背景颜色渐变：深蓝到浅灰，带有金属风格
  static const backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1E1E2F), // 深蓝色
        Color(0xFF2D2D44), // 中深灰蓝色
        Color(0xFF4A4A65), // 浅灰蓝色
      ],
    ),
  );

  // 按钮样式：带有金属感渐变背景和内阴影效果
  static final buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    backgroundColor: const Color(0xFF1F1F2E), // 按钮主背景色，接近金属风格
    shadowColor: Colors.black.withOpacity(0.4), // 按钮的阴影
    elevation: 8, // 提高立体感
  ).copyWith(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      return states.contains(WidgetState.pressed)
          ? const Color(0xFF383857) // 按下时的深蓝灰色
          : const Color(0xFF2A2A40); // 默认金属灰蓝色
    }),
  );

  // 标题栏样式
  static const appBarStyle = AppBarTheme(
    color: Color(0xFF2E2E3E), // 标题栏深金属灰
    elevation: 4,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      fontFamily: 'RobotoMono', // 字体带有科技感
    ),
  );

  // 视频框样式：带有金属边框和轻微阴影的3D效果
  static final videoFrameDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xFF1E1E2F), // 深金属色
        Color(0xFF2E2E4D), // 中灰蓝色
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // 按钮文字样式：白色，带些微阴影
  static const buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    shadows: [
      Shadow(
        color: Colors.black38,
        offset: Offset(0, 1),
        blurRadius: 1,
      ),
    ],
  );

  // 状态文字样式：金属灰色
  static const statusTextStyle = TextStyle(
    color: Color(0xFFC0C0C0), // 金属灰色
    fontSize: 16,
    fontStyle: FontStyle.italic,
  );
}

