import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

/// Google AdMob: a banner pinned to the bottom of every screen and a
/// full-screen ad after every finished maze.
///
/// The game is aimed at children, so every request is tagged as
/// child-directed with a G content rating, which is what the Play Families
/// policy requires. Ads are a bonus, never a dependency: with no connection,
/// no fill, or a failed SDK start-up, nothing loads and the game plays exactly
/// as before. Buying Full Unlock turns ads off for good.
class AdService extends ChangeNotifier {
  AdService({this.enabled = true});

  /// False in tests and wherever no ad plugin exists.
  final bool enabled;

  bool _ready = false;
  bool _adsAllowed = true;
  int _completedSinceInterstitial = 0;
  DateTime _lastInterstitial = DateTime.fromMillisecondsSinceEpoch(0);
  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  bool _showingInterstitial = false;

  bool get ready => _ready && _adsAllowed;

  /// True once the player owns Full Unlock: no banner, no interstitials.
  bool get adsRemoved => !_adsAllowed;

  Future<void> init() async {
    if (!enabled) return;
    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
          maxAdContentRating: MaxAdContentRating.g,
        ),
      );
      await MobileAds.instance.initialize();
      _ready = true;
      notifyListeners();
      _preloadInterstitial();
    } catch (e) {
      debugPrint('ads init: $e');
    }
  }

  /// Called whenever the profile loads or changes.
  void applyEntitlement({required bool fullUnlock}) {
    final allowed = !fullUnlock;
    if (allowed == _adsAllowed) return;
    _adsAllowed = allowed;
    if (!allowed) {
      _interstitial?.dispose();
      _interstitial = null;
    } else {
      _preloadInterstitial();
    }
    notifyListeners();
  }

  // ---- interstitial --------------------------------------------------------

  void _preloadInterstitial() {
    if (!enabled || !ready || _interstitial != null || _loadingInterstitial) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          debugPrint('interstitial load failed: ${error.code} ${error.message}');
        },
      ),
    );
  }

  /// Counts a finished maze. Returns true when this one earns a full-screen
  /// ad, which the caller shows once the player leaves the result screen.
  bool countMazeAndCheck() {
    if (!ready) return false;
    _completedSinceInterstitial++;
    return _completedSinceInterstitial >= AdConfig.mazesPerInterstitial;
  }

  /// Shows the pending full-screen ad, if one is due and loaded. Always
  /// completes — if there is no ad, it returns immediately and play goes on.
  Future<void> showInterstitialIfDue() async {
    if (!ready || _showingInterstitial) return;
    if (_completedSinceInterstitial < AdConfig.mazesPerInterstitial) return;
    if (DateTime.now().difference(_lastInterstitial) < AdConfig.minInterstitialGap) {
      return;
    }
    final ad = _interstitial;
    if (ad == null) {
      // Nothing loaded (offline, no fill): try again for next time and let
      // the player carry on.
      _preloadInterstitial();
      return;
    }
    _interstitial = null;
    _completedSinceInterstitial = 0;
    _lastInterstitial = DateTime.now();
    _showingInterstitial = true;

    final done = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showingInterstitial = false;
        _preloadInterstitial();
        if (!done.isCompleted) done.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('interstitial show failed: ${error.message}');
        ad.dispose();
        _showingInterstitial = false;
        _preloadInterstitial();
        if (!done.isCompleted) done.complete();
      },
    );
    try {
      await ad.show();
    } catch (e) {
      debugPrint('interstitial: $e');
      _showingInterstitial = false;
      if (!done.isCompleted) done.complete();
    }
    // Don't hang the UI if the SDK never calls back.
    await done.future.timeout(const Duration(seconds: 30), onTimeout: () {});
  }

  @override
  void dispose() {
    _interstitial?.dispose();
    super.dispose();
  }
}
