import 'dart:io';
import 'package:image/image.dart';

void main() {
  final files = ['assets/icon/app_icon.png', 'assets/splash/splash_logo.png'];
  
  for (final path in files) {
    File file = File(path);
    if (!file.existsSync()) {
      print('File not found: $path');
      continue;
    }
    
    Image? original = decodeImage(file.readAsBytesSync());
    if (original == null) continue;
    
    int newWidth = (original.width * 1.5).toInt();
    int newHeight = (original.height * 1.5).toInt();
    
    Image paddedImage = Image(width: newWidth, height: newHeight);
    
    int dstX = (newWidth - original.width) ~/ 2;
    int dstY = (newHeight - original.height) ~/ 2;
    
    compositeImage(paddedImage, original, dstX: dstX, dstY: dstY);
    
    file.writeAsBytesSync(encodePng(paddedImage));
    print('Successfully padded $path');
  }
}
