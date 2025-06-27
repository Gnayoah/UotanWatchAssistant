import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key});

  @override
  _ButtonPageState createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  bool _isDeviceConnected = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceConnection().then((connected) {
      setState(() {
        _isDeviceConnected = connected;
      });
      if (!connected) {
        _showMessage(context, "设备未连接", "请检查设备是否连接到电脑，并开启USB调试模式");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: GestureDetector(
            onPanStart: (details) => windowManager.startDragging(),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        '按键模拟',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontFamily: 'MiSansLight',
                        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: GridView.count(
          crossAxisCount: 4, // 一行四个按钮
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 3, // 维持按钮原高度
          children: _buildButtons(),
        ),
      ),
    );
  }

  List<Widget> _buildButtons() {
    List<Map<String, dynamic>> buttonData = [
      {"name": "主键", "keycode": "3"},
      {"name": "返回", "keycode": "4"},
      {"name": "电源", "keycode": "26"},
      {"name": "音量+", "keycode": "24"},
      {"name": "音量-", "keycode": "25"},
      {"name": "扬声器静音", "keycode": "164"},
      {"name": "话筒静音", "keycode": "91"},
      {"name": "电话拨号", "keycode": "5"},
      {"name": "电话1挂断", "keycode": "6"},
      {"name": "暂停/播放", "keycode": "85"},
      {"name": "下一曲", "keycode": "87"},
      {"name": "上一曲", "keycode": "88"},
      {"name": "亮屏", "keycode": "224"},
      {"name": "息屏", "keycode": "223"},
    ];

    return buttonData.map((button) {
      return _buildButton(button["name"], () => _sendAdbKey(button["keycode"]));
    }).toList();
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Card(
      color: const Color(0xFFF9F9F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onPressed,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendAdbKey(String keycode) async {
    if (!_isDeviceConnected) {
      _showMessage(context, "设备未连接", "请先连接设备");
      return;
    }

    try {
      ProcessResult result = await Process.run('adb', ['shell', 'input', 'keyevent', keycode]);
      if (result.exitCode == 0) {
        print("成功发送按键事件：$keycode");
      } else {
        _showMessage(context, "错误", "执行失败: ${result.stderr}");
      }
    } catch (e) {
      _showMessage(context, "错误", "执行失败: $e");
    }
  }

  Future<bool> _checkDeviceConnection() async {
    try {
      ProcessResult result = await Process.run('adb', ['devices']);
      String output = result.stdout.toString();
      List<String> lines = output.split('\n');
      for (var line in lines.skip(1)) {
        if (line.contains('\tdevice')) {
          return true;
        }
      }
    } catch (e) {
      print('检查设备连接失败：$e');
    }
    return false;
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
