// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Maze Adventure';

  @override
  String get play => 'PLAY';

  @override
  String get continueGame => 'Continue';

  @override
  String get worlds => 'Worlds';

  @override
  String get characters => 'Characters';

  @override
  String get achievements => 'Achievements';

  @override
  String get settings => 'Settings';

  @override
  String get myJourney => 'My Journey';

  @override
  String get dailyMaze => 'Daily Maze';

  @override
  String get dailyDone => 'Done today!';

  @override
  String get dailyNew => 'A new maze every day';

  @override
  String get chooseCharacter => 'Pick your buddy';

  @override
  String get chooseWorld => 'Choose a world';

  @override
  String get chooseSize => 'How big?';

  @override
  String get next => 'Next';

  @override
  String get go => 'GO!';

  @override
  String get locked => 'Locked';

  @override
  String unlockCompletions(int count) {
    return 'Finish $count mazes';
  }

  @override
  String unlockStars(int count) {
    return 'Collect $count stars';
  }

  @override
  String unlockSize(String size) {
    return 'Beat a $size maze';
  }

  @override
  String get selected => 'Selected';

  @override
  String get sizeTiny => 'Tiny';

  @override
  String get sizeSmall => 'Small';

  @override
  String get sizeMedium => 'Medium';

  @override
  String get sizeLarge => 'Large';

  @override
  String get sizeHuge => 'Huge';

  @override
  String get sizeExtreme => 'Extreme';

  @override
  String get worldForest => 'Forest';

  @override
  String get worldCandy => 'Candy';

  @override
  String get worldOcean => 'Ocean';

  @override
  String get worldRoad => 'Town';

  @override
  String get worldSnow => 'Snow';

  @override
  String get worldCastle => 'Castle';

  @override
  String get worldVolcano => 'Volcano';

  @override
  String get worldSpace => 'Space';

  @override
  String get paused => 'PAUSED';

  @override
  String get resume => 'Resume';

  @override
  String get restart => 'Restart';

  @override
  String get newMaze => 'New Maze';

  @override
  String get home => 'Home';

  @override
  String get youDidIt => 'YOU DID IT!';

  @override
  String get time => 'Time';

  @override
  String get moves => 'Moves';

  @override
  String get maze => 'Maze';

  @override
  String get nextMaze => 'NEXT MAZE';

  @override
  String get change => 'Change';

  @override
  String get ratingExcellent => 'Excellent!';

  @override
  String get ratingGood => 'Great job!';

  @override
  String get ratingCompleted => 'You made it!';

  @override
  String get newBest => 'New best time!';

  @override
  String get newUnlocks => 'Just unlocked!';

  @override
  String get achievementUnlocked => 'Achievement!';

  @override
  String get achFirstMaze => 'First Maze';

  @override
  String get achFirstMazeDesc => 'Finish your first maze';

  @override
  String get achExplorer => 'Explorer';

  @override
  String get achExplorerDesc => 'Finish 10 mazes';

  @override
  String get achMazeMaster => 'Maze Master';

  @override
  String get achMazeMasterDesc => 'Finish 100 mazes';

  @override
  String get achSpeedRunner => 'Speed Runner';

  @override
  String get achSpeedRunnerDesc =>
      'Finish a Medium or bigger maze in under 30 seconds';

  @override
  String get achGiant => 'Giant';

  @override
  String get achGiantDesc => 'Finish a 32 × 32 maze';

  @override
  String get achCollector => 'Collector';

  @override
  String get achCollectorDesc => 'Unlock every character';

  @override
  String get achWorldTraveler => 'World Traveler';

  @override
  String get achWorldTravelerDesc => 'Finish a maze in every world';

  @override
  String get achPerfect => 'Perfect';

  @override
  String get achPerfectDesc => 'Finish a maze without bumping a wall';

  @override
  String get achDailyHero => 'Daily Hero';

  @override
  String get achDailyHeroDesc => 'Finish a Daily Maze';

  @override
  String get achStarCollector => 'Star Collector';

  @override
  String get achStarCollectorDesc => 'Collect 100 stars';

  @override
  String get achStreak3 => 'On a Roll';

  @override
  String get achStreak3Desc => 'Play 3 days in a row';

  @override
  String achievementsProgress(int count, int total) {
    return '$count of $total unlocked';
  }

  @override
  String get statMazesCompleted => 'Mazes completed';

  @override
  String get statBestTime => 'Best time';

  @override
  String get statPlayTime => 'Total play time';

  @override
  String get statLargest => 'Largest maze';

  @override
  String get statCharacters => 'Characters unlocked';

  @override
  String get statWorlds => 'Worlds unlocked';

  @override
  String get statPerfect => 'Perfect mazes';

  @override
  String get statStars => 'Stars collected';

  @override
  String get statStreak => 'Current streak';

  @override
  String get statLongestStreak => 'Longest streak';

  @override
  String get statTried => 'Mazes tried';

  @override
  String get bestBySize => 'Best by size';

  @override
  String get noneYet => '—';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String durationHm(int h, int m) {
    return '${h}h ${m}m';
  }

  @override
  String durationM(int m) {
    return '${m}m';
  }

  @override
  String get soundAndPlay => 'Sound & play';

  @override
  String get sound => 'Sound';

  @override
  String get music => 'Music';

  @override
  String get vibration => 'Vibration';

  @override
  String get gentleVibration => 'Gentle vibration';

  @override
  String get controls => 'Controls';

  @override
  String get controlSwipe => 'Swipe';

  @override
  String get controlDrag => 'Drag';

  @override
  String get controlTilt => 'Tilt';

  @override
  String get controlJoystick => 'Joystick';

  @override
  String get hintSwipe => 'Swipe to run down a path';

  @override
  String get hintDrag => 'Drag your buddy with a finger';

  @override
  String get hintTilt => 'Tilt the phone to roll';

  @override
  String get hintJoystick => 'Push the stick to walk';

  @override
  String get showTimer => 'Show timer';

  @override
  String get showMoves => 'Show moves';

  @override
  String get animations => 'Animations';

  @override
  String get miniMap => 'Mini map';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get highContrast => 'High contrast';

  @override
  String get largeUi => 'Large buttons & text';

  @override
  String get leftHanded => 'Left-handed controls';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get appearance => 'Menus';

  @override
  String get themeSystem => 'Auto';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get backup => 'Backup';

  @override
  String get backupNote =>
      'Your progress is saved only on this device. To move it to another device, export a backup file and import it there.';

  @override
  String get exportData => 'Export game data';

  @override
  String get importData => 'Import game data';

  @override
  String get importConfirmTitle => 'Replace progress?';

  @override
  String get importConfirmBody =>
      'Everything on this device will be replaced by the backup file.';

  @override
  String get importDone => 'Progress restored!';

  @override
  String get importFailed => 'That file isn\'t a Maze Adventure backup.';

  @override
  String get exportFailed => 'Couldn\'t create the backup file.';

  @override
  String get replace => 'Replace';

  @override
  String get resetProgress => 'Reset progress';

  @override
  String get resetTitle => 'Are you sure?';

  @override
  String get resetBody => 'This will permanently delete:';

  @override
  String get resetItemMazes => 'Completed mazes';

  @override
  String get resetItemAchievements => 'Achievements';

  @override
  String get resetItemUnlocks => 'Unlocks';

  @override
  String get resetItemStats => 'Statistics';

  @override
  String get resetItemSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get resetDone => 'All progress deleted.';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyBody =>
      'Maze Adventure has no accounts and no servers. Your progress, statistics and settings stay on this device and are never sent anywhere, and the game itself plays offline. The app does go online for two things: the ads shown at the bottom of the screen and between mazes, which come from Google AdMob and are set to child-directed, family-friendly ads only; and the optional Full Unlock purchase, which a grown-up makes through the App Store or Google Play. Full Unlock also removes the ads.';

  @override
  String get about => 'About';

  @override
  String aboutBody(String version) {
    return 'Version $version\n\nMade for curious explorers of every age. Every maze is generated on your device, so there\'s always a new one to solve.';
  }

  @override
  String get fullUnlock => 'Full Unlock';

  @override
  String get fullUnlockBody =>
      'Unlock every character, world and maze size right away, and remove the ads. One payment, no subscriptions. Everything can also be unlocked for free just by playing.';

  @override
  String buyFor(String price) {
    return 'Unlock for $price';
  }

  @override
  String get restorePurchases => 'Restore purchase';

  @override
  String get storeUnavailable =>
      'The store isn\'t available right now. Check the internet connection and try again.';

  @override
  String get purchaseDone => 'Everything is unlocked. Thank you!';

  @override
  String get purchaseFailed => 'The purchase didn\'t go through.';

  @override
  String get askGrownUp => 'Ask a grown-up';

  @override
  String parentGate(int a, int b) {
    return 'What is $a × $b?';
  }

  @override
  String get check => 'Check';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get tiltCalibrate => 'Hold the phone comfortably, then tap to start';

  @override
  String get recalibrate => 'Re-center tilt';

  @override
  String get loading => 'Getting ready…';

  @override
  String get stars => 'Stars';
}
