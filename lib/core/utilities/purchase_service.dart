import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum StoreStatus { idle, loading, unavailable, ready, purchasing, done, failed }

/// The optional one-time "Full Unlock" (a non-consumable store product).
///
/// This is the only part of the app that ever touches the network, and only
/// after a grown-up opens the Full Unlock page. Without a connection it just
/// reports the store as unavailable; the game itself is unaffected.
class PurchaseService extends ChangeNotifier {
  PurchaseService({
    required this.productId,
    required this.onEntitled,
    this.enabled = true,
  });

  final String productId;
  final Future<void> Function() onEntitled;

  /// False in tests and on platforms without a store.
  final bool enabled;

  StoreStatus status = StoreStatus.idle;
  ProductDetails? product;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// Listen early so a purchase completed while the app was closed (or a
  /// pending one that finishes later) is still delivered.
  void start() {
    if (!enabled || _sub != null) return;
    try {
      _sub = InAppPurchase.instance.purchaseStream.listen(
        _onPurchases,
        onError: (Object e) => _set(StoreStatus.failed),
      );
    } catch (e) {
      debugPrint('iap: $e');
    }
  }

  Future<void> loadProduct() async {
    if (!enabled) return _set(StoreStatus.unavailable);
    _set(StoreStatus.loading);
    try {
      final available = await InAppPurchase.instance
          .isAvailable()
          .timeout(const Duration(seconds: 8));
      if (!available) return _set(StoreStatus.unavailable);
      final response = await InAppPurchase.instance
          .queryProductDetails({productId}).timeout(const Duration(seconds: 10));
      product = response.productDetails.isEmpty
          ? null
          : response.productDetails.first;
      _set(product == null ? StoreStatus.unavailable : StoreStatus.ready);
    } catch (e) {
      debugPrint('iap load: $e');
      _set(StoreStatus.unavailable);
    }
  }

  Future<void> buy() async {
    final p = product;
    if (p == null) return;
    _set(StoreStatus.purchasing);
    try {
      await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: PurchaseParam(productDetails: p));
    } catch (e) {
      debugPrint('iap buy: $e');
      _set(StoreStatus.failed);
    }
  }

  Future<void> restore() async {
    if (!enabled) return _set(StoreStatus.unavailable);
    try {
      _set(StoreStatus.purchasing);
      await InAppPurchase.instance.restorePurchases();
      // Stores send nothing when there is nothing to restore; fall back to
      // the idle product state after a short wait.
      Future.delayed(const Duration(seconds: 6), () {
        if (status == StoreStatus.purchasing) {
          _set(product == null ? StoreStatus.unavailable : StoreStatus.ready);
        }
      });
    } catch (e) {
      debugPrint('iap restore: $e');
      _set(StoreStatus.unavailable);
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != productId) continue;
      switch (p.status) {
        case PurchaseStatus.pending:
          _set(StoreStatus.purchasing);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await onEntitled();
          _set(StoreStatus.done);
        case PurchaseStatus.error:
          _set(StoreStatus.failed);
        case PurchaseStatus.canceled:
          _set(product == null ? StoreStatus.idle : StoreStatus.ready);
      }
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
  }

  void _set(StoreStatus s) {
    status = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
