enum ControlMode { swipe, drag, tilt, joystick }

enum AppThemeMode { system, light, dark }

/// All user preferences. Stored as key/value rows in the `settings` table so
/// new options can be added without a schema migration.
class GameSettings {
  const GameSettings({
    this.sound = true,
    this.music = true,
    this.vibration = true,
    this.gentleVibration = false,
    this.controlMode = ControlMode.swipe,
    this.showTimer = true,
    this.showMoves = true,
    this.animations = true,
    this.miniMap = true,
    this.highContrast = false,
    this.largeUi = false,
    this.leftHanded = false,
    this.language = 'system',
    this.themeMode = AppThemeMode.system,
  });

  final bool sound;
  final bool music;
  final bool vibration;
  final bool gentleVibration;
  final ControlMode controlMode;
  final bool showTimer;
  final bool showMoves;

  /// Off = reduced motion: no bounces, confetti or camera easing.
  final bool animations;
  final bool miniMap;
  final bool highContrast;
  final bool largeUi;
  final bool leftHanded;

  /// 'system', or a language code such as 'en' / 'hi'.
  final String language;
  final AppThemeMode themeMode;

  GameSettings copyWith({
    bool? sound,
    bool? music,
    bool? vibration,
    bool? gentleVibration,
    ControlMode? controlMode,
    bool? showTimer,
    bool? showMoves,
    bool? animations,
    bool? miniMap,
    bool? highContrast,
    bool? largeUi,
    bool? leftHanded,
    String? language,
    AppThemeMode? themeMode,
  }) =>
      GameSettings(
        sound: sound ?? this.sound,
        music: music ?? this.music,
        vibration: vibration ?? this.vibration,
        gentleVibration: gentleVibration ?? this.gentleVibration,
        controlMode: controlMode ?? this.controlMode,
        showTimer: showTimer ?? this.showTimer,
        showMoves: showMoves ?? this.showMoves,
        animations: animations ?? this.animations,
        miniMap: miniMap ?? this.miniMap,
        highContrast: highContrast ?? this.highContrast,
        largeUi: largeUi ?? this.largeUi,
        leftHanded: leftHanded ?? this.leftHanded,
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
      );

  Map<String, String> toMap() => {
        'sound': '$sound',
        'music': '$music',
        'vibration': '$vibration',
        'gentle_vibration': '$gentleVibration',
        'control_mode': controlMode.name,
        'show_timer': '$showTimer',
        'show_moves': '$showMoves',
        'animations': '$animations',
        'mini_map': '$miniMap',
        'high_contrast': '$highContrast',
        'large_ui': '$largeUi',
        'left_handed': '$leftHanded',
        'language': language,
        'dark_mode': themeMode.name,
      };

  factory GameSettings.fromMap(Map<String, String> m) {
    const d = GameSettings();
    bool b(String k, bool fallback) =>
        m[k] == null ? fallback : m[k] == 'true';
    T e<T extends Enum>(List<T> values, String k, T fallback) =>
        values.firstWhere((v) => v.name == m[k], orElse: () => fallback);
    return GameSettings(
      sound: b('sound', d.sound),
      music: b('music', d.music),
      vibration: b('vibration', d.vibration),
      gentleVibration: b('gentle_vibration', d.gentleVibration),
      controlMode: e(ControlMode.values, 'control_mode', d.controlMode),
      showTimer: b('show_timer', d.showTimer),
      showMoves: b('show_moves', d.showMoves),
      animations: b('animations', d.animations),
      miniMap: b('mini_map', d.miniMap),
      highContrast: b('high_contrast', d.highContrast),
      largeUi: b('large_ui', d.largeUi),
      leftHanded: b('left_handed', d.leftHanded),
      language: m['language'] ?? d.language,
      themeMode: e(AppThemeMode.values, 'dark_mode', d.themeMode),
    );
  }
}
