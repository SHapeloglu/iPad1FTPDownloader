# SIBLING_APP_INSTRUCTIONS.md

## Amaç

Bu doküman, iPad1FTPDownloader incelenirken ortaya çıkan ve kardeş uzman uygulamalara ait olan işleri tanımlar. Bu yetenekleri iPad1FTPDownloader içinde yeniden yazma.

## Zorunlu sahiplik kapısı

Herhangi bir özelliği yazmadan önce birincil sahibini belirle:

- FTP transferi / uzak FTP işlemleri -> iPad1FTPDownloader
- HTTP/HTTPS indirmeleri -> iPad1HTTPDownloader
- yerel dosya sistemi, klasör/dosya seçme, kopyala/taşı, ZIP, genel önizleme -> iPad1Files
- video çözme / oynatma / altyazı -> iPad1Player
- PDF görüntüleme / okuma / notlandırma -> iPad1PDFReader
- kabuk / terminal / komut çalıştırma -> iPad1Terminal
- VNC / uzak masaüstü -> iPad1VNC

Yetenek başka bir uygulamaya aitse ortak fiziksel yol ve hafif bir URL-scheme devriyle entegre ol. Alt sistemi çoğaltma.

---

## iPad1HTTPDownloader yönergeleri

HTTP/HTTPS indirme iPad1FTPDownloader'a değil buraya aittir.

Beklenen sorumluluklar:

- genel HTTP indirmeleri;
- genel HTTPS indirmeleri;
- bilinçli olarak desteklenen yerlerde tarayıcı / web URL'si indirme akışları;
- yönlendirmeler;
- indirme için gereken yerlerde çerezler / başlıklar;
- HTTP/HTTPS devam ettirme;
- HTTP/HTTPS kuyruk / ilerleme / yeniden deneme / hata yönetimi;
- büyük dosyalar için doğrudan diske akıtma;
- iPad 1'de bilinçli olarak düşük eşzamanlılık.

Tamamlanan dosyaların yönlendirmesi uygulama ailesi sözleşmeleriyle aynı olmalı:

```text
.mkv/.mp4/.mov/.m4v/.avi -> ipad1player://open?path=...
.pdf                     -> ipad1pdf://open?path=...
other                    -> ipad1files://show?path=...
```

Kardeş uygulamalara yalnızca tamamlanmış, erişilebilir yerel dosya yolları verilmelidir. Dosyaları yalnızca entegrasyon için kopyalama.

---

## iPad1Files yönergeleri

### Klasör seçici

Sağlanacak:

```text
ipad1files://pickFolder?root=<percent-encoded-root>&callback=<percent-encoded-callback>
```

İndirici uygulamalar normalde standart kökü verir:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Gereksinimler:

- seçici verilen kökün içinde kalmalı;
- mutlak, standart bir yol döndürmeli;
- seçilen klasörü veya aktarılan dosyayı kopyalamamalı;
- uygulama kapalıyken de açıkken de çalışmalı (cold / warm launch);
- iPad 1 / iOS 5.1.1 / armv7 / MRC uyumluluğunu korumalı.

### FTP yüklemesi için dosya seçici

Önerilen sözleşme:

```text
ipad1files://pickFile?root=<percent-encoded-root>&callback=<percent-encoded-callback>
```

Geri çağrı:

```text
ipad1ftp://fileSelected?path=<percent-encoded-absolute-path>
```

Gereksinimler:

- yerel gezinme arayüzü iPad1Files'a aittir;
- FTPDownloader yalnızca seçilen yolu alır ve akışla FTP yüklemesi yapar;
- dosyalar çoğaltılmaz;
- erişilemeyen veya dosya olmayan sonuçlar temiz biçimde reddedilir;
- seçicinin bellek kullanımı sınırlı tutulur.

### İndirilen dosyayı gösterme

Desteklenecek:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

Aynı fiziksel dosya gösterilmelidir. Kopyalamaya izin yoktur.

### Tamamen iPad1Files'ta kalan özellikler

- yerel kopyala / taşı;
- klasör yönetimi;
- yerel arama;
- favoriler / etiketler / sınıflandırma;
- ZIP / arşiv yönetimi;
- görsel / genel dosya önizleme;
- genel "Birlikte Aç" davranışı;
- kapsamlı yerel dosya metadata arayüzü.

---

## iPad1Player yönergeleri

Tamamlanan dosya devir sözleşmesini destekle:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

İndirici uygulamalar bunu yalnızca başarıyla tamamlanmış indirmelerde, şu büyük/küçük harf duyarsız uzantılar için çağırabilir:

```text
.mkv
.mp4
.mov
.m4v
.avi
```

Gereksinimler:

- aynı tamamlanmış fiziksel dosyayı açmalı; kopya yok;
- uygulama kapalıyken de açıkken de çalışmalı;
- yalnızca erişilebilir yerel yol kabul etmeli;
- medya çözme, oynatma arayüzü, ileri sarma, codec davranışı ve altyazı bulma/gösterme tamamen iPad1Player'da kalır;
- Player, FTPDownloader'ın kuyruk/ilerleme/duraklat-devam/yeniden deneme/hata durumunu üstlenmemeli;
- Player, iPad1HTTPDownloader'ın HTTP/HTTPS transfer yaşam döngüsünü üstlenmemeli;
- indirici uygulamalar transfer sürerken video çözmemeli veya oynatmamalı.

İleride akış (streaming) için ayrı bir uygulama ailesi sorumluluk incelemesi gerekir. İndiricinin transfer durumunu Player'ın çözme/görüntüleme durumuyla birleştirme.

---

## iPad1PDFReader yönergeleri

Desteklenecek:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Gereksinimler:

- aynı tamamlanmış fiziksel PDF açılmalı;
- uygulama kapalıyken de açıkken de çalışmalı;
- görüntüleme, yakınlaştırma, sayfa gezinme, yer imi ve vurgulama tamamen iPad1PDFReader'da kalır;
- indirici uygulamalar asla PDF görüntüleme gömmemeli veya devir için yinelenen PDF kopyası oluşturmamalı.

---

## iPad1Terminal yönergeleri

Terminal ve kabuk komutu çalıştırma indirici kapsamının dışındadır. İleride yol/host devri gerekirse önce iPad1Terminal tarafından tanımlanmalıdır.

---

## iPad1VNC yönergeleri

VNC / uzak masaüstü indirici kapsamının dışındadır. İleride host bağlamı devri gerekirse önce iPad1VNC tarafından tanımlanmalıdır.

---

## İndirici uygulamaları ilgilendiren transfer kısıtları

- tamamlanan dosyalar yalnızca yol ile devredilir;
- büyük dosyalar RAM'de tamponlanmak yerine diske akıtılır;
- iPad 1'de eşzamanlılık bilinçli olarak düşük tutulur;
- kuyruk / ilerleme / duraklat-devam / yeniden deneme / hata yönetimi, taşıma protokolünün sahibi olan indiricide kalır;
- ayrıca onaylanmış bir akış sözleşmesi olmadıkça kardeş okuyucu/oynatıcı uygulamalar yalnızca tamamlanmış ve erişilebilir dosyaları alır.

## Kaldırma kuralı

İndirici içindeki geçici bir yedek davranış, sahibi olan kardeş uygulamanın fiziksel olarak doğrulanmış bir alma sözleşmesi olana kadar kalabilir. Devir iPad 1'de doğrulandıktan sonra uygun olan yerlerde yinelenen yedek davranışı kaldır.

Belirleyici olan fiziksel cihaz davranışıdır.
