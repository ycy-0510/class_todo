import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PreviewPhoto extends StatelessWidget {
  const PreviewPhoto({this.imageProvider, super.key});
  final ImageProvider<Object>? imageProvider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('預覽圖片'),
      ),
      body: Center(
          child: PhotoView(
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 4,
        tightMode: true,
        imageProvider: imageProvider,
      )),
    );
  }
}
