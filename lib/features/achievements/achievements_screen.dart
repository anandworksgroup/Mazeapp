import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/constants/catalog.dart';
import '../../core/localization/l10n.dart';
import '../../core/widgets/chunky.dart';
import '../../core/widgets/screen_frame.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l10n = context.l10n;
    final p = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final done = app.achievements;

    return ScreenFrame(
      title: l10n.achievements,
      child: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlineText(
                  l10n.achievementsProgress(done.length, Achievement.values.length),
                  size: 20,
                  strokeWidth: 5,
                ),
              ),
            ),
            for (final a in Achievement.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CuteCard(
                  color: done.containsKey(a.name) ? p.card : p.card.withValues(alpha: 0.75),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done.containsKey(a.name) ? p.yellow : p.locked.withValues(alpha: 0.4),
                          border: Border.all(color: p.outline, width: p.outlineWidth),
                        ),
                        child: done.containsKey(a.name)
                            ? Text(a.emoji, style: const TextStyle(fontSize: 28))
                            : Icon(Icons.lock_rounded, color: p.outline.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.achievementTitle(a),
                                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: p.ink)),
                            Text(l10n.achievementDesc(a),
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.subInk)),
                          ],
                        ),
                      ),
                      if (done.containsKey(a.name) && done[a.name]! > 0)
                        Text(
                          DateFormat.MMMd(locale)
                              .format(DateTime.fromMillisecondsSinceEpoch(done[a.name]!)),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: p.subInk),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
