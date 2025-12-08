enum GameMode {
  singlePlayer,
  twoPlayer,
  fourPlayer;

  String get turkishName {
    switch (this) {
      case GameMode.singlePlayer:
        return 'Tek Oyuncu (vs Bot)';
      case GameMode.twoPlayer:
        return '2 Oyuncu';
      case GameMode.fourPlayer:
        return '4 Oyuncu';
    }
  }
}

enum AIDifficulty {
  easy,
  normal,
  hard,
  pro,
  godMode;

  String get turkishName {
    switch (this) {
      case AIDifficulty.easy:
        return 'Kolay';
      case AIDifficulty.normal:
        return 'Orta';
      case AIDifficulty.hard:
        return 'Zor';
      case AIDifficulty.pro:
        return 'Usta';
      case AIDifficulty.godMode:
        return 'Tanrı Modu';
    }
  }

  String get description {
    switch (this) {
      case AIDifficulty.easy:
        return 'Rastgele hamleler';
      case AIDifficulty.normal:
        return 'Güvenli hamleleri önceliklendirir';
      case AIDifficulty.hard:
        return 'Stratejik düşünür';
      case AIDifficulty.pro:
        return 'Rakip hamlelerini tahmin eder';
      case AIDifficulty.godMode:
        return 'Satranç motoru gibi oynar';
    }
  }
}
