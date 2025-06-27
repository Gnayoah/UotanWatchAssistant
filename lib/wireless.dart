import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

class WirelessPage extends StatefulWidget {
  const WirelessPage({super.key});

  @override
  _WirelessPageState createState() => _WirelessPageState();
}

class _WirelessPageState extends State<WirelessPage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: "5555"); // 默认端口

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
                        '无线连接设备',
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
              "输入设备 IP 地址和端口",
              style: TextStyle(fontSize: 18, ),
            ),
            const SizedBox(height: 10),
            
            // IP 地址输入框
            _buildTextField("设备 IP 地址", _ipController),
            const SizedBox(height: 10),

            // 端口输入框
            _buildTextField("端口号", _portController, isNumeric: true),
            const SizedBox(height: 20),

            // 连接按钮
            _buildButton("连接设备", _connectDevice),
          ],
        ),
      ),
    );
  }

  /// **构建输入框**
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  /// **构建按钮**
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

  /// **执行 ADB 连接**
  Future<void> _connectDevice() async {
    String ip = _ipController.text.trim();
    String port = _portController.text.trim();

    if (ip.isEmpty || port.isEmpty) {
      _showMessage(context, "错误", "请填写完整的 IP 地址和端口号");
      return;
    }

    String target = "$ip:$port";
    try {
      ProcessResult result = await Process.run('adb', ['connect', target]);
      if (result.stdout.contains("connected to")) {
        _showMessage(context, "成功", "设备已成功连接到 $target");
      } else {
        _showMessage(context, "错误", "连接失败: ${result.stdout}\n${result.stderr}");
      }
    } catch (e) {
      _showMessage(context, "错误", "执行失败: $e");
    }
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
