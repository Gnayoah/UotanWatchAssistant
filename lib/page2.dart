import 'package:flutter/material.dart';
import 'package:watch_assistant/function/button.dart';
import 'package:watch_assistant/function/pair.dart';
import 'package:watch_assistant/function/rotate.dart';
import 'package:window_manager/window_manager.dart';
import 'function/installApp.dart'; // 导入installApp页面
import 'function/app.dart'; // 导入 app 页面
import 'function/type.dart'; 
import 'function/display.dart'; 
import 'function/file.dart'; 

class Page2 extends StatelessWidget {
  const Page2({super.key});

  // 定义一个包含图标和文本的列表
  final List<Map<String, dynamic>> buttonData = const [
    {'icon': 'assets/icons/download_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.png', 'text': '安装应用'},
    {'icon': 'assets/icons/apps_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.png', 'text': '应用管理'},
    {'icon': 'assets/icons/drive_file_move_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.png', 'text': '文件管理'},
    {'icon': 'assets/icons/edit_note_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.png', 'text': '发送文本'},
    {'icon': 'assets/icons/aod_watch_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.png', 'text': '显示设置'},
    {'icon': 'assets/icons/memory_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.png', 'text': '内存清理'},
    {'icon': 'assets/icons/watch_button_press_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.png', 'text': '按键模拟'},
    {'icon': 'assets/icons/battery_profile.png', 'text': '电池管理'},
    {'icon': 'assets/icons/screen_rotation_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.png', 'text': '强制旋转屏幕'},
    {'icon': 'assets/icons/screenshot_tablet_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.png', 'text': '截屏录屏'},
    {'icon': 'assets/icons/transition_push_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.png', 'text': '重新配对'},
    {'icon': 'assets/icons/android_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.png', 'text': '刷机工具'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20), // 设置顶部边距
          child: GestureDetector(
            onPanStart: (details) => windowManager.startDragging(), // 允许拖动窗口
            child: Container(
              color: Colors.transparent, // 设置为透明背景
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween, // 左右对齐
  children: [
    // 用 Padding 包裹标题以控制它的垂直位置
    const Padding(
      padding: EdgeInsets.only(top: 20), // 调整这个值控制标题往下移动的距离
      child: Text(
        '功能列表', // 可以显示当前页面的名称
        style: TextStyle(
          color: Colors.black,
          fontSize: 26,
          fontFamily: 'MiSansLight', // 使用自定义字体
        ),
      ),
    ),
    Row(
      children: [
        // 最小化按钮
        IconButton(
          icon: Image.asset('assets/mini.png'),
          onPressed: () {
            windowManager.minimize();
          },
        ),
        // 关闭按钮
        IconButton(
          icon: Image.asset('assets/close.png'),
          onPressed: () {
            windowManager.close();
          },
        ),
      ],
    ),
  ],
),

            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 25, left: 20, right: 20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4列
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 3, // 调整子项的宽高比，增加横向空间
          ),
          itemCount: buttonData.length, // 根据按钮列表的长度生成按钮
          itemBuilder: (context, index) {
            return Material(
              color: const Color(0xFFF9F9F9), // 设置背景颜色为浅灰色
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // 设置圆角
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0), // 设置悬浮时的圆角效果
                onTap: () {
                  if (buttonData[index]['text'] == '安装应用') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InstallAppPage()),
                    ); // 跳转到installApp页面
                    
                  } else if (buttonData[index]['text'] == '应用管理') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AppManagementPage()),
                    ); // 跳转到installApp页面
                    
                  }else if (buttonData[index]['text'] == '发送文本') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TypeTextPage()),
                    ); // 跳转到installApp页面
                    
                  }else if (buttonData[index]['text'] == '显示设置') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DisplaySettingsPage()),
                    ); // 跳转到installApp页面
                    
                  }else if (buttonData[index]['text'] == '文件管理') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdbFileManagerPage()),
                    ); // 跳转到installApp页面
                    
                  }else if (buttonData[index]['text'] == '按键模拟') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ButtonPage()),
                    ); // 跳转到installApp页面
                    
                  }else if (buttonData[index]['text'] == '强制旋转屏幕') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RotatePage()),
                    ); // 跳转到installApp页面
                    
                  }else if (buttonData[index]['text'] == '重新配对') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PairPage()),
                    ); // 跳转到installApp页面
                    
                  }
                  else {
                     _showMessage(context, "敬请期待", "由于软件重制，当前版本暂不支持 ${buttonData[index]['text']}，我们将尽快更新支持。");
                   
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 5),
                      Image.asset(
                        buttonData[index]['icon']!, // 动态加载自定义图标
                        width: 20,
                        height: 20,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        buttonData[index]['text'], // 动态设置文本
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

   void _showMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF9F9F9),
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed) || states.contains(MaterialState.hovered)) {
                      return const Color.fromARGB(255, 237, 237, 237);
                    }
                    return null;
                  },
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
              ),
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
