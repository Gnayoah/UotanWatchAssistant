import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart'; // 导入用于窗口管理的包
import 'package:file_picker/file_picker.dart'; // 导入文件选择器包
import 'dart:io'; // 导入 dart:io 包，用于执行系统命令

class InstallAppPage extends StatefulWidget {
  const InstallAppPage({super.key});

  @override
  _InstallAppPageState createState() => _InstallAppPageState();
}

class _InstallAppPageState extends State<InstallAppPage> {
  String? _installingMessage;
  bool _isInstalling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90.0), // 设置AppBar的高度
        child: Padding(
          padding: const EdgeInsets.only(top: 40), // 设置顶部边距
          child: GestureDetector(
            onPanStart: (details) => windowManager.startDragging(), // 允许拖动窗口
            child: Container(
              color: Colors.transparent, // 设置为透明背景
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 左右对齐
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20), // 返回图标
                        onPressed: _isInstalling ? null : () { // 安装过程中禁用返回按钮
                          Navigator.pop(context); // 返回到上一个页面
                        },
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        '安装应用到手表', // 页面标题
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontFamily: 'MiSansLight', // 使用自定义字体
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isInstalling) // 当不在安装中时显示按钮
              Card(
                color: const Color(0xFFF9F9F9), // 设置按钮背景颜色
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // 设置圆角
                ),
                elevation: 0, // 去掉阴影
                child: InkWell(
                  borderRadius: BorderRadius.circular(8.0), // 设置悬浮时的圆角效果
                  onTap: _isInstalling ? null : () async {
                    await _selectAndInstallApk(context);
                  },
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0), // 保持圆角效果
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        '选择APK文件并安装',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (_isInstalling) // 当安装进行中时显示进度条
              Column(
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black), // 设置进度条颜色为黑色
                  ),
                  const SizedBox(height: 20),
                  Text(_installingMessage ?? '安装进行中，请稍候...'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // 选择APK文件并使用ADB进行安装
  Future<void> _selectAndInstallApk(BuildContext context) async {
    // 先检查是否有设备连接
    bool hasConnectedDevice = await _checkDeviceConnection();
    if (!hasConnectedDevice) {
      _showMessage(context, '没有连接设备', '没有检测到设备，请确保设备已连接。');
      return; // 如果没有连接设备，直接返回
    }

    // 使用文件选择器选择APK文件
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );

    if (result != null && result.files.isNotEmpty) {
      // 获取所选文件的路径
      String filePath = result.files.single.path!;

      setState(() {
        _isInstalling = true; // 开始安装
        _installingMessage = '安装进行中，请稍候...';
      });

      // 运行ADB命令进行安装
      try {
        // 使用 Process.start 来启动异步进程
        Process process = await Process.start('adb', ['install', '-r', filePath]);

        process.stdout.transform(SystemEncoding().decoder).listen((data) {
          setState(() {
            _installingMessage = data.trim(); // 更新安装过程的消息
          });
        });

        process.stderr.transform(SystemEncoding().decoder).listen((data) {
          setState(() {
            _installingMessage = '错误: $data'; // 显示错误信息
          });
        });

        int exitCode = await process.exitCode; // 等待进程完成
        setState(() {
          _isInstalling = false; // 结束安装
        });

        // 弹窗提示安装结果
        _showMessage(
          context,
          exitCode == 0 ? '安装成功' : '安装失败',
          exitCode == 0 ? '应用已成功安装！' : _installingMessage ?? '安装过程中出现问题。',
        );
      } catch (e) {
        setState(() {
          _isInstalling = false;
          _installingMessage = '安装失败：$e';
        });
        _showMessage(context, '安装失败', '出现错误：$e');
      }
    } else {
      _showMessage(context, '提示', '未选择任何文件');
    }
  }

  // 检查是否有设备连接
  Future<bool> _checkDeviceConnection() async {
    try {
      ProcessResult result = await Process.run('adb', ['devices']);
      String output = result.stdout.toString();

      // 过滤掉第一行标题，并检查是否有任何设备行存在
      List<String> lines = output.split('\n');
      for (var line in lines.skip(1)) { // 跳过第一行
        if (line.contains('\tdevice')) {
          return true; // 发现连接的设备
        }
      }
    } catch (e) {
      print('检查设备连接失败：$e');
    }
    return false; // 没有设备连接
  }

  // 显示提示消息
  void _showMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF9F9F9), // 设置弹窗背景颜色为 #F9F9F9
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed) || states.contains(MaterialState.hovered)) {
                      return const Color.fromARGB(255, 237, 237, 237); // 点击或悬浮时的背景颜色
                    }
                    return null; // 默认状态下不更改颜色
                  },
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black), // 文本颜色
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
