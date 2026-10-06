# CHANGELOG.md

Projedeki önemli değişiklikler burada kaydedilir.

## [Yayımlanmadı] — v1.3 geliştirme

### Eklendi / hazırlandı

- Merkezi dizin yolu normalleştirme tasarımı.
- Yerel Downloads gezgini.
- Uzak arama.
- A→Z / Z→A sıralama.
- Temel metin/görsel/HTML/PDF önizleme altyapısı.
- İndirme duraklat/devam altyapısı.
- Sunucu ve CFNetwork izin verdiği ölçüde FTP transfer ofseti / devam desteği.
- Transfer kuyruğu altyapısı.
- İleride SFTP/FTPS çalışması için güvenli taşıma soyutlaması / entegrasyon noktaları.

### Önemli

v1.3 özellikleri, aynı kaynak kod başarıyla derlenip fiziksel iPad 1 testlerinden geçene kadar geliştirme aşamasında sayılır.

## [1.2.0]

### Eklendi

- Kayıtlı FTP sunucu desteği.
- Yükleme desteği.
- Uzak yeniden adlandırma altyapısı.
- Uzak silme altyapısı.
- Yeni klasör altyapısı.
- Transfer ilerleme arayüzü.
- Yüzde göstergesi.
- Transfer hızı göstergesi.
- Okunabilir uzak dosya boyutu gösterimi.

### Doğrulanan gözlemler

- v1.2 derlendi ve iPad 1'e kuruldu.
- Cihaz testinde yükleme %100'e ulaştı.
- Transfer hızı / ilerleme görüntülendi.

### Bulunan bilinen sorun

Eski iOS 5 CFNetwork'te dizin yolu `/` ile bitmezse dizin gezinme başarısız olabiliyor.

`/` karakterini yalnızca ağ URL'si oluşturulurken eklemek sorunu tamamen çözmedi, çünkü uygulamanın gezinme durumu hâlâ normalleştirilmemiş yolları saklıyordu.

## [1.1.0]

### Eklendi

- FTP dizin listeleme.
- Klasör gezinme.
- Üst klasöre gitme.
- Dokunarak indirilen dosya gezgini.

### Doğrulandı

Dizin listeleme ve dosya indirme fiziksel iPad 1'de çalıştı.

## [1.0.0]

### Eklendi

- İlk FTP indirici.
- Host/IP alanı.
- Port alanı.
- Kullanıcı adı / şifre alanları.
- Uzak yol.
- Yerel dosya adı.
- `/var/mobile/Media/iPad1FTPDownloads/` klasörüne akışla indirme.

### Devreye alma sırasında düzeltildi

- İlk paket yalnızca çalıştırılabilir dosyayı kurduğu ve SpringBoard uygulamayı düzgün tanıyamadığı için uygulama paketine `Info.plist` eklendi.
