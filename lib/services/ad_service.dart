import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  // Set up family-safe ad configuration
  static void setupFamilySafeAds() {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.t,
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
      ),
    );
  }
}
