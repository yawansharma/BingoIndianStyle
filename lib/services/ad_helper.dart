import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1396135493947235/7013056944'; // Test ID for Android Banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID for iOS Banner
    } else {
      return '';
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1396135493947235/5185804106'; // Test ID for Android Interstitial
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1396135493947235/5185804106'; // Test ID for iOS Interstitial
    } else {
      return '';
    }
  }

  static String get bannerAdUnitIdLeft {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1396135493947235/7872844482'; // Test ID for Android Banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID for iOS Banner
    } else {
      return '';
    }
  }

  static String get bannerAdUnitIdRight {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1396135493947235/3716847756'; // Test ID for Android Banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID for iOS Banner
    } else {
      return '';
    }
  }

  static String get joinRoomInterstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1396135493947235/8312662337'; // Replace with your actual Android interstitial ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-YOUR_ADMOB_APP_ID/YOUR_JOIN_ROOM_INTERSTITIAL_AD_UNIT_ID'; // Replace with your actual iOS interstitial ID
    } else {
      return '';
    }
  }

  static String get sixBySixInterstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1396135493947235/3060335652'; // Replace with your actual Android ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-YOUR_ADMOB_APP_ID/YOUR_6X6_INTERSTITIAL_AD_UNIT_ID'; // Replace with your actual iOS ID
    } else {
      return '';
    }
  }

  static String get sevenBySevenInterstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1396135493947235/5470010605'; // Replace with your actual Android ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-YOUR_ADMOB_APP_ID/YOUR_7X7_INTERSTITIAL_AD_UNIT_ID'; // Replace with your actual iOS ID
    } else {
      return '';
    }
  }

  static String get eightByEightInterstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1396135493947235/5385152641'; // Replace with your actual Android ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-YOUR_ADMOB_APP_ID/YOUR_8X8_INTERSTITIAL_AD_UNIT_ID'; // Replace with your actual iOS ID
    } else {
      return '';
    }
  }
}
