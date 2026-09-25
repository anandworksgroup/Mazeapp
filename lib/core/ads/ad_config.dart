import 'dart:io';

/// AdMob identifiers.
///
/// The repository only ever holds Google's public **test** ids, so a debug
/// build can never earn or spend real money. Real ids are injected at build
/// time:
///
/// ```bash
/// flutter build appbundle --release \
///   --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-xxx/yyy \
///   --dart-define=ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-xxx/yyy \
///   --dart-define=ADMOB_BANNER_IOS=ca-app-pub-xxx/yyy \
///   --dart-define=ADMOB_INTERSTITIAL_IOS=ca-app-pub-xxx/yyy
/// ```
///
/// The app id itself lives in the Android manifest and iOS Info.plist and has
/// to be swapped there before release.
class AdConfig {
  AdConfig._();

  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  static const _bannerAndroid =
      String.fromEnvironment('ADMOB_BANNER_ANDROID', defaultValue: _testBannerAndroid);
  static const _bannerIos =
      String.fromEnvironment('ADMOB_BANNER_IOS', defaultValue: _testBannerIos);
  static const _interstitialAndroid = String.fromEnvironment('ADMOB_INTERSTITIAL_ANDROID',
      defaultValue: _testInterstitialAndroid);
  static const _interstitialIos =
      String.fromEnvironment('ADMOB_INTERSTITIAL_IOS', defaultValue: _testInterstitialIos);

  static String get bannerUnitId => Platform.isIOS ? _bannerIos : _bannerAndroid;
  static String get interstitialUnitId =>
      Platform.isIOS ? _interstitialIos : _interstitialAndroid;

  /// True while the build is still pointing at Google's test inventory.
  static bool get usingTestIds =>
      bannerUnitId == _testBannerAndroid ||
      bannerUnitId == _testBannerIos ||
      interstitialUnitId == _testInterstitialAndroid ||
      interstitialUnitId == _testInterstitialIos;

  /// A full-screen ad after every finished maze, by product decision.
  static const mazesPerInterstitial = 1;

  /// Never show two full-screen ads within this window, however fast the
  /// player finishes mazes. Short, because every maze now ends with one: it
  /// only guards against a maze finished seconds after the last ad closed.
  static const minInterstitialGap = Duration(seconds: 10);
}
