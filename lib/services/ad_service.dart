import 'dart:io';

class AdService {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-4588211425588192/4487213379";
    } else if (Platform.isIOS) {
      return "ca-app-pub-4588211425588192/3212255186";
    } else {
      throw UnsupportedError("Error: Unsupported Platform");
    }
  }
}
