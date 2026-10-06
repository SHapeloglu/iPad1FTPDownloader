# CLAUDE.md

## Proje kimliği

Bu repo **iPad1FTPDownloader**'dır: **iPad 1 / iOS 5.1.1 / armv7** için FTP uzmanı uygulama.

Amaç, 256 MB RAM'li eski bir cihazda güvenilir FTP transferidir. Genel amaçlı bir HTTP/HTTPS indiriciye, yerel dosya yöneticisine, medya oynatıcıya veya PDF okuyucuya dönüşmemelidir.

## Önce oku

Mimari veya kapsam değişikliğinden önce şu sırayla oku:

1. `INTEGRATION.md`
2. `ARCHITECTURE.md`
3. `TASK.md`
4. `SESSION.md`
5. `TESTING.md`

Uygulamalar arası sahiplikte `INTEGRATION.md` belirleyicidir.

## Değiştirilemez kısıtlar

- iPad 1
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- iOS 5'te bulunan UIKit API'leri
- Manuel bellek yönetimi / MRC
- Theos `.deb` paketleme
- FTP için CFNetwork/CFFTP
- akış tabanlı transfer
- fiziksel cihaz testi belirleyicidir

## Sorumluluk sınırı

### iPad1FTPDownloader'da kalır

- FTP bağlantısı / kimlik doğrulama
- uzak FTP gezinme
- FTP indirme / yükleme
- FTP duraklat / devam / iptal / yeniden dene
- FTP ilerleme / hız / kalan süre
- sınırlı FIFO transfer kuyruğu
- başarısız FTP transferlerinin yönetimi
- kayıtlı FTP sunucuları
- uzak arama / sıralama
- uzak yeniden adlandırma / silme
- MKD/RMD
- transfere yönelik yerel sonuç durumu
- tamamlanan dosyanın yolunu kardeş uygulamaya devretme

### iPad1Downloader'a bırakılır

- HTTP indirmeleri
- HTTPS indirmeleri
- tarayıcı / web URL'si indirme akışları
- yönlendirme / çerez / başlık yönetimi
- HTTP/HTTPS devam ettirme
- HTTP/HTTPS kuyruk / yeniden deneme / hata yönetimi

### iPad1Files'a bırakılır

- yerel dosya sistemi gezinme / seçiciler
- gelişmiş kopyala / taşı
- klasör yönetimi
- favoriler
- dosya sistemi genelinde yerel arama
- ZIP / arşiv
- zengin / genel önizleme
- metin düzenleme
- "Birlikte Aç" kaydı

### iPad1Player'a bırakılır

- video çözme / oynatma
- codec'ler
- ileri sarma / oynatma kontrolleri
- altyazı bulma / gösterme

### iPad1PDFReader'a bırakılır

- PDF görüntüleme
- sayfa gezinme
- yakınlaştırma / yer imleri / vurgulama

### Diğer uzman uygulamalar

- terminal / kabuk -> iPad1Terminal
- VNC / uzak masaüstü -> iPad1VNC

Dosyanın medya olması transfer sahipliğini değiştirmez. FTP'deki medya burada aktarılır; Player'a yalnızca başarıyla tamamlanmış ve erişilebilir yerel yol verilir.

## Uygulama ailesinin standart akışı

```text
FTP Server
   ↓
iPad1FTPDownloader
   ↓
/var/mobile/Media/iPad1Files/Downloads/
   ↓
completed-file hand-off
   ├─ video -> iPad1Player
   ├─ PDF   -> iPad1PDFReader
   └─ other -> iPad1Files
```

HTTP/HTTPS kaynakları bunun yerine iPad1Downloader'ı kullanır.

## Standart indirme kökü

Tüm yeni FTP indirmeleri doğrudan buraya yazılmalı:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Yeni indirmeleri `/var/mobile/Media/iPad1FTPDownloads/` altına yazma ve tamamlanan dosyaları yalnızca kardeş entegrasyonu için kopyalama.

## Uzak yol kuralı

Her uzak FTP dizin yolu:

- `/` ile başlamalı;
- `/` ile bitmeli;
- kök dizin tam olarak `/` olmalı.

Her yerde tek bir standart yardımcı fonksiyon kullan: elle giriş, mevcut durum, alt klasöre gitme, üst klasöre çıkma, yenileme ve listeleme URL'si oluşturma.

## Tamamlanan dosyanın devri

### Video

Tamamlanmış `.mkv`, `.mp4`, `.mov`, `.m4v`, `.avi` dosyaları için:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

FTPDownloader içinde medya çözme/oynatma yapma.

### PDF

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

### Dosyalar

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

Hepsi aynı fiziksel dosyayı kullanır. Kardeş uygulamanın scheme'i yoksa dosyaya dokunma ve hatayı nazikçe göster.

## Güncel yol haritası sırası

### v1.3

- standart ortak Downloads kökü
- tek fiziksel dosya kuralı
- merkezi uzak yol kuralı
- Player/PDFReader/Files'a aynı yolla devir
- FTP regresyon testleri
- indirme hedefi tercihi + iPad1Files klasör seçici entegrasyonu

### v1.4

- FTP duraklat / devam / iptal
- sınırlı kuyruk
- yeniden deneme / hatadan kurtarma
- ilerleme / hız / kalan süre
- dosya adı çakışması yönetimi
- yalnız metadata tutan geçmiş
- iPad 1'de bilinçli olarak düşük eşzamanlılık

### v1.5

- Kayıtlı Sunucular düzenleyicisi
- uzak arama / sıralama
- önce klasörler
- uzak metadata
- uzak işlemlerin iyileştirilmesi

### v1.6

Kardeş uygulama entegrasyonunun iyileştirilmesi.

### v1.7

Keychain tabanlı kayıtlı kimlik bilgileri ve ilgili güvenlik sıkılaştırmaları.

### HTTP/HTTPS

Bu reponun açıkça dışında; iPad1Downloader'a aittir.

### SFTP/FTPS

Fiziksel cihaz profili kabul edilebilir olduğunu gösterene kadar yalnızca deneysel araştırma.

## Bellek politikası

### Güvenli

- akışla FTP okuma/yazma
- 8–16 KB civarı küçük tamponlar
- sınırlı kuyruk / geçmiş metadata'sı
- URL/yol devirleri

### Dikkatli

- özyinelemeli uzak arama
- eşzamanlı transferler
- çok uzun kuyruklar
- ağır güvenli protokol kütüphaneleri

### Ekleme

- dosyanın tamamını RAM'de tutma
- HTTP/HTTPS indirici alt sistemi
- medya oynatma / codec / altyazı motoru
- zengin yerel önizleme çatısı
- PDF görüntüleme
- OCR
- AI/ML
- büyük arka plan önbellekleri
- SMB genişletmesi
- profil çıkarılmadan ağır SFTP bağımlılıkları

## SFTP / FTPS kuralı

Bir taslak sınıf veya arayüz öğesi var diye asla SFTP ya da FTPS desteği olduğunu söyleme. Gerçek bir armv7/iOS 5 uygulaması ve fiziksel profil çıkarma şarttır.

## Kod stili

Küçük Objective-C sınıflarını, açık delegate'leri, iOS 5 uyumlu API'leri, açık MRC sahipliğini, savunmacı hata yönetimini, akış tabanlı dosya/ağ G/Ç'sini ve tek bir ortak yol normalleştirme yardımcısını tercih et.

Tekrarlanan yol mantığından, gizli tam dosya okumalarından, ana thread'de bloklayan ağ işlemlerinden, yutulan FTP hatalarından ve HTTP indirici, yerel dosya yöneticisi ya da medya oynatma yönünde kapsam kaymasından kaçın.

## Derleme

```bash
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

## Sürüm kontrol listesi

1. `INTEGRATION.md`'yi oku.
2. Temiz ağaçtan derle.
3. Fiziksel iPad 1'e kur.
4. Standart ortak indirme kökünü ve yinelenen kopya olmadığını doğrula.
5. Uzak yol kuralını doğrula.
6. FTP indirme/yükleme ve uzak komutları doğrula.
7. Transfer ilerlemesini/hızını ve değişen transfer yöneticisi davranışını doğrula.
8. Player/PDFReader/Files devirlerinin aynı tamamlanmış fiziksel dosyayı kullandığını doğrula.
9. Yerel arayüzün FTP transferine odaklı kaldığını doğrula.
10. HTTP/HTTPS indirici veya medya oynatma mantığı eklenmediğini doğrula.
11. `CHANGELOG.md`, `SESSION.md`, `TASK.md` ve `TESTING.md`'yi gerçek fiziksel sonuçlarla güncelle.
