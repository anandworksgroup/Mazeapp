// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'मेज़ एडवेंचर';

  @override
  String get play => 'खेलें';

  @override
  String get continueGame => 'जारी रखें';

  @override
  String get worlds => 'दुनिया';

  @override
  String get characters => 'साथी';

  @override
  String get achievements => 'उपलब्धियाँ';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get myJourney => 'मेरी यात्रा';

  @override
  String get dailyMaze => 'आज की भूलभुलैया';

  @override
  String get dailyDone => 'आज पूरी हुई!';

  @override
  String get dailyNew => 'हर दिन एक नई भूलभुलैया';

  @override
  String get chooseCharacter => 'अपना साथी चुनें';

  @override
  String get chooseWorld => 'दुनिया चुनें';

  @override
  String get chooseSize => 'कितनी बड़ी?';

  @override
  String get next => 'आगे';

  @override
  String get go => 'चलो!';

  @override
  String get locked => 'बंद';

  @override
  String unlockCompletions(int count) {
    return '$count भूलभुलैया पूरी करें';
  }

  @override
  String unlockStars(int count) {
    return '$count तारे जमा करें';
  }

  @override
  String unlockSize(String size) {
    return 'एक $size भूलभुलैया जीतें';
  }

  @override
  String get selected => 'चुना गया';

  @override
  String get sizeTiny => 'नन्ही';

  @override
  String get sizeSmall => 'छोटी';

  @override
  String get sizeMedium => 'मध्यम';

  @override
  String get sizeLarge => 'बड़ी';

  @override
  String get sizeHuge => 'विशाल';

  @override
  String get sizeExtreme => 'महा';

  @override
  String get worldForest => 'जंगल';

  @override
  String get worldCandy => 'कैंडी';

  @override
  String get worldOcean => 'समुद्र';

  @override
  String get worldRoad => 'शहर';

  @override
  String get worldSnow => 'बर्फ़';

  @override
  String get worldCastle => 'किला';

  @override
  String get worldVolcano => 'ज्वालामुखी';

  @override
  String get worldSpace => 'अंतरिक्ष';

  @override
  String get paused => 'रुका हुआ';

  @override
  String get resume => 'जारी रखें';

  @override
  String get restart => 'फिर से';

  @override
  String get newMaze => 'नई भूलभुलैया';

  @override
  String get home => 'होम';

  @override
  String get youDidIt => 'शाबाश!';

  @override
  String get time => 'समय';

  @override
  String get moves => 'कदम';

  @override
  String get maze => 'भूलभुलैया';

  @override
  String get nextMaze => 'अगली भूलभुलैया';

  @override
  String get change => 'बदलें';

  @override
  String get ratingExcellent => 'बहुत बढ़िया!';

  @override
  String get ratingGood => 'अच्छा किया!';

  @override
  String get ratingCompleted => 'तुमने कर दिखाया!';

  @override
  String get newBest => 'नया सबसे तेज़ समय!';

  @override
  String get newUnlocks => 'अभी खुला!';

  @override
  String get achievementUnlocked => 'उपलब्धि!';

  @override
  String get achFirstMaze => 'पहली भूलभुलैया';

  @override
  String get achFirstMazeDesc => 'अपनी पहली भूलभुलैया पूरी करें';

  @override
  String get achExplorer => 'खोजी';

  @override
  String get achExplorerDesc => '10 भूलभुलैया पूरी करें';

  @override
  String get achMazeMaster => 'भूलभुलैया उस्ताद';

  @override
  String get achMazeMasterDesc => '100 भूलभुलैया पूरी करें';

  @override
  String get achSpeedRunner => 'तेज़ धावक';

  @override
  String get achSpeedRunnerDesc =>
      'मध्यम या बड़ी भूलभुलैया 30 सेकंड से कम में पूरी करें';

  @override
  String get achGiant => 'दिग्गज';

  @override
  String get achGiantDesc => '32 × 32 भूलभुलैया पूरी करें';

  @override
  String get achCollector => 'संग्रहकर्ता';

  @override
  String get achCollectorDesc => 'सभी साथी खोलें';

  @override
  String get achWorldTraveler => 'विश्व यात्री';

  @override
  String get achWorldTravelerDesc => 'हर दुनिया में एक भूलभुलैया पूरी करें';

  @override
  String get achPerfect => 'एकदम सही';

  @override
  String get achPerfectDesc => 'दीवार से टकराए बिना भूलभुलैया पूरी करें';

  @override
  String get achDailyHero => 'रोज़ का हीरो';

  @override
  String get achDailyHeroDesc => 'आज की भूलभुलैया पूरी करें';

  @override
  String get achStarCollector => 'तारा संग्रहकर्ता';

  @override
  String get achStarCollectorDesc => '100 तारे जमा करें';

  @override
  String get achStreak3 => 'लगातार';

  @override
  String get achStreak3Desc => 'लगातार 3 दिन खेलें';

  @override
  String achievementsProgress(int count, int total) {
    return '$total में से $count खुली';
  }

  @override
  String get statMazesCompleted => 'पूरी की गई भूलभुलैया';

  @override
  String get statBestTime => 'सबसे तेज़ समय';

  @override
  String get statPlayTime => 'कुल खेल समय';

  @override
  String get statLargest => 'सबसे बड़ी भूलभुलैया';

  @override
  String get statCharacters => 'खुले साथी';

  @override
  String get statWorlds => 'खुली दुनिया';

  @override
  String get statPerfect => 'एकदम सही भूलभुलैया';

  @override
  String get statStars => 'जमा तारे';

  @override
  String get statStreak => 'मौजूदा सिलसिला';

  @override
  String get statLongestStreak => 'सबसे लंबा सिलसिला';

  @override
  String get statTried => 'कोशिश की गई भूलभुलैया';

  @override
  String get bestBySize => 'आकार के अनुसार सबसे अच्छा';

  @override
  String get noneYet => '—';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      one: '1 दिन',
    );
    return '$_temp0';
  }

  @override
  String durationHm(int h, int m) {
    return '$h घं $m मि';
  }

  @override
  String durationM(int m) {
    return '$m मि';
  }

  @override
  String get soundAndPlay => 'आवाज़ और खेल';

  @override
  String get sound => 'आवाज़';

  @override
  String get music => 'संगीत';

  @override
  String get vibration => 'कंपन';

  @override
  String get gentleVibration => 'हल्का कंपन';

  @override
  String get controls => 'नियंत्रण';

  @override
  String get controlSwipe => 'स्वाइप';

  @override
  String get controlDrag => 'खींचें';

  @override
  String get controlTilt => 'झुकाएँ';

  @override
  String get controlJoystick => 'जॉयस्टिक';

  @override
  String get hintSwipe => 'रास्ते पर दौड़ने के लिए स्वाइप करें';

  @override
  String get hintDrag => 'उंगली से अपने साथी को खींचें';

  @override
  String get hintTilt => 'फ़ोन को झुकाकर चलाएँ';

  @override
  String get hintJoystick => 'चलने के लिए स्टिक दबाएँ';

  @override
  String get showTimer => 'टाइमर दिखाएँ';

  @override
  String get showMoves => 'कदम दिखाएँ';

  @override
  String get animations => 'एनिमेशन';

  @override
  String get miniMap => 'छोटा नक्शा';

  @override
  String get accessibility => 'सुलभता';

  @override
  String get highContrast => 'उच्च कंट्रास्ट';

  @override
  String get largeUi => 'बड़े बटन और अक्षर';

  @override
  String get leftHanded => 'बाएँ हाथ के नियंत्रण';

  @override
  String get language => 'भाषा';

  @override
  String get languageSystem => 'फ़ोन की भाषा';

  @override
  String get appearance => 'मेनू';

  @override
  String get themeSystem => 'अपने-आप';

  @override
  String get themeLight => 'हल्का';

  @override
  String get themeDark => 'गहरा';

  @override
  String get backup => 'बैकअप';

  @override
  String get backupNote =>
      'आपकी प्रगति सिर्फ़ इसी डिवाइस पर सहेजी जाती है। दूसरे डिवाइस पर ले जाने के लिए बैकअप फ़ाइल निर्यात करें और वहाँ आयात करें।';

  @override
  String get exportData => 'गेम डेटा निर्यात करें';

  @override
  String get importData => 'गेम डेटा आयात करें';

  @override
  String get importConfirmTitle => 'प्रगति बदलें?';

  @override
  String get importConfirmBody =>
      'इस डिवाइस का सारा डेटा बैकअप फ़ाइल से बदल जाएगा।';

  @override
  String get importDone => 'प्रगति वापस आ गई!';

  @override
  String get importFailed => 'यह मेज़ एडवेंचर की बैकअप फ़ाइल नहीं है।';

  @override
  String get exportFailed => 'बैकअप फ़ाइल नहीं बन सकी।';

  @override
  String get replace => 'बदलें';

  @override
  String get resetProgress => 'प्रगति मिटाएँ';

  @override
  String get resetTitle => 'क्या आप पक्का हैं?';

  @override
  String get resetBody => 'यह हमेशा के लिए मिट जाएगा:';

  @override
  String get resetItemMazes => 'पूरी की गई भूलभुलैया';

  @override
  String get resetItemAchievements => 'उपलब्धियाँ';

  @override
  String get resetItemUnlocks => 'खुली चीज़ें';

  @override
  String get resetItemStats => 'आँकड़े';

  @override
  String get resetItemSettings => 'सेटिंग्स';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get reset => 'मिटाएँ';

  @override
  String get resetDone => 'सारी प्रगति मिटा दी गई।';

  @override
  String get privacy => 'गोपनीयता';

  @override
  String get privacyBody =>
      'मेज़ एडवेंचर में न कोई खाता है, न कोई सर्वर। आपकी प्रगति, आँकड़े और सेटिंग्स इसी डिवाइस पर रहते हैं और कहीं नहीं भेजे जाते। गेम को इंटरनेट की ज़रूरत नहीं है। ऐप इंटरनेट का उपयोग सिर्फ़ तब करता है जब कोई बड़ा App Store या Google Play से फ़ुल अनलॉक खरीदता है।';

  @override
  String get about => 'जानकारी';

  @override
  String aboutBody(String version) {
    return 'संस्करण $version\n\nहर उम्र के खोजियों के लिए। हर भूलभुलैया आपके डिवाइस पर बनती है, इसलिए हमेशा एक नई तैयार रहती है।';
  }

  @override
  String get fullUnlock => 'फ़ुल अनलॉक';

  @override
  String get fullUnlockBody =>
      'सभी साथी, दुनिया और आकार अभी खोलें। एक बार भुगतान, कोई विज्ञापन नहीं, कोई सदस्यता नहीं। सब कुछ खेलकर मुफ़्त में भी खुल सकता है।';

  @override
  String buyFor(String price) {
    return '$price में खोलें';
  }

  @override
  String get restorePurchases => 'खरीदारी वापस लाएँ';

  @override
  String get storeUnavailable =>
      'स्टोर अभी उपलब्ध नहीं है। इंटरनेट कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get purchaseDone => 'सब कुछ खुल गया। धन्यवाद!';

  @override
  String get purchaseFailed => 'खरीदारी पूरी नहीं हुई।';

  @override
  String get askGrownUp => 'किसी बड़े से पूछें';

  @override
  String parentGate(int a, int b) {
    return '$a × $b कितना होता है?';
  }

  @override
  String get check => 'जाँचें';

  @override
  String get close => 'बंद करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get tiltCalibrate =>
      'फ़ोन आराम से पकड़ें, फिर शुरू करने के लिए टैप करें';

  @override
  String get recalibrate => 'झुकाव फिर से सेट करें';

  @override
  String get loading => 'तैयारी हो रही है…';

  @override
  String get stars => 'तारे';
}
