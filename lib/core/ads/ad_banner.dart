import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_service.dart';

/// The banner strip pinned to the bottom of every screen.
///
/// It only takes up space once an ad has actually loaded, so a player with no
/// connection — or one who bought Full Unlock — sees the game full height
/// instead of an empty grey bar.
class AdBannerBar extends StatefulWidget {
  const AdBannerBar({super.key, required this.ads});

  final AdService ads;

  @override
  State<AdBannerBar> createState() => _AdBannerBarState();
}

class _AdBannerBarState extends State<AdBannerBar> {
  BannerAd? _ad;
  bool _loaded = false;
  int _width = 0;

  @override
  void initState() {
    super.initState();
    widget.ads.addListener(_reload);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (width != _width) {
      _width = width;
      _reload();
    }
  }

  Future<void> _reload() async {
    if (!mounted) return;
    _dispose();
    if (!widget.ads.ready || _width <= 0) {
      if (mounted) setState(() {});
      return;
    }
    try {
      final size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(_width);
      if (size == null || !mounted) return;
      final ad = BannerAd(
        adUnitId: AdConfig.bannerUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('banner failed: ${error.code} ${error.message}');
            ad.dispose();
            if (mounted) setState(() => _loaded = false);
          },
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (e) {
      debugPrint('banner: $e');
    }
  }

  void _dispose() {
    _ad?.dispose();
    _ad = null;
    _loaded = false;
  }

  @override
  void dispose() {
    widget.ads.removeListener(_reload);
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
