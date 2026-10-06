# iPad1Downloader v1.4 kaynak kodu

iPad 1 / iOS 5.1.1 / armv7 / MRC / Theos için birleşik, hafif ağ transfer uygulaması.

Bu repo, `iPad1FTPDownloader`'dan `iPad1Downloader`'a geçişin aktif geliştirme tabanıdır.

## Kaynak kodun güncel durumu

Kaynakta yazıldı, **fiziksel iPad 1 testi bekleniyor**:

- mevcut FTP gezinme/indirme/yükleme ve uzak FTP işlemleri korundu;
- HTTP/HTTPS indirme ekranı eklendi;
- HTTP yanıt doğrulaması ve yönlendirmeye uygun `NSURLConnection` akışı;
- `suggestedFilename` / URL'deki dosya adına geri dönüş;
- benzersiz ad ile çakışma yönetimi;
- `.part` geçici dosyaları;
- doğrudan diske akıtma;
- HTTP ilerleme ve hız göstergesi;
- HTTP iptal;
- Windows -> iPad yerel Wi-Fi alma sunucusu;
- tarayıcı tabanlı Windows yükleme sayfası;
- aynı anda tek Wi-Fi alımı;
- Wi-Fi alma için altı haneli oturum kodu;
- Wi-Fi alma doğrudan `.part` dosyasına yazar, başarıda tamamlar;
- birleşik üç sekmeli arayüz: `FTP`, `HTTP`, `Wi-Fi Al`.

Daha önce fiziksel cihazda doğrulanmış FTP davranışı geçerliliğini korur, ancak **birleşik v1.4 paketinin kendisi henüz fiziksel cihazda doğrulanmadı**.

## Transfer sahipliği

`iPad1Downloader` yalnızca ağ transferinden sorumludur:

- FTP gezinme/indirme/yükleme ve uzak FTP işlemleri;
- HTTP/HTTPS indirmeleri;
- yerel ağ üzerinden Windows -> iPad Wi-Fi alma;
- transfer ilerlemesi / hızı;
- protokolün desteklediği yerde yeniden deneme / iptal / devam ettirme;
- sınırlı kuyruk metadata'sı;
- doğrudan diske akıtma.

FTP, HTTP/HTTPS ve Wi-Fi Alma ayrı transfer motorlarıdır. Protokol kodları tek bir dev motorda karıştırılmaz.

## iPad1Files sınırı

`iPad1Downloader` yerel dosya yöneticisi işlevleri **üstlenmemelidir**.

Bunlar `iPad1Files`'a aittir:

- yerel dosya/klasör gezinme;
- hedef klasör seçici;
- kopyala / taşı / yeniden adlandır / sil;
- ZIP / arşiv işlemleri;
- yerel arama / favoriler;
- indirilen dosyaların düzenlenmesi;
- genel "Birlikte Aç" / dosya yönetimi arayüzü.

Standart ortak indirme kökü:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Harici klasör seçici sözleşmesi fiziksel olarak doğrulanana kadar HTTP ve Wi-Fi Alma yalnızca bu köke yazar. Downloader'a ikinci bir yerel dosya gezgini ekleme.

## Wi-Fi Alma

Düşük bellekli akış:

```text
Windows browser
    -> same local Wi-Fi/LAN
    -> iPad1Downloader lightweight HTTP receive server :8080
    -> raw PUT body streamed to disk
    -> <filename>.part
    -> successful finalize
    -> /var/mobile/Media/iPad1Files/Downloads/<filename>
```

iPad şuna benzer bir yerel adres gösterir:

```text
http://192.168.x.x:8080/?token=123456
```

Bu adresi Windows'ta açın, bir dosya seçin ve `Gönder`'e basın.

Alıcı multipart form yüklemelerini ayrıştırmaz ve dosyanın tamamını RAM'e almaz. Küçük HTML sayfası seçilen dosyayı ham bir HTTP `PUT` olarak gönderir; böylece iPad tarafındaki kod küçük kalır.

## Tamamlanan dosyanın devri

Aynı fiziksel dosya yalnızca yol ile devredilir:

```text
PDF   -> ipad1pdf://open?path=...
video -> ipad1player://open?path=...
other -> ipad1files://show?path=...
```

Hiçbir dosya yalnızca entegrasyon için kopyalanmaz.

## Platform kuralları

- iPad 1 / Apple A4 / ~256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C / non-ARC MRC
- eski iPhoneOS 6.1 SDK
- doğrudan diske akıtma
- tercihen tek aktif büyük transfer
- dosyanın tamamını RAM'de tutmak yok
- gömülü genel dosya yöneticisi yok
- gömülü PDF/video motoru yok

## Derleme

```bash
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

v1.4 yeniden adlandırması sonrası beklenen paket kimliği:

```text
com.olap.ipad1downloader
```

Belirleyici olan fiziksel iPad davranışıdır. Derlenmiş v1.4 paketi cihaz testlerinden geçmeden HTTP veya Wi-Fi Alma'yı doğrulanmış diye işaretleme.
