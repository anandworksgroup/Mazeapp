import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/constants/catalog.dart';
import '../../core/localization/l10n.dart';
import '../../core/utilities/purchase_service.dart';
import '../../core/widgets/chunky.dart';
import '../../core/widgets/screen_frame.dart';
import '../character/animated_character.dart';
import '../character/character_painter.dart';

/// The optional one-time purchase. A grown-up must pass a simple question
/// first (kids-category store rule), and nothing here is needed to play.
class FullUnlockScreen extends StatefulWidget {
  const FullUnlockScreen({super.key});

  @override
  State<FullUnlockScreen> createState() => _FullUnlockScreenState();
}

class _FullUnlockScreenState extends State<FullUnlockScreen> {
  bool _grownUp = false;
  late final int _a;
  late final int _b;
  final _answer = TextEditingController();
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _a = 6 + rng.nextInt(4);
    _b = 3 + rng.nextInt(6);
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  void _check() {
    if (int.tryParse(_answer.text.trim()) == _a * _b) {
      setState(() => _grownUp = true);
      AppScope.read(context).purchases.loadProduct();
    } else {
      setState(() => _wrong = true);
      _answer.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final app = context.app;
    final purchases = AppScope.of(context).purchases;

    return ScreenFrame(
      title: l10n.fullUnlock,
      child: ContentWidth(
        maxWidth: 520,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final id in ['rex', 'ollie', 'rudy'])
                    AnimatedCharacter(
                      def: Catalog.character(id),
                      pose: CharacterPose.happy,
                      size: 100,
                      animate: app.settings.animations,
                    ),
                ],
              ),
            ),
            CuteCard(
              child: Column(
                children: [
                  Text(l10n.fullUnlockBody,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: p.ink)),
                  const SizedBox(height: 16),
                  if (app.player.fullUnlock)
                    Text('✅ ${l10n.purchaseDone}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: p.playEdge))
                  else if (!_grownUp)
                    _gate(l10n, p)
                  else
                    ListenableBuilder(
                      listenable: purchases,
                      builder: (context, _) => _store(l10n, p, purchases),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gate(AppLocalizations l10n, Palette p) => Column(
        children: [
          Text('👪 ${l10n.askGrownUp}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: p.ink)),
          const SizedBox(height: 8),
          Text(l10n.parentGate(_a, _b),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: p.ink)),
          const SizedBox(height: 8),
          SizedBox(
            width: 140,
            child: TextField(
              controller: _answer,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                errorText: _wrong ? '✗' : null,
              ),
              onSubmitted: (_) => _check(),
            ),
          ),
          const SizedBox(height: 12),
          ChunkyButton(onTap: _check, label: l10n.check, color: p.blue, height: 54),
        ],
      );

  Widget _store(AppLocalizations l10n, Palette p, PurchaseService purchases) {
    final busy = purchases.status == StoreStatus.loading || purchases.status == StoreStatus.purchasing;
    return Column(
      children: [
        if (busy) const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
        if (purchases.status == StoreStatus.unavailable)
          Text(l10n.storeUnavailable,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, color: p.subInk)),
        if (purchases.status == StoreStatus.failed)
          Text(l10n.purchaseFailed,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFE63946))),
        if (purchases.product != null && !busy) ...[
          const SizedBox(height: 8),
          ChunkyButton(
            onTap: purchases.buy,
            label: l10n.buyFor(purchases.product!.price),
            color: p.play,
            expand: true,
            height: 62,
          ),
        ],
        const SizedBox(height: 8),
        TextButton(
          onPressed: busy ? null : purchases.restore,
          child: Text(l10n.restorePurchases,
              style: TextStyle(fontWeight: FontWeight.w900, color: p.ink)),
        ),
        if (purchases.status == StoreStatus.unavailable)
          TextButton(
            onPressed: purchases.loadProduct,
            child: Icon(Icons.refresh_rounded, color: p.ink),
          ),
      ],
    );
  }
}
