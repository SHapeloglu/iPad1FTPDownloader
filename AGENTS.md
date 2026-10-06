# AGENTS.md

## Amaç

Bu dosya, bu repoda çalışan kod asistanları için kısa bir çalışma sözleşmesidir.

## Hedef

- iPad 1
- iOS 5.1.1
- armv7
- Theos
- Objective-C
- UIKit / Foundation / CFNetwork
- Manuel referans sayımı (MRC)

## Kurallar

1. iOS 5 uyumluluğunu koru.
2. Swift ekleme.
3. Sessizce ARC gerektiren kod yazma.
4. iOS 5'ten yeni API'leri uyumluluk koruması olmadan kullanma.
5. Ağ işlemlerini asenkron tut.
6. Büyük bellek içi tamponlardan kaçın.
7. `.deb` paketleme akışını bozma.
8. Kimlik bilgilerini asla commit etme.
9. Fiziksel iPad davranışını doğruluk kaynağı kabul et.
10. Davranış veya mimari değişince dokümanları güncelle.
11. Herhangi bir özelliği önermeden veya yazmadan önce aşağıdaki kardeş uygulama sahiplik kontrolünü yap.

## Zorunlu kardeş uygulama sahiplik kontrolü

- FTP transferi / uzak FTP işlemleri -> **iPad1FTPDownloader**
- HTTP/HTTPS indirme -> **iPad1Downloader**
- yerel dosya sistemi / seçici / dosya yönetimi -> **iPad1Files**
- video oynatma / codec / altyazı -> **iPad1Player**
- PDF görüntüleme / okuma -> **iPad1PDFReader**
- terminal / kabuk -> **iPad1Terminal**
- VNC / uzak masaüstü -> **iPad1VNC**

İndirme sahipliğini taşıma protokolü belirler. FTP ile indirilen bir medya dosyası yine iPad1FTPDownloader transferidir; transfer başarıyla bitince iPad1Player'a yalnızca erişilebilir yerel yol verilir.

Bu repoya HTTP/HTTPS indirici davranışı ekleme. Medya oynatma davranışı ekleme. Ortak fiziksel yolları ve hafif URL-scheme devirlerini tercih et.

## Dizin yolu kuralı

Her uzak FTP dizin yolu:

- `/` ile başlamalı,
- `/` ile bitmeli,
- kök dizin tam olarak `/` olmalı.

Bu kural arayüz durumunda, gezinme durumunda ve FTP URL'si oluşturulurken her zaman geçerli olmalı.

## Transfer ilkeleri

- FTP indirmelerini doğrudan diske akıt.
- FTP yüklemelerini doğrudan diskten akıt.
- Transfer tamponlarını küçük tut.
- iPad 1'de eşzamanlı aktif transfer sayısını bilinçli olarak düşük tut.
- Hataları kullanıcıya göster.
- Devam ettirme (resume) yazarken FTP sunucusu desteğini ve yerel dosya ofseti davranışını doğrula.
- Akış temiz bir şekilde bitmeden transferi tamamlandı sayma.
- Tamamlanan video `ipad1player://open?path=...` ile devredilebilir; burada çözme/oynatma yapma.

## Güvenli protokoller

SFTP ve FTPS, gerçekten çalışan taşıma katmanları bağlanıp iPad 1'de test edilene kadar yapılmış sayılmaz.

## Kaynak değişikliğinden sonra zorunlu doğrulama

```bash
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

Ardından fiziksel iPad'e kur ve `TESTING.md`'deki ilgili senaryoları çalıştır.

## Doküman sorumlulukları

- `README.md`: kullanıcı/proje özeti
- `ARCHITECTURE.md`: yapı ve teknik kararlar
- `TASK.md`: aktif iş listesi
- `SESSION.md`: son devir durumu
- `TESTING.md`: doğrulama planı
- `ROADMAP.md`: gelecek sürümler
- `CHANGELOG.md`: yayımlanan / geliştirilen değişiklikler
- `DEVELOPMENT.md`: derleme/kurulum akışı
- `CLAUDE.md`: ayrıntılı asistan bağlamı
