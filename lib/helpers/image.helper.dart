import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class ImageHelper {
  static final ImageHelper _instance = ImageHelper.internal();

  factory ImageHelper() => _instance;

  ImageHelper.internal();

  ImageProvider showImage(String img) {
    if (kIsWeb) {
      return NetworkImage(img);
    } else {
      return FileImage(File(img));
    }
  }
}
