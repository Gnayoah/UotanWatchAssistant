import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

class PairPage extends StatefulWidget {
  const PairPage({super.key});

  @override
  _PairPageState createState() => _PairPageState();
}

class _PairPageState extends State<PairPage> {
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
                        '免重置重新配对(WearOS)',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text(
              "第一步",
              style: TextStyle(fontSize: 20, ),
              
            ),
             const Text(
              "在旧手机设置中，断开并删除手机与手表的蓝牙配对连接",
              style: TextStyle(fontSize: 16, ),
            ),
              const SizedBox(height: 30), 
            const Text(
              "第二步",
              style: TextStyle(fontSize: 20, ),
            ),
             
            const SizedBox(height: 10),
            _buildButton("清除 Google 服务并重启", _clearGoogleServicesAndReboot),
            const SizedBox(height: 30), // 间隔

            const Text(
              "第三步",
              style: TextStyle(fontSize: 20, ),
            ),
           
            _buildButton("开启蓝牙可见模式", _enableBluetoothDiscoverable),
            const SizedBox(height: 30), // 间隔
             const Text(
              "第四步",
              style: TextStyle(fontSize: 20, ),
              
            ),
             const Text(
              "在新手机上，打开 WearOS By Google 应用，配对连接手表",
              style: TextStyle(fontSize: 16, ),
            ),
          ],
        ),
      ),
    );
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

  /// **第一步：清除 Google Play 服务并重启**
  Future<void> _clearGoogleServicesAndReboot() async {
    if (!_isDeviceConnected) {
      _showMessage(context, "设备未连接", "请先连接设备");
      return;
    }

    try {
      // 清除 Google Play 服务
      ProcessResult clearResult = await Process.run('adb', ['shell', 'pm', 'clear', 'com.google.android.gms']);
      if (clearResult.exitCode != 0) {
        _showMessage(context, "错误", "清除 Google 服务失败: ${clearResult.stderr}");
        return;
      }

      // 重启设备
      ProcessResult rebootResult = await Process.run('adb', ['shell', 'reboot']);
      if (rebootResult.exitCode == 0) {
        _showMessage(context, "成功", "设备正在重启...");
      } else {
        _showMessage(context, "错误", "重启失败: ${rebootResult.stderr}");
      }
    } catch (e) {
      _showMessage(context, "错误", "执行失败: $e");
    }
  }

  /// **第二步：开启蓝牙可见模式**
  Future<void> _enableBluetoothDiscoverable() async {
    if (!_isDeviceConnected) {
      _showMessage(context, "设备未连接", "请先连接设备");
      return;
    }

    try {
      ProcessResult result = await Process.run('adb', [
        'shell',
        'am',
        'start',
        '-a',
        'android.bluetooth.adapter.action.REQUEST_DISCOVERABLE'
      ]);
      if (result.exitCode == 0) {
        _showMessage(context, "成功", "蓝牙可见模式已开启");
      } else {
        _showMessage(context, "错误", "执行失败: ${result.stderr}");
      }
    } catch (e) {
      _showMessage(context, "错误", "执行失败: $e");
    }
  }

  /// **检查 ADB 设备连接**
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

  /// **弹窗显示执行结果**
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
