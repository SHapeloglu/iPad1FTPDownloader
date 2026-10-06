# TASK.md

## Güncel öncelik

Önce **v1.3 entegrasyon / kararlılık** işini bitir. Her yeni özellik, yazılmadan önce kardeş uygulama sahiplik kapısından geçmelidir.

Sahiplik:

- FTP transferi / uzak FTP işlemleri -> iPad1FTPDownloader
- HTTP/HTTPS indirmeleri -> iPad1Downloader
- yerel dosya sistemi / seçiciler -> iPad1Files
- video oynatma / codec / altyazı -> iPad1Player
- PDF -> iPad1PDFReader
- terminal / kabuk -> iPad1Terminal
- VNC / uzak masaüstü -> iPad1VNC

Devredilen işler için bkz. `SIBLING_APP_INSTRUCTIONS.md`.

## P0 — v1.3 entegrasyon için kritik

- [x] Yeni FTP indirmeleri için standart yerel indirme kökünün `/var/mobile/Media/iPad1Files/Downloads/` olduğunu doğrula.
- [x] Standart Downloads klasörü yoksa otomatik oluştur.
- [x] Yeni indirmelerde `/var/mobile/Media/iPad1FTPDownloads/` kullanımını kaldır.
- [x] Tamamlanan bir FTP dosyasının yeni düzende tam olarak tek bir fiziksel konumda olduğunu doğrula.
- [x] Tamamlanan indirmeleri yalnızca kardeş entegrasyonu için transfer sonrası kopyalama.
- [x] Uzak dizin normalleştirmesini tek bir yardımcıda topla.
- [x] Uzak dizin gezinme yollarında baştaki ve sondaki `/` kuralını zorunlu kıl.
- [x] Elle yol girişinin kuralı koruduğunu doğrula.
- [x] Alt klasöre gitmenin kuralı koruduğunu doğrula.
- [x] Üst klasöre çıkmanın kuralı koruduğunu doğrula.
- [x] Yenilemenin kuralı bağımsız olarak koruduğunu doğrula.
- [x] Üst klasöre çıkarken kökün tam olarak `/` kaldığını doğrula.
- [x] v1.3'ü derleyip fiziksel iPad 1'e kur.

## P1 — v1.3 regresyon ve devir

- [x] Doğrudan `/var/mobile/Media/iPad1Files/Downloads/` içine indir.
- [ ] Yükleme akış tabanlı ve çalışır durumda kalıyor.
- [ ] Transfer yüzdesi çalışıyor.
- [ ] Transfer hızı çalışıyor.
- [ ] Kayıtlı sunucular hâlâ çalışıyor.
- [ ] Uzak yeniden adlandırma çalışıyor.
- [ ] Uzak silme çalışıyor.
- [ ] MKD çalışıyor.
- [ ] RMD çalışıyor.
- [ ] Tamamlanan `.pdf` uzantısını büyük/küçük harf duyarsız algıla.
- [ ] `PDFReader ile Aç` eylemini ekle.
- [ ] Standart mutlak yolu yüzde-kodla (percent-encode).
- [ ] Dosyayı kopyalamadan `ipad1pdf://open?path=<encoded-path>` aç.
- [ ] Tamamlanan `.mkv`, `.mp4`, `.mov`, `.m4v`, `.avi` dosyalarını büyük/küçük harf duyarsız algıla.
- [ ] Tamamlanan video dosyaları için `iPad1Player ile Aç` eylemini ekle.
- [ ] `ipad1player://open?path=<encoded-path>` yalnızca yerel dosya tamamlanmış ve erişilebilir olduğunda açılsın.
- [ ] FTPDownloader'a video çözme / oynatma / altyazı mantığı ekleme.
- [ ] `ipad1files://show?path=<encoded-path>` ile `Dosyalarda Göster` ekle.
- [ ] Kardeş uygulamanın URL scheme'i yoksa tamamlanan dosyaya dokunmadan hatayı nazikçe göster.
- [ ] Yerel arayüzü FTP transfer durumu ve devirle sınırlı tut.

## P2 — indirme hedefi tercihi + iPad1Files seçici

- [ ] Tercih modlarını ekle: `Son kullanılan klasör`, `Her indirmede sor`, `Her zaman Downloads'a indir`.
- [ ] Varsayılan olarak basit / az zahmetli bir mod kullan; nihai varsayılan cihazda kullanıcı deneyimi testinden sonra seçilsin.
- [ ] Yalnızca hafif yol/tercih metadata'sı sakla.
- [ ] iPad1Files'a `Başka klasör seç` devrini ekle.
- [ ] `ipad1files://pickFolder?root=<encoded-root>&callback=<encoded-callback>` çağır.
- [ ] `ipad1ftp://folderSelected?path=<encoded-path>` geri çağrısını kaydet/işle.
- [ ] Geri çağrı yolunun `/var/mobile/Media/iPad1Files/Downloads/` altında kaldığını doğrula.
- [ ] Yol geçişi (path traversal) / kök dışı hedefleri reddet.
- [ ] Son seçilen klasörü hatırla.
- [ ] iPad1Files scheme'i yoksa FTP transfer durumunu kaybetmeden standart Downloads'a geri dön.

## P3 — tamamlanan dosya tercihleri

- [ ] PDF modları: `Her seferinde sor`, `Otomatik PDFReader ile aç`, `Sadece indir`.
- [ ] Önerilen PDF varsayılanı: `Her seferinde sor`.
- [ ] `ipad1pdf://` yoksa dosyayı olduğu gibi bırak ve işe yarar bir durum mesajı göster.
- [ ] Yinelenen PDF kopyası oluşmadığını doğrula.
- [ ] Benzer hafif bir video tamamlama tercihini ancak fiziksel kullanıcı deneyimi testinden sonra düşün; FTPDownloader'a oynatma ayarları ekleme.

## P4 — v1.4 FTP transfer yöneticisi

- [ ] FTP indirmesini duraklat.
- [ ] Desteklenen yerde FTP REST/ofset ile devam ettir.
- [ ] Desteklenmeyen devam davranışını temiz şekilde algıla.
- [ ] Transferi iptal et.
- [ ] FIFO kuyruk.
- [ ] iPad 1'de aktif eşzamanlılığı bilinçli olarak düşük tut; tercih edilen başlangıç tek aktif FTP transferi.
- [ ] Kuyruk uzunluğunu sınırla veya metadata'yı başka bir yolla sınırlı tut.
- [ ] Başarısız FTP transferini yeniden dene.
- [ ] Bağlantı kopmasından kurtarma.
- [ ] Düşük CPU yüküyle kalan süre hesabı.
- [ ] Üzerine Yaz / Devam Et / Yeniden Adlandır çakışma seçimi.
- [ ] Küçük, yalnız metadata tutan transfer geçmişi.
- [ ] Kuyruğa alınmış en az 3 ardışık transferi test et.
- [ ] Dosyanın tamamının tamponlanmadığını doğrula.

## P5 — uzak FTP kullanıcı deneyimi

- [ ] Kayıtlı Sunucular düzenleyicisini geliştir.
- [ ] Kayıtlı profili düzenle.
- [ ] Kayıtlı profili sil.
- [ ] **Kaynakta yazıldı, fiziksel test bekliyor:** zaten yüklenmiş dizin listesinde uzak dosya/klasör adı filtreleme; özyinelemeli tarama yok.
- [x] **iPad 1'de fiziksel olarak doğrulandı (2026-08-29):** kullanıcının seçebildiği A→Z sıralama.
- [x] **iPad 1'de fiziksel olarak doğrulandı (2026-08-29):** kullanıcının seçebildiği Z→A sıralama.
- [ ] **Kaynakta yazıldı, fiziksel test bekliyor:** önce klasörler seçeneği.
- [x] Okunabilir uzak dosya boyutu satır arayüzünde zaten var; koru.
- [ ] Sunucu liste formatı güvenilir ayrıştırmaya izin veriyorsa uzak tarih/saat metadata'sı.
- [ ] Yükleme hedefi seçimi uzak FTP yolunun sorumluluğunda kalır.
- [ ] Özyinelemeli uzak arama yazılırsa sınırlı ve iptal edilebilir olsun.

## P6 — uygulama ailesi entegrasyon iyileştirmeleri

- [ ] iPad1Files ile klasör seçici gidiş-dönüşünü fiziksel iPad 1'de doğrula.
- [ ] iPad1PDFReader kuruluyken PDF devrini doğrula.
- [ ] iPad1Player kuruluyken video devrini doğrula.
- [ ] iPad1Files scheme'i varken `Dosyalarda Göster`'i doğrula.
- [ ] Tüm kardeş uygulama eylemlerinin aynı fiziksel dosyayı kullandığını doğrula.
- [ ] Geçici FTPDownloader yerel yükleme seçicisini fiziksel olarak doğrulanmış iPad1Files `pickFile` devriyle değiştir.
- [ ] `ipad1ftp://fileSelected?path=...` geri çağrısını yalnızca iPad1Files sözleşmesi yazılıp doğrulandığında kaydet/işle.
- [ ] FTPDownloader'a "Birlikte Aç" kaydı ekleme.

## P7 — kimlik bilgisi sıkılaştırması

- [ ] Kayıtlı şifreleri iOS 5 uyumlu bir Keychain uygulamasına taşı.
- [ ] "Şifreyi kaydetme" seçeneği ekle.
- [ ] Anonim FTP desteğini iyileştir.
- [ ] Mümkün olduğunca mevcut kayıtlı profil uyumluluğunu koru.

## iPad1Downloader'a devredildi — burada yazma

- [ ] Genel HTTP indirmeleri.
- [ ] Genel HTTPS indirmeleri.
- [ ] Tarayıcı / web URL'si indirme akışları.
- [ ] HTTP yönlendirmeleri / çerezleri / başlıkları.
- [ ] HTTP/HTTPS devam ettirme.
- [ ] HTTP/HTTPS kuyruk / yeniden deneme / hata yönetimi.
- [ ] HTTP/HTTPS medya indirmelerinin tamamlanma yönlendirmesi aynı Player/PDFReader/Files devir sözleşmelerini kullanabilir, ancak uygulaması iPad1Downloader'a aittir.

## Deneysel — SFTP / FTPS

- [ ] Ana uygulamanın dışında minimal bir armv7/iOS 5 libssh2 kavram kanıtı derle.
- [ ] Fiziksel cihazda boşta RAM, transfer sırasında RAM ve CPU ölç.
- [ ] SFTP'yi yalnızca profil kabul edilebilirse entegre et.
- [ ] FTPS'i SFTP'den ayrı değerlendir.
- [ ] Bu uygulamaya SMB veya başka ağır protokoller ekleme.

## Açıkça hedef dışı

HTTP/HTTPS indirici davranışı, tarayıcıdan indirme akışları, gelişmiş yerel kopyala/taşı, genel klasör yönetimi, favoriler, dosya sistemi genelinde yerel arama, sınıflandırma, zengin önizleme çatısı, medya oynatma/codec/altyazı, tam PDF okuyucu işlevi, ZIP yöneticisi, metin düzenleyici, "Birlikte Aç" kaydı, terminal/kabuk, VNC/uzak masaüstü, OCR, AI/ML, dosyanın tamamını RAM'de tutma veya büyük arka plan önbellekleri ekleme.

## v1.3 için "bitti" tanımı

v1.3 ancak şu koşullarda bitmiş sayılır:

1. temiz derleme/paketleme/kurulum fiziksel iPad 1'de başarılı;
2. standart ortak indirme kökü kullanılıyor;
3. yeni FTP transferleri için yinelenen fiziksel kopya oluşmuyor;
4. uzak dizin gezinme hiçbir zaman elle `/` düzeltmesi gerektirmiyor;
5. FTP indirme/yükleme ve uzak komut regresyonları geçiyor;
6. ilgili kardeş uygulama kuruluyken PDF ve video tamamlama devirleri aynı fiziksel dosyayı açıyor;
7. yerel arayüz hafif ve FTP transferine odaklı kalıyor;
8. kardeş uygulamalara ait işlevler çoğaltılmak yerine devrediliyor;
9. klasör seçici / tercih işi ya yazılıp doğrulandı ya da açıkça ertelendi;
10. `TESTING.md`, `CHANGELOG.md`, `SESSION.md`, `INTEGRATION.md` ve `SIBLING_APP_INSTRUCTIONS.md` gerçek test edilmiş davranışı yansıtıyor.
