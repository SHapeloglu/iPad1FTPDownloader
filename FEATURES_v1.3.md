# v1.3 entegrasyon kapsamı

- Standart indirme klasörü: `/var/mobile/Media/iPad1Files/Downloads/`
- İndirme sonrası uygulamaya ait yinelenen kopya yok
- Uzak dizin kuralı: başta `/`, sonda `/`
- Alt / üst / yenile / elle girilen yol normalleştirmesi
- Mevcut FTP gezinme/indirme/yükleme/yeniden adlandırma/silme/MKD/RMD korundu
- PDF tamamlanınca devir: `ipad1pdf://open?path=...`
- İsteğe bağlı dosya yöneticisine devir: `ipad1files://show?path=...`
- Yalnızca hafif yerel indirme listesi; zengin önizleme / dosya yöneticisi özellikleri FTP kapsamından çıkarıldı
- iPad 1 / iOS 5.1.1 / armv7 / MRC / Theos / CFNetwork zorunlu olmaya devam ediyor
