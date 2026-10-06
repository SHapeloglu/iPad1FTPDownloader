# TESTING.md

## Amaç

Başarılı derleme tek başına yeterli kanıt değildir. Sürüme güvenmek için iOS 5.1.1 çalıştıran bir iPad 1'de fiziksel cihaz testi gerekir.

## Derleme doğrulaması

```bash
cd ~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

Geçme ölçütleri:

- Derleme hatası yok.
- Bağlama (link) hatası yok.
- `packages/` altında `.deb` oluştu.
- Paket sürümü hedeflenen sürümle aynı.
- Hazırlanan uygulama paketinde `Info.plist` var.

## Kurulum doğrulaması

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
-o PubkeyAcceptedAlgorithms=+ssh-rsa \
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb \
root@192.168.1.2:/var/mobile/
```

iPad'de:

```bash
dpkg -i /var/mobile/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb
su mobile -c "/usr/bin/uicache"
killall SpringBoard
```

Geçme ölçütleri:

- paket kurulumu başarılı;
- uygulama açılabiliyor;
- uygulama hemen çökmüyor.

## Temel FTP bağlantı testleri

### Geçerli kimlik bilgileri

- [ ] Host/port/kullanıcı adı/şifre gir.
- [ ] `/` dizinine bağlan.
- [ ] Dizin listesi görünüyor.

### Geçersiz kimlik bilgileri

- [ ] Yanlış şifre işe yarar bir hata gösteriyor.
- [ ] Sonrasında arayüz kullanılabilir kalıyor.

### Erişilemeyen host

- [ ] Bağlantı hatası bildiriliyor.
- [ ] Uygulama donmuyor.

## Dizin yolu regresyon testleri

- [ ] `/` olduğu gibi `/` kalıyor.
- [ ] Elle girilen `domains`, `/domains/` oluyor.
- [ ] Elle girilen `/domains`, `/domains/` oluyor.
- [ ] Elle girilen `/domains/` olduğu gibi kalıyor.
- [ ] Alt klasöre gitmek sondaki `/` işaretini koruyor.
- [ ] İç içe alt klasörlerde elle `/` düzeltmesi gerekmiyor.
- [ ] Üst klasöre çıkmak doğru üst klasöre dönüyor.
- [ ] Art arda üst klasöre çıkmak sonunda `/` üretiyor.
- [ ] Her seviyede yenileme normalleştirilmiş durumu koruyor.

## FTP indirme testleri

- [ ] Küçük bir metin dosyası indir.
- [ ] Orta boy bir ikili/görsel dosya indir.
- [ ] Cihaz depolamasına uygun daha büyük bir dosya indir.
- [ ] İlerleyen bayt sayısı artıyor.
- [ ] Beklenen boyut biliniyorsa yüzde görünüyor.
- [ ] Hız göstergesi güncelleniyor.
- [ ] Son dosya `/var/mobile/Media/iPad1Files/Downloads/` altında veya fiziksel olarak doğrulanmış seçili alt klasörde.
- [ ] `/var/mobile/Media/iPad1FTPDownloads/` altında yeni bir yinelenen kopya oluşmuyor.
- [ ] Yerel boyut uzak boyutla eşleşiyor.
- [ ] İndirmenin tamamlanması bir sonraki FTP dizin işlemini bozmuyor.
- [ ] Büyük dosyalar diske kademeli yazılıyor; dosyanın tamamını RAM'de tutma davranışı görülmüyor.

## Duraklat / devam testleri

- [ ] Yeterince büyük bir FTP indirmesi başlat.
- [ ] Anlamlı ilerlemeden sonra duraklat.
- [ ] Kısmi yerel dosyanın kaldığını doğrula.
- [ ] Devam ettir.
- [ ] Sunucu ofsetle devamı destekliyorsa baştan başlamak yerine kaldığı yerden devam ettiğini doğrula.
- [ ] Son boyutun uzak boyutla eşleştiğini doğrula.
- [ ] Devam ettirmeyi desteklemeyen bir sunucuyu test et ve davranışın düzgün olduğunu doğrula.

## Yükleme testleri

- [ ] Ortak Downloads alanından veya iPad1Files'ın verdiği bir yoldan erişilebilir bir yerel dosya kullan.
- [ ] Güncel uzak FTP dizinine yükle.
- [ ] İlerleme ve hız güncelleniyor.
- [ ] Yükleme %100'e ulaşıyor.
- [ ] Uzak dizini yenile.
- [ ] Yüklenen dosya görünüyor ve boyutu eşleşiyor.

## Uzak işlem testleri

### Yeniden adlandırma

- [ ] Bir dosyayı yeniden adlandır.
- [ ] Sunucu izin veriyorsa bir klasörü yeniden adlandır.
- [ ] Yenile ve yeni adı doğrula.

### Silme

- [ ] Uzak bir dosyayı sil.
- [ ] Boş bir uzak klasörü sil.
- [ ] Boş olmayan klasör hatası anlaşılır şekilde gösteriliyor.

### Yeni klasör

- [ ] Yeni klasör oluştur.
- [ ] Listeyi yenile.
- [ ] Klasöre gir.
- [ ] Yolun `/` ile bittiğini doğrula.

## Arama ve sıralama

- [ ] Alt metin araması güncel yüklü dizindeki dosyaları buluyor.
- [ ] Alt metin araması güncel yüklü dizindeki klasörleri buluyor.
- [ ] Aramayı temizlemek yüklü listenin tamamını geri getiriyor.
- [x] A→Z çalışıyor — 2026-08-29'da fiziksel olarak doğrulandı.
- [x] Z→A çalışıyor — 2026-08-29'da fiziksel olarak doğrulandı.
- [ ] Önce klasörler çalışıyor.
- [ ] Önce klasörler kapatılabiliyor.
- [ ] Dizin değiştikten sonra arama/sıralama kullanılabilir kalıyor.

## Tamamlanan dosya devir testleri

Tüm devirler aynı tamamlanmış fiziksel dosyayı kullanmalı; kopyaya izin yok.

### Video -> iPad1Player

Büyük/küçük harf duyarsız `.mkv`, `.mp4`, `.mov`, `.m4v`, `.avi` için:

- [ ] Tamamlanma arayüzü `iPad1Player ile Aç` seçeneği sunuyor.
- [ ] `ipad1player://open?path=<encoded-path>` tamamlanmış, erişilebilir yerel yolu alıyor.
- [ ] Player kapalıyken açılınca (cold launch) aynı dosyayı açıyor.
- [ ] Player açıkken (warm launch) aynı dosyayı açıyor.
- [ ] Player scheme'i yoksa hata nazikçe gösteriliyor ve dosyaya dokunulmuyor.
- [ ] FTPDownloader medya çözme / oynatma / altyazı işlemi yapmıyor.

### PDF -> iPad1PDFReader

- [ ] `.pdf` büyük/küçük harf duyarsız algılanıyor.
- [ ] Tamamlanma arayüzü `PDFReader ile Aç` seçeneği sunuyor.
- [ ] `ipad1pdf://open?path=<encoded-path>` aynı fiziksel dosyayı açıyor.
- [ ] Cold ve warm launch çalışıyor.
- [ ] PDFReader scheme'i yoksa hata nazikçe gösteriliyor ve dosyaya dokunulmuyor.

### Diğer / Dosyalar

- [ ] `Dosyalarda Göster`, `ipad1files://show?path=<encoded-path>` çağırıyor.
- [ ] iPad1Files aynı fiziksel dosyayı gösteriyor.
- [ ] Scheme yoksa hata nazikçe gösteriliyor.

## İndirme hedefi seçici entegrasyonu

- [ ] FTPDownloader ikinci bir genel yerel gezgin yazmak yerine klasör seçimini iPad1Files üzerinden istiyor.
- [ ] Geri çağrı yolu mutlak ve standart.
- [ ] Geri çağrı yolu yalnızca `/var/mobile/Media/iPad1Files/Downloads/` altındaysa kabul ediliyor.
- [ ] Kök dışı / yol geçişi içeren yollar reddediliyor.
- [ ] Standart Downloads'a geri dönüş FTP transfer durumunu kaybettirmiyor.

## Kuyruk / eşzamanlılık testleri

- [ ] En az 3 FTP indirmesini kuyruğa al.
- [ ] Transferler FIFO sırasıyla yapılıyor.
- [ ] iPad 1'de tercih edilen başlangıç davranışı aynı anda tek aktif FTP transferi.
- [ ] İlk hata sonraki kuyruk öğelerini kalıcı olarak engellemiyor.
- [ ] Kuyruk metadata'sı sınırlı kalıyor.
- [ ] Kuyruk asla dosya içeriği tutmuyor.

## Kapsam regresyon testleri

Uygulamanın kardeş uygulamalara ait alt sistemleri **edinmediğini** doğrula:

- [ ] Genel HTTP/HTTPS indirme akışı yok.
- [ ] Tarayıcı URL indirici arayüzü yok.
- [ ] Gömülü medya oynatıcı / codec / altyazı motoru yok.
- [ ] Gömülü PDF görüntüleyici yok.
- [ ] Genel yerel dosya yöneticisi veya zengin önizleme alt sistemi yok.

## Yük / bellek testleri

Fiziksel iPad'de:

- [ ] En az 20 klasör değişikliği boyunca gezin.
- [ ] Birden fazla dosyayı ardışık indir.
- [ ] Birden fazla dosyayı ardışık yükle.
- [ ] Arama/sıralamayı tekrar tekrar kullan.
- [ ] Tamamlanan transferlerden sonra kardeş uygulama devirlerini tekrar tekrar kullan.
- [ ] Bellek uyarılarını, arayüz donmalarını, çökmeleri veya SpringBoard'un uygulamayı kapatmasını izle.

## Sürüm kapısı

Gerekli alanlardan biri başarısızsa geliştirme derlemesini kararlı diye etiketleme:

- derleme / paketleme / kurulum;
- uygulamanın açılması;
- uzak yol normalleştirmesi;
- temel FTP indirme;
- temel FTP yükleme;
- regresyonsuz dizin listeleme;
- değişen transfer yöneticisi davranışı;
- değişen kardeş uygulama devir davranışı;
- mimari kapsam kapısı.

Belirleyici olan fiziksel cihaz sonuçlarıdır.
