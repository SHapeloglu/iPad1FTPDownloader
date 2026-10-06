# iPad1Downloader Entegrasyon Sözleşmesi

## Amaç

Eski adıyla `iPad1FTPDownloader`, iPad 1 uygulama ailesinin ağ transfer uzmanı olan **iPad1Downloader**'a dönüştürülüyor.

Birden fazla ağ taşıma protokolüne sahip olabilir, ancak kardeş uygulamaların sorumluluklarını üstlenmemelidir.

## Platform sözleşmesi

- iPad 1
- Apple A4
- ~256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- eski iPhoneOS 6.1 SDK

## Sorumluluk matrisi

```text
FTP transfer / remote FTP operations -> iPad1Downloader / FTP engine
HTTP/HTTPS download                  -> iPad1Downloader / HTTP engine
Windows -> iPad Wi-Fi receive        -> iPad1Downloader / Wi-Fi receive engine
local filesystem / picker / ZIP      -> iPad1Files
PDF rendering/reading                -> iPad1PDFReader
video/audio playback/subtitles       -> iPad1Player
terminal/shell                       -> iPad1Terminal
VNC                                  -> iPad1VNC
```

Protokol sahipliği dosya türüne göre değişmez. FTP ile aktarılan video yine FTP transferidir. Wi-Fi ile alınan PDF yine Wi-Fi alma transferidir. Dosya türü yalnızca transfer tamamlandıktan sonra önem kazanır.

## Taşıma mimarisi

Protokol motorlarını ayrı tut:

```text
iPad1Downloader
├── FTP engine
├── HTTP/HTTPS engine
├── Wi-Fi Receive engine
└── shared lightweight transfer state
    ├── progress
    ├── speed / ETA
    ├── bounded queue metadata
    ├── retry / cancel
    └── completed-file handoff
```

FTP protokol kodunu, HTTP protokol kodunu ve yerel ağdan gelen bağlantıları karşılayan sunucu kodunu tek bir dev sınıfta birleştirme.

## Standart ortak depolama

iPad1Files'a ait:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Aktarılan bir dosya = bir fiziksel dosya.

Downloader yalnızca entegrasyon için özel bir yinelenen kopya oluşturmamalıdır.

## iPad1Files'a devredilenler

Aşağıdakiler `iPad1Downloader` içinde yazılmamalı, `iPad1Files` tarafından yapılmalıdır:

- yerel dosya/klasör gezgini;
- hedef klasör seçme arayüzü;
- kopyala / taşı / yeniden adlandır / sil;
- ZIP / arşiv yönetimi;
- yerel arama;
- favoriler / etiketler / sınıflandırma;
- indirilen dosyaların düzenlenmesi;
- genel dosya yönetimi arayüzü.

### Klasör seçici sözleşmesi

Downloader kullanıcının hedef klasör seçmesine ihtiyaç duyduğunda:

```text
ipad1files://pickFolder?root=<percent-encoded-root>&callback=<percent-encoded-callback>
```

Birleşik indirici için önerilen geri çağrı:

```text
ipad1downloader://folderSelected?path=<percent-encoded-absolute-path>
```

Bu alma sözleşmesi fiziksel olarak doğrulanana kadar Downloader yalnızca standart `Downloads` kökünü kullanabilir. Kendi yedek klasör gezginini eklememelidir.

### İndirilen dosyayı gösterme

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

Aynı fiziksel dosya; kopya yok.

## Tamamlanan dosyanın yönlendirilmesi

Yalnızca transfer başarıyla tamamlandıktan ve yerel dosya oluştuktan sonra:

### PDF

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

### Video

İlk aşamadaki büyük/küçük harf duyarsız uzantılar:

```text
.mkv
.mp4
.mov
.m4v
.avi
```

Sözleşme:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

### Diğer dosyalar

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

Downloader PDF görüntülememeli, video çözmemeli, altyazı aramamalı ve genel bir yerel önizleme sistemi yazmamalıdır.

## HTTP/HTTPS motoru

Sorumlulukları:

- HTTP/HTTPS URL indirme;
- yönlendirmeler;
- yanıt / durum kodu doğrulaması;
- `Content-Length`;
- `Content-Disposition` dosya adı işleme;
- `.part` geçici dosya;
- doğrudan diske akıtma;
- ilerleme / hız / kalan süre;
- iptal / yeniden deneme;
- `206 Partial Content` doğrulamasıyla HTTP Range devam ettirme;
- güvenli olduğu yerde ağ kopmasından kurtarma;
- sınırlı kuyruk metadata'sı.

## FTP motoru

Sorumlulukları:

- FTP bağlantısı / kimlik doğrulama;
- uzak gezinme;
- FTP indirme / yükleme;
- uzak yeniden adlandırma / silme;
- MKD/RMD;
- kayıtlı FTP sunucuları;
- uzak arama / sıralama;
- FTP'ye özgü yeniden deneme / devam ettirme davranışı.

## Wi-Fi Alma motoru

Amaç: aynı yerel Wi-Fi/LAN üzerinden Windows bilgisayardan iPad'e dosya aktarmak.

İlk tasarım:

```text
Windows browser
    -> local HTTP connection
    -> lightweight receive server on iPad1Downloader
    -> streamed file write
    -> canonical Downloads path
```

Gereksinimler:

- dosyanın tamamı RAM'de tamponlanmaz;
- başlangıçta aynı anda tek gelen transfer;
- alınan dosya adı temizlenir;
- alım sırasında `.part`, yalnızca başarıda son ada çevrilir;
- yalnızca izin verilen ortak kök altına veya iPad1Files seçicisinin döndürdüğü yola yazılır;
- alıcıda dizin gezgini veya dosya yöneticisi yok;
- kullanıcı Wi-Fi Alma'yı kapatınca veya uygulama kapanınca sunucu durur;
- yerel adres/port ve basit bağlantı durumu gösterilir;
- tamamlanınca aynı kardeş uygulama devir kuralları uygulanır.

Basit bir yükleme sayfasına yalnızca transfer giriş noktası olarak izin verilir; yerel dosya sistemi yöneticisine dönüşmemelidir.

## Bellek ve eşzamanlılık politikası

iPad 1 için güvenli varsayılanlar:

- aynı anda tek aktif büyük transfer;
- küçük akış tamponları;
- yalnız metadata tutan sınırlı kuyruk;
- dosyanın tamamını tutan `NSData` tamponları yok;
- başlangıçta parçalı/çok iş parçacıklı indirme yok;
- büyük önbellek veya küçük resimler yok;
- gömülü tarayıcı/PDF/video alt sistemi yok.

## Fiziksel test kuralı

Kaynak kodu incelemek ve başarılı derleme, özelliğin doğrulandığı anlamına gelmez.

Belirleyici olan fiziksel iPad 1 davranışıdır. Bir özellik ancak cihaz testinden sonra doğrulanmış olarak işaretlenmelidir.
