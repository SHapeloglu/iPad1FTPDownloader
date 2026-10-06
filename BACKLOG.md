# BACKLOG.md — iPad1FTPDownloader / iPad1Downloader

Planlı işler `ROADMAP.md` (v1.3 → v1.7) ve `TASK.md` (P0–P3) içindedir. Bu dosya henüz planlanmamış maddeleri ve araştırma başlıklarını tutar. Her madde `TASK.md`'ye geçmeden önce `INTEGRATION.md`'deki sahiplik kapısından geçmelidir.

## Araştırma başlıkları (sürüm bağımlılığı değil)

- **SFTP / FTPS** — önce bağımsız bir armv7 / iOS 5 kavram kanıtı; herhangi bir entegrasyondan önce fiziksel iPad 1'de RAM/CPU profili.
- **Doğrudan medya akışı** — yalnızca uygulama ailesi sorumluluk filtresinden sonra; taşıma ile oynatma arasındaki sınır temiz kalmalı (burada çözme yok).

## Planlanmamış fikirler

- Transfer başına bant genişliği sınırı (VNC/SSH aynı Wi-Fi'yi paylaşırken işe yarar).
- Uygulama arka plandayken transfer bitince ses / yerel bildirim (iOS 5 yerel bildirimleri).
- Kayıtlı sunucu listesini (şifresiz) dışa/içe aktarma — cihaz değiştirirken.
- Hata bildirimleri için hafif transfer günlüğü dışa aktarımı (yalnız metadata, sınırlı).

## Açık doküman tutarsızlığı

`README.md` ve `INTEGRATION.md` uygulamayı birleşik **iPad1Downloader** olarak anlatıyor (FTP + HTTP/HTTPS + Wi-Fi alma motorları, paket 1.4.2); `ROADMAP.md` ise hâlâ HTTP/HTTPS'in bu repoya girmemesi gerektiğini söylüyor. HTTP özelliği eklemeden önce hangi dokümanın belirleyici olduğuna karar ver ve diğerini uyumlu hale getir.

## Açıkça kapsam dışı

Yerel dosya yönetimi / seçiciler / ZIP (iPad1Files), PDF görüntüleme (iPad1PDFReader), video oynatma (iPad1Player), terminal / SSH konsolu (iPad1Terminal), VNC (iPad1VNC), genel bulut/SMB dosya yöneticisi.
