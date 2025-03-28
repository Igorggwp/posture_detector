import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

class PngImage {
  final ByteData bytes;
  final int width;
  final int height;

  PngImage.from(this.bytes, {required this.width, required this.height});
}

extension PngImageExtension on ui.Image {
  Future<PngImage?> toPngImage() async {
    final byteData = await this.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      return Future.error("Could not convert image to png format.");
    }
    return PngImage.from(byteData, width: this.width, height: this.height);
  }
}
