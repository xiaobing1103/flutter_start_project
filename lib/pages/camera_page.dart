import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras![0], ResolutionPreset.high);
    await _controller!.initialize();
    setState(() {
      _isCameraReady = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    // 恢复状态栏为白色背景和深色图标
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: const Color.fromARGB(0, 255, 255, 255),
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏颜色
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: const Color.fromARGB(255, 57, 58, 62), // 状态栏背景色
        statusBarIconBrightness: Brightness.light, // 状态栏图标颜色（白色）
      ),
    );
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: _isCameraReady
          ? Stack(
              children: [
                CameraPreview(_controller!),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                      color: const Color.fromARGB(255, 57, 58, 62), // 灰色背景
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top), // 适配状态栏
                      height: 50 + MediaQuery.of(context).padding.top, // 总高度
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          '边界AIchat',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      )),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera, color: Colors.black),
                      onPressed: () async {
                        // 拍照逻辑
                        final image = await _controller!.takePicture();
                        // 这里可以处理图片（如预览、保存等）
                      },
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
