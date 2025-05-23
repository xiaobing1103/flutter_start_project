import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewerWidget extends StatelessWidget {
  final String modelUrl;
  const ModelViewerWidget({super.key, required this.modelUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ModelViewer(
        src: modelUrl,
        alt: "3D 模型",
        autoRotate: true,
        cameraControls: true,
        disableZoom: true,
        cameraOrbit: "0deg 75deg 2.5m",
        shadowIntensity: 1,
        exposure: 1,
      ),
    );
  }
}
