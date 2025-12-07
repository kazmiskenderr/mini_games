# 🚀 TestFlight Deployment Guide

## Adım 1: App Store Connect'te Uygulama Oluştur

1. **App Store Connect'e git**: https://appstoreconnect.apple.com
2. **"My Apps"** → **"+"** → **"New App"**
3. Bilgileri doldur:
   - **Platform**: iOS
   - **Name**: Mini Games (veya istediğin isim)
   - **Primary Language**: Turkish veya English
   - **Bundle ID**: `com.kazimiskender.miniGames` (otomatik gelecek)
   - **SKU**: `mini-games-001` (herhangi bir unique kod)

## Adım 2: Archive Oluştur

Terminal'de şu komutları çalıştır:

```bash
cd /Users/kazimiskender/mini_games

# 1. Release build oluştur
flutter build ios --release

# 2. Xcode'u aç
open ios/Runner.xcworkspace
```

## Adım 3: Xcode'da Archive

1. Xcode açıldığında:
   - Üst menüden cihaz seçicisinde **"Any iOS Device (arm64)"** seç
   - Menü: **Product → Archive**
   - Build tamamlanacak (3-5 dakika)

2. Archive Organizer açılacak:
   - Oluşan archive'i seç
   - **"Distribute App"** butonuna tıkla

## Adım 4: TestFlight'a Yükle

1. Distribution yöntemini seç:
   - **"App Store Connect"** seç → Next
   - **"Upload"** seç → Next
   - **Distribution options** → hepsini otomatik bırak → Next
   - **Re-sign** → Automatically manage signing → Next
   - **Review** → Upload

2. Yükleme başlayacak (5-10 dakika)
   - App Store Connect'e yükleniyor mesajı gelecek

## Adım 5: TestFlight'ı Aktif Et

1. **App Store Connect** → **My Apps** → **Mini Games**
2. **TestFlight** sekmesine git
3. Build işleniyor olacak (30-60 dakika bekle)
4. Build hazır olunca:
   - **External Testing** → **"+"** → **Add Testers**
   - Email adreslerini ekle (100'e kadar)
   - **Send Invitations**

## Adım 6: Test Kullanıcıları İçin

Davet edilen kişiler:
1. Email'lerinden davet linkine tıklarlar
2. **TestFlight** uygulamasını App Store'dan indirirler
3. Davet linkine tekrar tıklayıp uygulamayı yüklerler
4. Her güncelleme otomatik bildirim gelir

## 🔄 Güncelleme Gönderme

Her güncelleme için:

```bash
# 1. Version numarasını artır (pubspec.yaml)
version: 1.0.1+2  # 1.0.0+1'den 1.0.1+2'ye

# 2. Build ve upload
flutter build ios --release
open ios/Runner.xcworkspace
# Product → Archive → Distribute App → Upload

# 3. App Store Connect'te yeni build'i test kullanıcılarına gönder
```

## ⚡ Hızlı Komutlar

```bash
# Release build
flutter build ios --release --no-codesign

# Archive oluştur
cd ios && xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -sdk iphoneos \
  -configuration Release archive \
  -archivePath $HOME/Desktop/Runner.xcarchive

# Xcode aç
open ios/Runner.xcworkspace
```

## 📝 Notlar

- **İlk yükleme**: Apple incelemesi 24-48 saat sürebilir (External Testing için)
- **Sonraki güncellemeler**: Genelde inceleme gerektirmez, 1-2 saat içinde yayında
- **Internal Testing**: Anında yayınlanır, inceleme yok (ekip üyelerine)
- **Build süresi**: Her build yaklaşık 1 saat işlenir App Store Connect'te

## 🎯 Şu An Yapman Gerekenler

1. ✅ App Store Connect'e git ve uygulama oluştur
2. ✅ `flutter build ios --release` çalıştır
3. ✅ Xcode'da Archive yap
4. ✅ TestFlight'a upload et
5. ⏳ Build'in işlenmesini bekle (30-60 dk)
6. ✅ Test kullanıcılarını davet et

Başarılar! 🚀
