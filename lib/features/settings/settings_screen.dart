import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/localization/l10n.dart';
import '../../core/storage/backup_service.dart';
import '../../core/widgets/chunky.dart';
import '../../core/widgets/screen_frame.dart';
import 'game_settings.dart';

const appVersion = '1.0.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final s = app.settings;
    final l10n = context.l10n;
    final p = context.palette;
    void set(GameSettings next) => app.updateSettings(next);

    return ScreenFrame(
      title: l10n.settings,
      child: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _Section(title: l10n.soundAndPlay, children: [
              _Toggle(Icons.volume_up_rounded, l10n.sound, s.sound, (v) => set(s.copyWith(sound: v))),
              _Toggle(Icons.music_note_rounded, l10n.music, s.music, (v) => set(s.copyWith(music: v))),
              _Toggle(Icons.vibration_rounded, l10n.vibration, s.vibration, (v) => set(s.copyWith(vibration: v))),
              if (s.vibration)
                _Toggle(Icons.waves_rounded, l10n.gentleVibration, s.gentleVibration,
                    (v) => set(s.copyWith(gentleVibration: v))),
            ]),
            _Section(title: l10n.controls, children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.9,
                  children: [
                    for (final (mode, icon, label) in [
                      (ControlMode.swipe, Icons.swipe_rounded, l10n.controlSwipe),
                      (ControlMode.drag, Icons.touch_app_rounded, l10n.controlDrag),
                      (ControlMode.tilt, Icons.screen_rotation_rounded, l10n.controlTilt),
                      (ControlMode.joystick, Icons.gamepad_rounded, l10n.controlJoystick),
                    ])
                      CuteCard(
                        selected: s.controlMode == mode,
                        color: s.controlMode == mode ? p.cardAlt : p.card,
                        padding: const EdgeInsets.all(4),
                        radius: 18,
                        onTap: () => set(s.copyWith(controlMode: mode)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: 30, color: s.controlMode == mode ? p.playEdge : p.ink),
                            const SizedBox(height: 2),
                            FittedBox(
                              child: Text(label,
                                  style: TextStyle(fontWeight: FontWeight.w900, color: p.ink)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  switch (s.controlMode) {
                    ControlMode.swipe => l10n.hintSwipe,
                    ControlMode.drag => l10n.hintDrag,
                    ControlMode.tilt => l10n.hintTilt,
                    ControlMode.joystick => l10n.hintJoystick,
                  },
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, color: p.subInk),
                ),
              ),
              _Toggle(Icons.timer_rounded, l10n.showTimer, s.showTimer, (v) => set(s.copyWith(showTimer: v))),
              _Toggle(Icons.directions_walk_rounded, l10n.showMoves, s.showMoves, (v) => set(s.copyWith(showMoves: v))),
              _Toggle(Icons.map_rounded, l10n.miniMap, s.miniMap, (v) => set(s.copyWith(miniMap: v))),
              _Toggle(Icons.animation_rounded, l10n.animations, s.animations, (v) => set(s.copyWith(animations: v))),
            ]),
            _Section(title: l10n.accessibility, children: [
              _Toggle(Icons.contrast_rounded, l10n.highContrast, s.highContrast,
                  (v) => set(s.copyWith(highContrast: v))),
              _Toggle(Icons.text_increase_rounded, l10n.largeUi, s.largeUi, (v) => set(s.copyWith(largeUi: v))),
              _Toggle(Icons.front_hand_rounded, l10n.leftHanded, s.leftHanded,
                  (v) => set(s.copyWith(leftHanded: v))),
            ]),
            _Section(title: l10n.language, children: [
              _Choices<String>(
                value: s.language,
                options: [
                  ('system', l10n.languageSystem),
                  for (final loc in shippedLocales) (loc.languageCode, localeNames[loc.languageCode]!),
                ],
                onChanged: (v) => set(s.copyWith(language: v)),
              ),
              const SizedBox(height: 10),
              Text(l10n.appearance, style: TextStyle(fontWeight: FontWeight.w900, color: p.ink)),
              const SizedBox(height: 6),
              _Choices<AppThemeMode>(
                value: s.themeMode,
                options: [
                  (AppThemeMode.system, l10n.themeSystem),
                  (AppThemeMode.light, l10n.themeLight),
                  (AppThemeMode.dark, l10n.themeDark),
                ],
                onChanged: (v) => set(s.copyWith(themeMode: v)),
              ),
            ]),
            _Section(title: l10n.fullUnlock, children: [
              _Action(
                app.player.fullUnlock ? Icons.verified_rounded : Icons.lock_open_rounded,
                app.player.fullUnlock ? l10n.purchaseDone : l10n.fullUnlock,
                onTap: app.player.fullUnlock
                    ? null
                    : () => Navigator.of(context).pushNamed(Routes.fullUnlock),
              ),
            ]),
            _Section(title: l10n.backup, children: [
              Text(l10n.backupNote, style: TextStyle(fontWeight: FontWeight.w700, color: p.subInk)),
              const SizedBox(height: 6),
              _Action(Icons.upload_file_rounded, l10n.exportData, onTap: () => _export(context)),
              _Action(Icons.download_rounded, l10n.importData, onTap: () => _import(context)),
            ]),
            _Section(title: l10n.resetProgress, children: [
              _Action(Icons.delete_forever_rounded, l10n.resetProgress,
                  color: const Color(0xFFE63946), onTap: () => _reset(context)),
            ]),
            _Section(title: '${l10n.privacy} · ${l10n.about}', children: [
              _Action(Icons.shield_rounded, l10n.privacy,
                  onTap: () => _info(context, l10n.privacy, l10n.privacyBody)),
              _Action(Icons.info_rounded, l10n.about,
                  onTap: () => _info(context, l10n.about, l10n.aboutBody(appVersion))),
            ]),
          ],
        ),
      ),
    );
  }

  static void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _export(BuildContext context) async {
    final app = context.appRead;
    final l10n = context.l10n;
    try {
      final json = await app.exportBackup();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${BackupService.fileName}');
      await file.writeAsString(json);
      // iPad shows the share sheet as a popover and needs an anchor.
      final box = context.mounted ? context.findRenderObject() as RenderBox? : null;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: BackupService.fileName,
        sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ));
    } catch (e) {
      debugPrint('export: $e');
      if (context.mounted) _toast(context, l10n.exportFailed);
    }
  }

  Future<void> _import(BuildContext context) async {
    final app = context.appRead;
    final l10n = context.l10n;
    FilePickerResult? picked;
    try {
      picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
    } catch (e) {
      debugPrint('pick: $e');
    }
    final bytes = picked?.files.single.bytes;
    if (bytes == null || !context.mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.importConfirmTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(l10n.importConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.replace)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await app.importBackup(utf8.decode(bytes));
      if (context.mounted) _toast(context, l10n.importDone);
    } catch (e) {
      debugPrint('import: $e');
      if (context.mounted) _toast(context, l10n.importFailed);
    }
  }

  Future<void> _reset(BuildContext context) async {
    final app = context.appRead;
    final l10n = context.l10n;
    final p = context.palette;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.resetTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.resetBody, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final item in [
              l10n.resetItemMazes,
              l10n.resetItemAchievements,
              l10n.resetItemUnlocks,
              l10n.resetItemStats,
              l10n.resetItemSettings,
            ])
              Text('•  $item', style: TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE63946)),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await app.resetProgress();
    if (context.mounted) _toast(context, l10n.resetDone);
  }

  void _info(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(context.l10n.ok)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CuteCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: p.ink)),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle(this.icon, this.label, this.value, this.onChanged);

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return MergeSemantics(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: p.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: p.ink)),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: p.play,
                trackOutlineColor: WidgetStatePropertyAll(p.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(this.icon, this.label, {this.onTap, this.color});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = color ?? p.ink;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: c),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c)),
            ),
            if (onTap != null) Icon(Icons.chevron_right_rounded, color: p.subInk),
          ],
        ),
      ),
    );
  }
}

class _Choices<T> extends StatelessWidget {
  const _Choices({required this.value, required this.options, required this.onChanged});

  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (v, label) in options)
          ChoiceChip(
            label: Text(label, style: TextStyle(fontWeight: FontWeight.w900, color: p.ink)),
            selected: v == value,
            onSelected: (_) => onChanged(v),
            selectedColor: p.yellow,
            backgroundColor: p.card,
            side: BorderSide(color: p.outline, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
      ],
    );
  }
}
