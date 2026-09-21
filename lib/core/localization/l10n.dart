import 'package:flutter/widgets.dart';

import '../constants/catalog.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// Languages that ship today. The architecture takes any ARB file dropped
/// into `arb/` (Spanish, French, German, Portuguese, Arabic, Japanese,
/// Korean are planned); add its code here to expose it in Settings.
const shippedLocales = [Locale('en'), Locale('hi')];

/// Native names, shown in the language picker regardless of current language.
const localeNames = {'en': 'English', 'hi': 'हिन्दी'};

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension CatalogText on AppLocalizations {
  String sizeName(String id) => switch (id) {
        'tiny' => sizeTiny,
        'small' => sizeSmall,
        'medium' => sizeMedium,
        'large' => sizeLarge,
        'huge' => sizeHuge,
        _ => sizeExtreme,
      };

  String worldName(String id) => switch (id) {
        'forest' => worldForest,
        'candy' => worldCandy,
        'ocean' => worldOcean,
        'road' => worldRoad,
        'snow' => worldSnow,
        'castle' => worldCastle,
        'volcano' => worldVolcano,
        _ => worldSpace,
      };

  String achievementTitle(Achievement a) => switch (a) {
        Achievement.firstMaze => achFirstMaze,
        Achievement.explorer => achExplorer,
        Achievement.mazeMaster => achMazeMaster,
        Achievement.speedRunner => achSpeedRunner,
        Achievement.giant => achGiant,
        Achievement.collector => achCollector,
        Achievement.worldTraveler => achWorldTraveler,
        Achievement.perfect => achPerfect,
        Achievement.dailyHero => achDailyHero,
        Achievement.starCollector => achStarCollector,
        Achievement.streak3 => achStreak3,
      };

  String achievementDesc(Achievement a) => switch (a) {
        Achievement.firstMaze => achFirstMazeDesc,
        Achievement.explorer => achExplorerDesc,
        Achievement.mazeMaster => achMazeMasterDesc,
        Achievement.speedRunner => achSpeedRunnerDesc,
        Achievement.giant => achGiantDesc,
        Achievement.collector => achCollectorDesc,
        Achievement.worldTraveler => achWorldTravelerDesc,
        Achievement.perfect => achPerfectDesc,
        Achievement.dailyHero => achDailyHeroDesc,
        Achievement.starCollector => achStarCollectorDesc,
        Achievement.streak3 => achStreak3Desc,
      };

  String unlockText(UnlockRule rule) {
    if (rule.completions > 0) return unlockCompletions(rule.completions);
    if (rule.stars > 0) return unlockStars(rule.stars);
    return unlockSize(sizeName(rule.completedSizeId ?? 'huge'));
  }

  String clock(int ms) {
    final total = ms ~/ 1000;
    final m = total ~/ 60;
    final s = total % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String playTime(int ms) {
    final minutes = ms ~/ 60000;
    if (minutes >= 60) return durationHm(minutes ~/ 60, minutes % 60);
    return durationM(minutes);
  }
}
