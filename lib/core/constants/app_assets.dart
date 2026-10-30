class AppAssets {
  AppAssets._();

  static const logo = 'assets/images/app_logo.png';

  // home
  static const _home = 'assets/images/home';
  static const goalCard = '$_home/goal_card.svg';
  static const horoscopeCardBg = '$_home/horoscope_card_bg.png';
  static const geminiCoin = '$_home/gemini_coin.png';
  static const numerologyCard = '$_home/numerology_card.svg';
  static const journalCover = '$_home/journal_cover.svg';

  static const glyphGemini = '$_home/glyph_gemini.svg';
  static const glyphLeo = '$_home/glyph_leo.svg';
  static const glyphLibra = '$_home/glyph_libra.svg';
  static const glyphSagittarius = '$_home/glyph_sagittarius.svg';
  static const glyphTaurus = '$_home/glyph_taurus.svg';
  static const glyphVirgo = '$_home/glyph_virgo.svg';

  // insights
  static const _insights = 'assets/images/insights';
  static const zodiacRing = '$_insights/zodiac_ring.svg';
  static const zodiacWheel = '$_insights/zodiac_wheel.png';
  static const lion = '$_insights/lion.png';
  static const zodiacCancer = '$_insights/zodiac_cancer.svg';
  static const zodiacLeo = '$_insights/zodiac_leo.svg';
  static const constellationCorner = '$_insights/constellation_corner.png';
  static const compass = '$_insights/compass.png';
  static const luckyClover = '$_insights/lucky_clover.png';
  static const destinyScene = '$_insights/destiny_scene.png';
  static const softCloud = '$_insights/soft_cloud.png';
  static const cloudOutline = '$_insights/cloud_outline.png';

  // icons, single colour, tinted with a ColorFilter
  static const _icons = 'assets/images/icons';
  static const navHome = '$_icons/nav_home.svg';
  static const navGoals = '$_icons/nav_goals.svg';
  static const navJournal = '$_icons/nav_journal.svg';
  static const navInsights = '$_icons/nav_insights.svg';
  static const icProfile = '$_icons/profile.svg';
  static const icBell = '$_icons/bell.svg';
  static const icChevronRight = '$_icons/chevron_right.svg';

  /// Big files that are slow to parse or decode the first time, loaded
  /// while the splash is showing.
  static const heavySvgs = [
    goalCard,
    journalCover,
    numerologyCard,
    zodiacRing,
  ];
  static const images = [
    logo,
    horoscopeCardBg,
    geminiCoin,
    lion,
    zodiacWheel,
    constellationCorner,
    compass,
    luckyClover,
    destinyScene,
    softCloud,
    cloudOutline,
  ];
}
