import 'package:flutter/widgets.dart';

import '../core/ads/ad_service.dart';
import '../core/audio/audio_service.dart';
import '../core/constants/game_config.dart';
import '../core/utilities/purchase_service.dart';
import 'app_controller.dart';

/// Hands the app-wide services to every screen and rebuilds dependants when
/// the controller changes.
class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required this.audio,
    required this.config,
    required this.purchases,
    required this.ads,
    required super.child,
  }) : super(notifier: controller);

  final AudioService audio;
  final GameConfig config;
  final PurchaseService purchases;
  final AdService ads;

  AppController get controller => notifier!;

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  /// Services only, without subscribing to rebuilds.
  static AppScope read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!;
}

extension AppScopeContext on BuildContext {
  AppController get app => AppScope.of(this).controller;
  AppController get appRead => AppScope.read(this).controller;
  AudioService get audio => AppScope.read(this).audio;
  AdService get ads => AppScope.read(this).ads;
  GameConfig get config => AppScope.read(this).config;
}
