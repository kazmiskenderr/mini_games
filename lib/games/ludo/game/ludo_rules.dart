import 'dart:math';
import '../models/ludo_color.dart';
import '../models/pawn.dart';
import '../models/player.dart';

class LudoRules {
  // Güvenli kareler (yıldız konumları)
  static const List<int> safeSquares = [1, 9, 14, 22, 27, 35, 40, 48];

  // Her rengin başlangıç konumu
  static int getStartPosition(LudoColor color) {
    switch (color) {
      case LudoColor.red:
        return 1;
      case LudoColor.yellow:
        return 14;
      case LudoColor.green:
        return 27;
      case LudoColor.blue:
        return 40;
    }
  }

  // Her rengin ev yolu başlangıcı
  static int getHomePathStart(LudoColor color) {
    switch (color) {
      case LudoColor.red:
        return 51;
      case LudoColor.yellow:
        return 12;
      case LudoColor.green:
        return 25;
      case LudoColor.blue:
        return 38;
    }
  }

  // Piyon hareket edebilir mi?
  static bool canPawnMove(Pawn pawn, int diceValue, List<Player> allPlayers) {
    if (pawn.isFinished) return false;

    // Üste çıkma kontrolü (6 atmalı)
    if (pawn.isInBase) {
      return diceValue == 6;
    }

    // Bitiş kontrolü
    int newPos = calculateNewPosition(pawn, diceValue);
    if (newPos > 57) return false; // Aşırı hareket

    return true;
  }

  // Yeni pozisyon hesapla
  static int calculateNewPosition(Pawn pawn, int diceValue) {
    if (pawn.isInBase) {
      return getStartPosition(pawn.color);
    }

    int currentPos = pawn.position;

    // Ev yolunda mı?
    if (pawn.isInHomePath) {
      return currentPos + diceValue;
    }

    // Normal tahta hareketi
    int newPos = (currentPos + diceValue) % 52;

    // Ev yoluna girme kontrolü
    int homePathEntry = getHomePathStart(pawn.color);
    if (currentPos < homePathEntry && newPos >= homePathEntry) {
      // Ev yoluna gir
      int stepsAfterEntry = diceValue - (homePathEntry - currentPos);
      return 52 + stepsAfterEntry;
    }

    return newPos;
  }

  // Güvenli kare mi?
  static bool isSafeSquare(int position) {
    return safeSquares.contains(position);
  }

  // Rakip piyon yeme kontrolü
  static Pawn? checkKill(Pawn movingPawn, int newPosition, List<Player> allPlayers) {
    // Güvenli karede öldürme yok
    if (isSafeSquare(newPosition)) return null;

    // Ev yolunda öldürme yok
    if (newPosition >= 52) return null;

    // Aynı konumda rakip piyon var mı?
    for (var player in allPlayers) {
      if (player.color == movingPawn.color) continue;

      for (var pawn in player.pawnsOnBoard) {
        if (pawn.position == newPosition) {
          return pawn;
        }
      }
    }

    return null;
  }

  // 6 atarsa tekrar atar mı?
  static bool shouldRollAgain(int diceValue) {
    return diceValue == 6;
  }

  // Hamle yapılabilir mi kontrol (tüm piyonlar için)
  static bool hasValidMove(Player player, int diceValue, List<Player> allPlayers) {
    for (var pawn in player.pawns) {
      if (canPawnMove(pawn, diceValue, allPlayers)) {
        return true;
      }
    }
    return false;
  }

  // Oyun bitti mi?
  static Player? checkWinner(List<Player> players) {
    for (var player in players) {
      if (player.hasWon) return player;
    }
    return null;
  }
}
