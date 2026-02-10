import 'dart:io';

import 'package:flutter/foundation.dart';

class AdService {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return kDebugMode
          ? "ca-app-pub-3940256099942544/9214589741"
          : "ca-app-pub-4588211425588192/4487213379";
    } else if (Platform.isIOS) {
      return "ca-app-pub-4588211425588192/3212255186";
    } else {
      throw UnsupportedError("Error: Unsupported Platform");
    }
  }
}
