# ARCHITECTURE.md

## Genel bakış

iPad1FTPDownloader, iPad 1 uygulama ailesinin **FTP uzmanıdır**. iOS 5.1.1 çalıştıran, 256 MB RAM'li birinci nesil iPad'ler için tasarlanmıştır.

Uzak FTP işlemlerine ve verimli, akış tabanlı FTP transferine odaklı kalmalıdır. Genel HTTP/HTTPS indirme iPad1Downloader'a, genel yerel dosya sistemi yönetimi iPad1Files'a, medya oynatma iPad1Player'a, PDF görüntüleme iPad1PDFReader'a aittir.

## Zorunlu kardeş uygulama sahiplik kapısı

**Herhangi** bir yeni özelliği önermeden, tasarlamadan veya yazmadan önce sorumluluğun hangi uygulamaya ait olduğunu belirle.

```text
New feature request
      ↓
Which specialist app owns this responsibility?
      ↓
FTP transfer / remote FTP operation → iPad1FTPDownloader
HTTP/HTTPS download                 → iPad1Downloader
Local filesystem / picker           → iPad1Files
Video playback / codecs / subtitles → iPad1Player
PDF rendering / reading             → iPad1PDFReader
Terminal / shell                     → iPad1Terminal
VNC / remote desktop                 → iPad1VNC
      ↓
If another app owns it: integrate/hand off; do not duplicate it here.
```

Dosya türü transfer sahipliğini belirlemez; indiriciyi taşıma protokolü belirler:

- FTP üzerinden video -> transferi iPad1FTPDownloader yapar, tamamlanan dosyayı iPad1Player'a devreder;
- HTTP/HTTPS üzerinden video -> transferi iPad1Downloader yapar, tamamlanan dosyayı iPad1Player'a devreder.

Bir rakip FTP, HTTP indirme, dosya yönetimi ve oynatmayı tek uygulamada topluyor diye buraya özellik ekleme.

## Platform kısıtları

- iPad 1
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- iOS 5'te bulunan UIKit API'leri
- CFNetwork / CFFTP
- akış tabanlı FTP transferleri

## Uygulama ailesi akışı

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

HTTP/HTTPS kaynakları iPad1Downloader üzerinden ayrı bir yol izler ve bu uygulamada yapılmaz.

## Ortak depolama sınırı

Standart yerel indirme kökü:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Dizin yoksa oluşturulmalıdır.

Eski `/var/mobile/Media/iPad1FTPDownloads/` yolu yeni indirmeler için kullanımdan kalkmıştır.

### Tek fiziksel dosya kuralı

Tamamlanan transfer bir kez, doğrudan standart konumuna kaydedilir. Aynı dosyayı yalnızca entegrasyon için başka bir uygulamanın klasörüne kopyalama.

## Temel katmanlar

### Arayüz katmanı

Sorumlulukları:

- FTP bağlantı alanları;
- güncel uzak FTP yolu;
- uzak dizin tablosu;
- uzak arama / sıralama kontrolleri;
- FTP transfer ilerlemesi / hızı;
- FTP transfer kuyruğu durumu;
- tamamlanan transferlerin hafif sonuç listesi;
- kardeş uygulamaya devir eylemleri;
- FTP hata / durum bildirimleri.

Arayüz bir tarayıcı indiricisine, genel dosya yöneticisine, medya oynatıcıya veya PDF okuyucuya dönüşmemelidir.

### Standart uzak yol yardımcısı

Her uzak FTP dizin yolu:

```text
start with /
end with /
root is exactly /
```

Elle giriş, güncel yol ataması, alt klasöre gitme, üst klasöre çıkma, yenileme ve FTP URL'si oluşturma için tek bir standart yardımcı kullan.

### FTP gezinme katmanı

`FTPBrowser` yalnızca FTP dizin listelemesinden sorumludur:

- normalleştirilmiş yollardan FTP dizin URL'leri oluşturmak;
- kimlik bilgilerini uygulamak;
- dizin listeleme akışlarını okumak;
- sunucu listesini dosya/klasör metadata'sına ayrıştırmak;
- öğeleri delegate üzerinden döndürmek.

Sunucu ağacının tamamını özyinelemeli olarak önbelleğe alma.

### FTP indirme katmanı

`FTPDownloader` FTP transfer mekaniğinden sorumludur:

- CFFTP okuma akışını açmak;
- doğrudan diske akıtmak;
- gerekirse standart yerel dizini oluşturmak;
- ilerleme ve hız bildirmek;
- sunucu/CFNetwork izin verdiği ölçüde FTP ofsetleriyle duraklat/devam desteği;
- bitiş/hata/duraklatma/iptalde akışları güvenle kapatmak.

Kardeş entegrasyonu için indirme sonrası kopyalamaya izin yoktur.

### Yükleme katmanı

`FTPUploader` yalnızca FTP yüklemeden sorumludur:

- yerel dosyaları parça parça okumak;
- FTP çıkış akışına yazmak;
- gönderilen bayt ve hızı bildirmek;
- dosyanın tamamını tamponlamaktan kaçınmak.

Yerel kaynak yolu iPad1Files tarafından verilebilir.

### Uzak komut katmanı

`FTPCommandClient` uzak FTP işlemlerinden sorumludur:

- `DELE`;
- `RMD`;
- `MKD`;
- `RNFR` / `RNTO`.

### Transfer yöneticisi

`TransferQueue` ve ilgili FTP transfer durumu kodu şunlardan sorumludur:

- yalnız metadata tutan FIFO kuyruk;
- güncel FTP transfer durumu;
- duraklat / devam / iptal / yeniden dene;
- başarısız transferden kurtarma;
- yapılırsa sınırlı geçmiş.

Kuyruk asla dosya içeriği tutmamalıdır. iPad 1'de aynı anda tek aktif transfer veya benzer şekilde düşük, sınırlı eşzamanlılık tercih edilir.

## Tamamlanan dosyanın devri

Devir yalnızca transfer başarıyla bittikten ve yerel dosya erişilebilir olduktan sonra yapılır.

### Video

Büyük/küçük harf duyarsız uzantılar:

```text
.mkv .mp4 .mov .m4v .avi
```

Kullanım:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

FTPDownloader video çözmemeli, görüntülememeli, ileri sarmamalı, altyazı incelememeli veya oynatmamalıdır.

### PDF

Kullanım:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

### Diğer dosyalar / dosyalarda göster

Kullanım:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

Tüm devirler aynı fiziksel dosyayı kullanır.

## Açık iPad1Downloader sınırı

Bunları iPad1FTPDownloader'da yazma:

- genel HTTP/HTTPS indirme;
- tarayıcı / web URL'si indirme akışları;
- HTTP yönlendirmeleri;
- HTTP çerezleri / başlıkları;
- HTTP/HTTPS devam ettirme;
- HTTP/HTTPS kuyruk / yeniden deneme / hata yönetimi.

Bunlar iPad1Downloader'a aittir.

## Yerel gezgin kapsamı

Burada yalnızca transfere yönelik sonuçlar ve kardeş uygulamaya devir için izin verilir. Genel yerel kopyala/taşı, klasör yönetimi, favoriler, dosya sistemi genelinde arama, ZIP/arşiv, zengin önizleme, metin düzenleme ve "Birlikte Aç" iPad1Files'a veya başka bir uzman uygulamaya aittir.

## Güvenli protokol araştırma sınırı

### SFTP

SFTP, CFFTPStream tarafından sağlanmaz. Her uygulama, armv7/iOS 5 için derlenmiş gerçek bir SSH/SFTP kütüphanesi ve entegrasyon öncesi fiziksel cihaz profili gerektirir.

### FTPS

FTPS, TLS farkındalığı olan gerçek bir FTP uygulaması gerektirir ve ayrıca değerlendirilmelidir.

## Akış (streaming) sınırı

İleride doğrudan medya akışı otomatik olarak FTPDownloader'a veya Player'a atanmaz. Önce uygulama ailesinin sorumluluk kapısından geçmelidir. Ağ taşıma durumu ile medya çözme/görüntüleme durumu ayrılabilir kalmalıdır.

## Bellek politikası

### Güvenli

- akışla FTP okuma/yazma;
- yaklaşık 8–16 KB'lık küçük transfer tamponları;
- sınırlı kuyruk metadata'sı;
- yol/URL devirleri.

### Dikkatli

- eşzamanlı transferler;
- özyinelemeli uzak arama;
- çok uzun kuyruklar;
- ağır güvenli protokol bağımlılıkları.

### Mimari olarak yasak

- aktarılan dosyaların tamamını RAM'e yüklemek;
- HTTP/HTTPS indirici alt sistemi;
- entegrasyon için yinelenen fiziksel dosyalar;
- medya çözme / oynatma;
- PDF görüntüleme;
- genel zengin önizleme alt sistemi;
- OCR;
- AI/ML;
- büyük arka plan önbellekleri;
- SMB genişletmesi;
- fiziksel cihazda ölçülmeden ağır SFTP kütüphaneleri.

## Derleme / dağıtım topolojisi

```text
Windows + WSL Ubuntu + Theos
        ↓
      .deb
        ↓
      SCP
        ↓
jailbroken iPad 1
        ↓
     dpkg -i
```

## Sahiplik karar kuralı

- FTP transferi / uzak FTP işlemi -> **iPad1FTPDownloader**
- HTTP/HTTPS indirme -> **iPad1Downloader**
- Yerel dosya sistemi / seçici -> **iPad1Files**
- Video oynatma / codec / altyazı -> **iPad1Player**
- PDF okuma / görüntüleme -> **iPad1PDFReader**
- Terminal / kabuk -> **iPad1Terminal**
- VNC / uzak masaüstü -> **iPad1VNC**

Bu karar uygulamadan önce verilmelidir. Yinelenen alt sistemler veya yinelenen dosyalar yerine ortak fiziksel yolları ve hafif URL-scheme devirlerini tercih et.
