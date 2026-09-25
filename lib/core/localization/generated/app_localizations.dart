import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Maze Adventure'**
  String get appTitle;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueGame;

  /// No description provided for @worlds.
  ///
  /// In en, this message translates to:
  /// **'Worlds'**
  String get worlds;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get characters;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myJourney.
  ///
  /// In en, this message translates to:
  /// **'My Journey'**
  String get myJourney;

  /// No description provided for @dailyMaze.
  ///
  /// In en, this message translates to:
  /// **'Daily Maze'**
  String get dailyMaze;

  /// No description provided for @dailyDone.
  ///
  /// In en, this message translates to:
  /// **'Done today!'**
  String get dailyDone;

  /// No description provided for @dailyNew.
  ///
  /// In en, this message translates to:
  /// **'A new maze every day'**
  String get dailyNew;

  /// No description provided for @chooseCharacter.
  ///
  /// In en, this message translates to:
  /// **'Pick your buddy'**
  String get chooseCharacter;

  /// No description provided for @chooseWorld.
  ///
  /// In en, this message translates to:
  /// **'Choose a world'**
  String get chooseWorld;

  /// No description provided for @chooseSize.
  ///
  /// In en, this message translates to:
  /// **'How big?'**
  String get chooseSize;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'GO!'**
  String get go;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @unlockCompletions.
  ///
  /// In en, this message translates to:
  /// **'Finish {count} mazes'**
  String unlockCompletions(int count);

  /// No description provided for @unlockStars.
  ///
  /// In en, this message translates to:
  /// **'Collect {count} stars'**
  String unlockStars(int count);

  /// No description provided for @unlockSize.
  ///
  /// In en, this message translates to:
  /// **'Beat a {size} maze'**
  String unlockSize(String size);

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @sizeTiny.
  ///
  /// In en, this message translates to:
  /// **'Tiny'**
  String get sizeTiny;

  /// No description provided for @sizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get sizeSmall;

  /// No description provided for @sizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get sizeMedium;

  /// No description provided for @sizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get sizeLarge;

  /// No description provided for @sizeHuge.
  ///
  /// In en, this message translates to:
  /// **'Huge'**
  String get sizeHuge;

  /// No description provided for @sizeExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get sizeExtreme;

  /// No description provided for @worldForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get worldForest;

  /// No description provided for @worldCandy.
  ///
  /// In en, this message translates to:
  /// **'Candy'**
  String get worldCandy;

  /// No description provided for @worldOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get worldOcean;

  /// No description provided for @worldRoad.
  ///
  /// In en, this message translates to:
  /// **'Town'**
  String get worldRoad;

  /// No description provided for @worldSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get worldSnow;

  /// No description provided for @worldCastle.
  ///
  /// In en, this message translates to:
  /// **'Castle'**
  String get worldCastle;

  /// No description provided for @worldVolcano.
  ///
  /// In en, this message translates to:
  /// **'Volcano'**
  String get worldVolcano;

  /// No description provided for @worldSpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get worldSpace;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get paused;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @newMaze.
  ///
  /// In en, this message translates to:
  /// **'New Maze'**
  String get newMaze;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @youDidIt.
  ///
  /// In en, this message translates to:
  /// **'YOU DID IT!'**
  String get youDidIt;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @moves.
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get moves;

  /// No description provided for @maze.
  ///
  /// In en, this message translates to:
  /// **'Maze'**
  String get maze;

  /// No description provided for @nextMaze.
  ///
  /// In en, this message translates to:
  /// **'NEXT MAZE'**
  String get nextMaze;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @ratingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get ratingExcellent;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get ratingGood;

  /// No description provided for @ratingCompleted.
  ///
  /// In en, this message translates to:
  /// **'You made it!'**
  String get ratingCompleted;

  /// No description provided for @newBest.
  ///
  /// In en, this message translates to:
  /// **'New best time!'**
  String get newBest;

  /// No description provided for @newUnlocks.
  ///
  /// In en, this message translates to:
  /// **'Just unlocked!'**
  String get newUnlocks;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement!'**
  String get achievementUnlocked;

  /// No description provided for @achFirstMaze.
  ///
  /// In en, this message translates to:
  /// **'First Maze'**
  String get achFirstMaze;

  /// No description provided for @achFirstMazeDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish your first maze'**
  String get achFirstMazeDesc;

  /// No description provided for @achExplorer.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get achExplorer;

  /// No description provided for @achExplorerDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish 10 mazes'**
  String get achExplorerDesc;

  /// No description provided for @achMazeMaster.
  ///
  /// In en, this message translates to:
  /// **'Maze Master'**
  String get achMazeMaster;

  /// No description provided for @achMazeMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish 100 mazes'**
  String get achMazeMasterDesc;

  /// No description provided for @achSpeedRunner.
  ///
  /// In en, this message translates to:
  /// **'Speed Runner'**
  String get achSpeedRunner;

  /// No description provided for @achSpeedRunnerDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish a Medium or bigger maze in under 30 seconds'**
  String get achSpeedRunnerDesc;

  /// No description provided for @achGiant.
  ///
  /// In en, this message translates to:
  /// **'Giant'**
  String get achGiant;

  /// No description provided for @achGiantDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish a 32 × 32 maze'**
  String get achGiantDesc;

  /// No description provided for @achCollector.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get achCollector;

  /// No description provided for @achCollectorDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock every character'**
  String get achCollectorDesc;

  /// No description provided for @achWorldTraveler.
  ///
  /// In en, this message translates to:
  /// **'World Traveler'**
  String get achWorldTraveler;

  /// No description provided for @achWorldTravelerDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish a maze in every world'**
  String get achWorldTravelerDesc;

  /// No description provided for @achPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get achPerfect;

  /// No description provided for @achPerfectDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish a maze without bumping a wall'**
  String get achPerfectDesc;

  /// No description provided for @achDailyHero.
  ///
  /// In en, this message translates to:
  /// **'Daily Hero'**
  String get achDailyHero;

  /// No description provided for @achDailyHeroDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish a Daily Maze'**
  String get achDailyHeroDesc;

  /// No description provided for @achStarCollector.
  ///
  /// In en, this message translates to:
  /// **'Star Collector'**
  String get achStarCollector;

  /// No description provided for @achStarCollectorDesc.
  ///
  /// In en, this message translates to:
  /// **'Collect 100 stars'**
  String get achStarCollectorDesc;

  /// No description provided for @achStreak3.
  ///
  /// In en, this message translates to:
  /// **'On a Roll'**
  String get achStreak3;

  /// No description provided for @achStreak3Desc.
  ///
  /// In en, this message translates to:
  /// **'Play 3 days in a row'**
  String get achStreak3Desc;

  /// No description provided for @achievementsProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} unlocked'**
  String achievementsProgress(int count, int total);

  /// No description provided for @statMazesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mazes completed'**
  String get statMazesCompleted;

  /// No description provided for @statBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best time'**
  String get statBestTime;

  /// No description provided for @statPlayTime.
  ///
  /// In en, this message translates to:
  /// **'Total play time'**
  String get statPlayTime;

  /// No description provided for @statLargest.
  ///
  /// In en, this message translates to:
  /// **'Largest maze'**
  String get statLargest;

  /// No description provided for @statCharacters.
  ///
  /// In en, this message translates to:
  /// **'Characters unlocked'**
  String get statCharacters;

  /// No description provided for @statWorlds.
  ///
  /// In en, this message translates to:
  /// **'Worlds unlocked'**
  String get statWorlds;

  /// No description provided for @statPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect mazes'**
  String get statPerfect;

  /// No description provided for @statStars.
  ///
  /// In en, this message translates to:
  /// **'Stars collected'**
  String get statStars;

  /// No description provided for @statStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get statStreak;

  /// No description provided for @statLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get statLongestStreak;

  /// No description provided for @statTried.
  ///
  /// In en, this message translates to:
  /// **'Mazes tried'**
  String get statTried;

  /// No description provided for @bestBySize.
  ///
  /// In en, this message translates to:
  /// **'Best by size'**
  String get bestBySize;

  /// No description provided for @noneYet.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get noneYet;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String days(int count);

  /// No description provided for @durationHm.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String durationHm(int h, int m);

  /// No description provided for @durationM.
  ///
  /// In en, this message translates to:
  /// **'{m}m'**
  String durationM(int m);

  /// No description provided for @soundAndPlay.
  ///
  /// In en, this message translates to:
  /// **'Sound & play'**
  String get soundAndPlay;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @gentleVibration.
  ///
  /// In en, this message translates to:
  /// **'Gentle vibration'**
  String get gentleVibration;

  /// No description provided for @controls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get controls;

  /// No description provided for @controlSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get controlSwipe;

  /// No description provided for @controlDrag.
  ///
  /// In en, this message translates to:
  /// **'Drag'**
  String get controlDrag;

  /// No description provided for @controlTilt.
  ///
  /// In en, this message translates to:
  /// **'Tilt'**
  String get controlTilt;

  /// No description provided for @controlJoystick.
  ///
  /// In en, this message translates to:
  /// **'Joystick'**
  String get controlJoystick;

  /// No description provided for @hintSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe to run down a path'**
  String get hintSwipe;

  /// No description provided for @hintDrag.
  ///
  /// In en, this message translates to:
  /// **'Drag your buddy with a finger'**
  String get hintDrag;

  /// No description provided for @hintTilt.
  ///
  /// In en, this message translates to:
  /// **'Tilt the phone to roll'**
  String get hintTilt;

  /// No description provided for @hintJoystick.
  ///
  /// In en, this message translates to:
  /// **'Push the stick to walk'**
  String get hintJoystick;

  /// No description provided for @showTimer.
  ///
  /// In en, this message translates to:
  /// **'Show timer'**
  String get showTimer;

  /// No description provided for @showMoves.
  ///
  /// In en, this message translates to:
  /// **'Show moves'**
  String get showMoves;

  /// No description provided for @animations.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get animations;

  /// No description provided for @miniMap.
  ///
  /// In en, this message translates to:
  /// **'Mini map'**
  String get miniMap;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get highContrast;

  /// No description provided for @largeUi.
  ///
  /// In en, this message translates to:
  /// **'Large buttons & text'**
  String get largeUi;

  /// No description provided for @leftHanded.
  ///
  /// In en, this message translates to:
  /// **'Left-handed controls'**
  String get leftHanded;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get languageSystem;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Menus'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @backupNote.
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved only on this device. To move it to another device, export a backup file and import it there.'**
  String get backupNote;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export game data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import game data'**
  String get importData;

  /// No description provided for @importConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace progress?'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Everything on this device will be replaced by the backup file.'**
  String get importConfirmBody;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Progress restored!'**
  String get importDone;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'That file isn\'t a Maze Adventure backup.'**
  String get importFailed;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the backup file.'**
  String get exportFailed;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get resetProgress;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get resetTitle;

  /// No description provided for @resetBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete:'**
  String get resetBody;

  /// No description provided for @resetItemMazes.
  ///
  /// In en, this message translates to:
  /// **'Completed mazes'**
  String get resetItemMazes;

  /// No description provided for @resetItemAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get resetItemAchievements;

  /// No description provided for @resetItemUnlocks.
  ///
  /// In en, this message translates to:
  /// **'Unlocks'**
  String get resetItemUnlocks;

  /// No description provided for @resetItemStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get resetItemStats;

  /// No description provided for @resetItemSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get resetItemSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'All progress deleted.'**
  String get resetDone;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Maze Adventure has no accounts and no servers. Your progress, statistics and settings stay on this device and are never sent anywhere, and the game itself plays offline. The app does go online for two things: the ads shown at the bottom of the screen and between mazes, which come from Google AdMob and are set to child-directed, family-friendly ads only; and the optional Full Unlock purchase, which a grown-up makes through the App Store or Google Play. Full Unlock also removes the ads.'**
  String get privacyBody;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Version {version}\n\nMade for curious explorers of every age. Every maze is generated on your device, so there\'s always a new one to solve.'**
  String aboutBody(String version);

  /// No description provided for @fullUnlock.
  ///
  /// In en, this message translates to:
  /// **'Full Unlock'**
  String get fullUnlock;

  /// No description provided for @fullUnlockBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock every character, world and maze size right away, and remove the ads. One payment, no subscriptions. Everything can also be unlocked for free just by playing.'**
  String get fullUnlockBody;

  /// No description provided for @buyFor.
  ///
  /// In en, this message translates to:
  /// **'Unlock for {price}'**
  String buyFor(String price);

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get restorePurchases;

  /// No description provided for @storeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The store isn\'t available right now. Check the internet connection and try again.'**
  String get storeUnavailable;

  /// No description provided for @purchaseDone.
  ///
  /// In en, this message translates to:
  /// **'Everything is unlocked. Thank you!'**
  String get purchaseDone;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase didn\'t go through.'**
  String get purchaseFailed;

  /// No description provided for @askGrownUp.
  ///
  /// In en, this message translates to:
  /// **'Ask a grown-up'**
  String get askGrownUp;

  /// No description provided for @parentGate.
  ///
  /// In en, this message translates to:
  /// **'What is {a} × {b}?'**
  String parentGate(int a, int b);

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @tiltCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone comfortably, then tap to start'**
  String get tiltCalibrate;

  /// No description provided for @recalibrate.
  ///
  /// In en, this message translates to:
  /// **'Re-center tilt'**
  String get recalibrate;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Getting ready…'**
  String get loading;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
