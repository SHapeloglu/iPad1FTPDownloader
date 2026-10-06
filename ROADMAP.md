# ROADMAP.md

## Ürün yönü

iPad1FTPDownloader, iPad 1 / iOS 5.1.1 için odaklı **FTP uzmanıdır**.

Uygulama ailesi sahipliği:

- FTP transferi / uzak FTP işlemleri -> iPad1FTPDownloader
- HTTP/HTTPS indirme -> iPad1Downloader
- yerel dosya sistemi / seçiciler -> iPad1Files
- video oynatma / codec / altyazı -> iPad1Player
- PDF okuma / görüntüleme -> iPad1PDFReader
- terminal / kabuk -> iPad1Terminal
- VNC / uzak masaüstü -> iPad1VNC

FTP ile indirilen medya dosyası tamamlanana kadar FTPDownloader transferi olarak kalır; iPad1Player'a yalnızca tamamlanmış yerel yol verilir.

Standart FTP akışı:

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

Rakiplerden esinlenen her özellik bu yol haritasına girmeden önce sahiplik kapısından geçmelidir.

## v1.3 — entegrasyon ve kararlılık

- Standart indirme kökü: `/var/mobile/Media/iPad1Files/Downloads/`.
- Ortak Downloads klasörünü otomatik oluştur.
- Bir FTP transferi = bir fiziksel dosya.
- Merkezi uzak dizin normalleştirmesi.
- FTP indirme/yükleme/yeniden adlandırma/silme/MKD/RMD davranışını koru.
- `ipad1pdf://open?path=...` ile aynı yoldan PDF devri.
- `.mkv/.mp4/.mov/.m4v/.avi` için yalnızca başarılı tamamlanma sonrası `ipad1player://open?path=...` ile aynı yoldan video devri.
- `ipad1files://show?path=...` ile `Dosyalarda Göster`.
- Gömülü önizleme / oynatıcı / dosya yöneticisi ekranı yok.
- İndirme hedefi tercih modeli FTPDownloader'ın; asıl klasör seçici iPad1Files'ın.
- Yalnızca fiziksel cihaz doğrulamasından sonra sürüm çıkar.

## v1.4 — FTP transfer yöneticisi

- Duraklat / devam / iptal.
- Desteklenen yerde FTP REST/ofset ile devam ettirme.
- FIFO kuyruk ve sınırlı metadata.
- iPad 1'de başlangıçta aynı anda tek aktif FTP transferi tercih et.
- Başarısız FTP transferlerini yeniden dene.
- İlerleme / hız / kalan süre.
- Üzerine Yaz / Devam Et / Yeniden Adlandır çakışma seçenekleri.
- Küçük, yalnız metadata tutan transfer geçmişi.
- Bağlantı kopmasından kurtarma.
- Doğrudan diske akıt; dosyanın tamamını asla tamponlama.

## v1.5 — uzak FTP kullanıcı deneyimi

- Geliştirilmiş Kayıtlı Sunucular düzenleyicisi.
- Yüklü listede uzak dosya/klasör adı araması.
- A→Z / Z→A sıralama.
- Önce klasörler sıralaması.
- Okunabilir uzak dosya boyutu.
- Güvenilir olduğu yerde uzak tarih/saat metadata'sı.
- Yeniden adlandır / sil / MKD / RMD iyileştirmeleri.
- Uzak FTP yükleme hedefi seçimi.
- Özyinelemeli arama yalnızca sınırlı ve iptal edilebilirse.

## v1.6 — kardeş uygulama entegrasyonu iyileştirmeleri

- iPad1Files klasör seçici geri çağrısının sağlam gidiş-dönüşü.
- Sağlam `Dosyalarda Göster`.
- iPad1Player'a aynı dosya ile sağlam devir.
- iPad1PDFReader'a aynı dosya ile sağlam devir.
- Aynı dosya doğrulaması.
- Fiziksel olarak doğrulanınca geçici yerel yükleme seçicisini iPad1Files `pickFile` ile değiştir.

## v1.7 — kimlik bilgisi sıkılaştırması

- iOS 5 uyumlu Keychain.
- Şifreyi kaydetmeme seçeneği.
- Anonim FTP iyileştirmeleri.
- Kayıtlı kimlik bilgisini güvenle güncelleme/silme.

## iPad1Downloader yol haritasına açıkça devredilenler

Aşağıdakiler bu reponun yol haritasına girmemelidir:

- HTTP/HTTPS indirme motoru;
- tarayıcı URL indiricisi;
- yönlendirme / çerez / başlık yönetimi;
- HTTP/HTTPS devam ettirme;
- HTTP/HTTPS kuyruk / yeniden deneme / hata yönetimi.

Bunlar iPad1Downloader'a aittir. O uygulama Player/PDFReader/Files'a aynı tamamlanan dosya devir sözleşmelerini kullanabilir.

## Deneysel — SFTP / FTPS

SFTP ve FTPS, sürüm bağımlılığı değil, FTP/ağ protokolü araştırma başlıklarıdır. Entegrasyondan önce bağımsız armv7/iOS 5 kavram kanıtları yap ve fiziksel iPad 1'de RAM/CPU profilini çıkar.

## Açıkça kardeş uygulamalara ait yetenekler

Rakipler bunları bir arada sunsa bile FTPDownloader'da yazma:

- HTTP/HTTPS indirmeleri -> iPad1Downloader;
- yerel kopyala/taşı/klasör yönetimi/seçiciler/ZIP -> iPad1Files;
- PDF görüntüleme/notlandırma -> iPad1PDFReader;
- video oynatma/codec/altyazı -> iPad1Player;
- terminal/kabuk/SSH konsolu -> iPad1Terminal;
- VNC/uzak masaüstü -> iPad1VNC;
- genel bulut/SMB dosya yöneticisi -> ayrı bir uzman uygulama.

## Akış (streaming)

Doğrudan medya akışı FTPDownloader veya Player için otomatik olarak onaylı değildir. Önce uygulama ailesinin sorumluluk filtresinden geçmeli ve taşıma ile oynatma arasındaki sınırı temiz tutmalıdır.

## Ürün kuralı

- FTP -> iPad1FTPDownloader
- HTTP/HTTPS -> iPad1Downloader
- yerel dosya sistemi -> iPad1Files
- video oynatma -> iPad1Player
- PDF -> iPad1PDFReader
- terminal -> iPad1Terminal
- VNC -> iPad1VNC

Yinelenen alt sistemler yerine ortak fiziksel yolları ve hafif URL-scheme devirlerini tercih et.
