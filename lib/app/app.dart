import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/ads/ad_banner.dart';
import '../core/ads/ad_service.dart';
import '../core/audio/audio_service.dart';
import '../core/constants/game_config.dart';
import '../core/localization/l10n.dart';
import '../core/utilities/purchase_service.dart';
import '../database/database.dart';
import '../features/home/splash_screen.dart';
import '../features/settings/game_settings.dart';
import 'app_controller.dart';
import 'app_scope.dart';
import 'router.dart';
import 'theme.dart';

/// Everything the app needs before the first real screen.
class AppServices {
  AppServices({
    required this.controller,
    required this.audio,
    required this.config,
    required this.purchases,
    required this.ads,
  });

  final AppController controller;
  final AudioService audio;
  final GameConfig config;
  final PurchaseService purchases;
  final AdService ads;

  /// Launch sequence: open the local database (creating the local player
  /// profile on first run), load bundled config, prepare sounds, start the ad
  /// SDK. Only the ads reach for the network, and never block the game.
  static Future<AppServices> boot(AssetBundle bundle) async {
    final db = await AppDatabase.open();
    final controller = AppController(db);
    final results = await Future.wait([
      controller.load(),
      GameConfig.load(bundle),
    ]);
    final config = results[1] as GameConfig;
    final audio = AudioService();
    await audio.init();
    audio.apply(controller.settings);
    final purchases = PurchaseService(
      productId: config.fullUnlockProductId,
      onEntitled: controller.grantFullUnlock,
    )..start();
    final ads = AdService()..applyEntitlement(fullUnlock: controller.player.fullUnlock);
    // Fire and forget: the first frame must not wait for the ad SDK.
    unawaited(ads.init());
    return AppServices(
      controller: controller,
      audio: audio,
      config: config,
      purchases: purchases,
      ads: ads,
    );
  }
}

class MazeAdventureApp extends StatefulWidget {
  const MazeAdventureApp({super.key, this.boot});

  /// Injectable for tests.
  final Future<AppServices> Function(AssetBundle bundle)? boot;

  @override
  State<MazeAdventureApp> createState() => _MazeAdventureAppState();
}

class _MazeAdventureAppState extends State<MazeAdventureApp>
    with WidgetsBindingObserver {
  AppServices? _services;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  Future<void> _start() async {
    try {
      final boot = widget.boot ?? AppServices.boot;
      final services = await boot(rootBundle);
      services.controller.addListener(() {
        services.audio.apply(services.controller.settings);
        services.ads.applyEntitlement(fullUnlock: services.controller.player.fullUnlock);
      });
      if (mounted) setState(() => _services = services);
    } catch (e, st) {
      debugPrint('boot failed: $e\n$st');
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _services?.audio.onAppLifecycle(foreground: state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    if (services == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(dark: false, highContrast: false),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: shippedLocales,
        home: SplashScreen(error: _error, onRetry: () {
          setState(() => _error = null);
          _start();
        }),
      );
    }
    return AppScope(
      controller: services.controller,
      audio: services.audio,
      config: services.config,
      purchases: services.purchases,
      ads: services.ads,
      child: ListenableBuilder(
        listenable: services.controller,
        builder: (context, _) {
          final s = services.controller.settings;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (c) => c.l10n.appTitle,
            locale: s.language == 'system' ? null : Locale(s.language),
            supportedLocales: shippedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: switch (s.themeMode) {
              AppThemeMode.system => ThemeMode.system,
              AppThemeMode.light => ThemeMode.light,
              AppThemeMode.dark => ThemeMode.dark,
            },
            theme: buildTheme(dark: false, highContrast: s.highContrast),
            darkTheme: buildTheme(dark: true, highContrast: s.highContrast),
            onGenerateRoute: Routes.onGenerateRoute,
            initialRoute: Routes.home,
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: s.largeUi
                      ? TextScaler.linear((mq.textScaler.scale(1) * 1.2).clamp(1.0, 1.6))
                      : mq.textScaler.clamp(maxScaleFactor: 1.3),
                  disableAnimations: !s.animations || mq.disableAnimations,
                ),
                // The banner lives here so every screen keeps it, and so the
                // screen above it never draws underneath an ad.
                child: Column(
                  children: [
                    Expanded(child: child!),
                    RepaintBoundary(child: AdBannerBar(ads: services.ads)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
