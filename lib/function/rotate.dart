import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

class RotatePage extends StatefulWidget {
  const RotatePage({super.key});

  @override
  _RotatePageState createState() => _RotatePageState();
}

class _RotatePageState extends State<RotatePage> {
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
                        '旋转屏幕',
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
          crossAxisCount: 2, // 一行两个按钮
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.5, // 维持按钮原高度
          children: _buildButtons(),
        ),
      ),
    );
  }

  List<Widget> _buildButtons() {
    List<Map<String, dynamic>> buttonData = [
      {"name": "向左旋转", "rotation": "1"},
      {"name": "向右旋转", "rotation": "3"},
      {"name": "上下翻转", "rotation": "2"},
      {"name": "恢复默认", "rotation": "0"},
    ];

    return buttonData.map((button) {
      return _buildButton(button["name"], () => _rotateScreen(button["rotation"]));
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

  Future<void> _rotateScreen(String rotation) async {
    if (!_isDeviceConnected) {
      _showMessage(context, "设备未连接", "请先连接设备");
      return;
    }

    try {
      ProcessResult result = await Process.run(
          'adb', ['shell', 'settings', 'put', 'system', 'user_rotation', rotation]);
      if (result.exitCode == 0) {
        print("成功旋转屏幕：$rotation");
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
