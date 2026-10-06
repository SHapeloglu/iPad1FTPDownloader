# SESSION.md

## Son devir

Tarih: 2026-09-16

## Ürün kimliği

Aktif kaynak kod hâlâ şurada:

```text
https://github.com/SHapeloglu/iPad1FTPDownloader
```

ancak uygulama/paket şuna taşınıyor:

```text
iPad1Downloader
com.olap.ipad1downloader
v1.4.0
```

Ayrı `SHapeloglu/ipad1HTTPDownloader` reposu şu an boş ve aktif geliştirme tabanı değil.

## Platform kısıtları — değiştirme

- iPad 1
- Apple A4
- ~256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- eski iPhoneOS 6.1 SDK
- büyük transferler için doğrudan diske akıtma
- belirleyici olan fiziksel cihaz davranışı

## Birleşik taşıma mimarisi

`iPad1Downloader` yalnızca ağ transferinden sorumludur:

```text
FTP        -> existing FTP engine
HTTP/HTTPS -> HTTPDownloadTask
Wi-Fi Al   -> WiFiReceiveServer
```

Birleşik arayüz üç sekme kullanır:

```text
FTP | HTTP | Wi-Fi Al
```

FTP protokol kodu, HTTP protokol kodu ve Wi-Fi alma kodu ayrı motorlar olarak kalır.

## iPad1Files sahiplik sınırı

Bunları Downloader içinde YAZMA:

- yerel dosya sistemi gezgini;
- hedef klasör gezgini / seçici;
- yerel kopyala / taşı / yeniden adlandır / sil;
- ZIP / arşiv;
- yerel arama / favoriler;
- indirilen dosyaların düzenlenmesi;
- genel "Birlikte Aç" / dosya yöneticisi arayüzü.

Bunlar `iPad1Files`'a aittir.

Harici seçici henüz fiziksel olarak doğrulanmadığı sürece standart hedef:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Bir transfer = bir fiziksel dosya.

## Mevcut FTP için geçmiş doğrulamalar

Daha önce fiziksel iPad 1'de doğrulananlar:

- FTP bağlantısı / gezinme / indirme temelleri;
- alt / iç içe dizin gezinme;
- üst dizine çıkma;
- önceki testlerde izlenen standart indirme kökü davranışı;
- A->Z uzak sıralama;
- Z->A uzak sıralama;
- daha önceki bir yükleme/ilerleme akışı %100'e ulaştı.

Bunlar FTP çekirdeğine ait geçmiş sonuçlardır. Yeni birleşik v1.4 paketini otomatik olarak doğrulamazlar.

## v1.4 kaynakta yazıldı — fiziksel test bekliyor

### HTTP/HTTPS

Kaynakta yazıldı:

- `HTTPDownloadTask`;
- HTTP ve HTTPS URL doğrulaması;
- `NSURLConnection` GET taşıması;
- `NSURLConnection` üzerinden normal yönlendirme işleme;
- 2xx dışı HTTP yanıtlarının reddi;
- URL'ye geri dönüşlü `NSURLResponse suggestedFilename`;
- güvenli dosya adı normalleştirmesi;
- benzersiz ad ile çakışma yönetimi;
- `<filename>.part` geçici dosyası;
- parça parça diske yazma;
- ilerleme;
- hız;
- iptal;
- tamamlanınca PDFReader / Player / Files'a devir.

Henüz yapılmadı / doğrulanmadı:

- HTTP Range ile devam ettirme;
- 206 doğrulaması;
- yeniden deneme politikası;
- ağ kopmasından otomatik kurtarma;
- sınırlı birleşik kuyruk;
- kalan süre tahmininin yumuşatılması.

### Windows -> iPad Wi-Fi Alma

Kaynakta yazıldı:

- hafif yerel TCP/HTTP alma sunucusu;
- port 8080;
- yalnızca kullanıcı alıcıyı açtığında dinler;
- `en0` üzerinden yerel Wi-Fi IP tespiti;
- her başlatmada altı haneli oturum kodu;
- küçük tarayıcı yükleme sayfası;
- tarayıcı dosya gövdesini ham HTTP PUT ile gönderir;
- multipart ayrıştırıcı yok;
- `Content-Length` zorunlu;
- dosya adı temizleme ve çakışmaya karşı güvenli adlandırma;
- `.part` dosyasına akışla yazma;
- alım tamamlanınca son ada çevirme;
- aynı anda tek bağlantı/transfer işlenir;
- transfer kesilirse kısmi dosya korunur.

Dosyalar yalnızca buraya alınır:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Transfer sonrası yerel gezinme `iPad1Files`'ın sorumluluğunda kalır.

## v1.4 için eklenen kaynak dosyalar

```text
src/UnifiedAppDelegate.h
src/UnifiedAppDelegate.m
src/HTTPDownloadTask.h
src/HTTPDownloadTask.m
src/HTTPDownloadViewController.h
src/HTTPDownloadViewController.m
src/WiFiReceiveServer.h
src/WiFiReceiveServer.m
src/WiFiReceiveViewController.h
src/WiFiReceiveViewController.m
```

Değişenler:

```text
src/main.m
Makefile
Info.plist
control
README.md
```

## Derleme durumu

**BAŞARILI — 2026-09-16**

armv7 / iOS 5.1 hedefi için WSL/Theos temiz paket derlemesi başarıyla tamamlandı.

Gözlenen derleme sırası:

```text
Making all for application iPad1Downloader
Compiling FTP sources
Compiling HTTPDownloadTask / HTTPDownloadViewController
Compiling WiFiReceiveServer / WiFiReceiveViewController
Linking application iPad1Downloader (armv7)
Signing iPad1Downloader
Packaging com.olap.ipad1downloader_1.4.0_iphoneos-arm.deb
```

Üretilen paket:

```text
packages/com.olap.ipad1downloader_1.4.0_iphoneos-arm.deb
```

Görülen tek uyarı:

```text
ld: warning: building for iOS 5.1.0 is deprecated
```

Bu uyarı eski hedef için beklenen bir durumdur ve paketlemeyi engellemedi.

Paket derleme açısından doğrulandı ancak **henüz fiziksel iPad 1'de doğrulanmadı**.

## Hemen yapılacak sonraki adım

Şu sırayla test et:

1. `com.olap.ipad1downloader_1.4.0_iphoneos-arm.deb` paketini fiziksel iPad 1'e kur;
2. uygulamayı aç ve üç sekmenin göründüğünü doğrula: FTP / HTTP / Wi-Fi Al;
3. FTP sekmesinin hâlâ bağlandığını / listelediğini / gezindiğini doğrula;
4. küçük, düz bir HTTP dosyası dene;
5. iOS 5 TLS yığınıyla uyumlu bir HTTPS adresi dene;
6. bir HTTP yönlendirmesi dene;
7. bir HTTP indirmesini iptal et ve `.part` davranışını incele;
8. `Wi-Fi Al`'ı başlat ve iPad'in yerel adresinin gösterildiğini doğrula;
9. aynı ağdaki Windows'tan adresi açıp küçük bir dosya yükle;
10. iPad belleğini/kararlılığını izlerken daha büyük bir dosya yükle;
11. son dosyanın `iPad1Files/Downloads` içinde olduğunu doğrula;
12. özellik durumunu ancak fiziksel doğrulamadan sonra "doğrulandı" yap.

## Uygulamalar arası tamamlama sözleşmeleri

```text
PDF   -> ipad1pdf://open?path=<encoded-absolute-path>
video -> ipad1player://open?path=<encoded-absolute-path>
other -> ipad1files://show?path=<encoded-absolute-path>
```

Bir dosyayı asla yalnızca devir için çoğaltma.

## Bellek politikası

İzin verilenler:

- küçük ağ tamponları;
- doğrudan diske akıtma;
- `.part` dosyaları;
- küçük, sınırlı metadata;
- tercihen tek aktif büyük transfer.

Downloader içinde yasak olanlar:

- dosyanın tamamını RAM'de tutmak;
- gömülü yerel dosya yöneticisi;
- gömülü PDF motoru;
- gömülü medya oynatıcı / codec yığını;
- OCR / AI / ML;
- büyük önbellekler;
- kontrolsüz paralel transferler.

Uygulama ailesi sorumluluk sınırlarında `INTEGRATION.md` belirleyici olmaya devam eder.
