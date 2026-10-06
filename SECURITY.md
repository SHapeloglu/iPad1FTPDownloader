# SECURITY.md

## Kapsam

Bu proje iOS 5.1.1'i hedefleyen eski bir istemcidir. İşletim sistemi ve onun TLS/SSH ekosistemi günümüz güvenlik standartlarına göre eskimiştir. Bu yüzden güvenlik iddiaları temkinli ve açık olmalıdır.

## Kimlik bilgileri

Asla commit etme:

- FTP şifreleri
- hassas sistemlere bağlı üretim kullanıcı adları
- SSH özel anahtarları
- API token'ları
- hosting paneli kimlik bilgileri
- özel sunucu yapılandırmaları

Herkese açık repolara gidecek doküman ve ekran görüntülerinde yer tutucu değerler kullan.

## Düz FTP

Düz FTP, kimlik bilgilerini ve dosya içeriklerini aktarım sırasında şifrelemez. Yalnızca bu riskin bilindiği ve kabul edilebilir olduğu ağ/sunucularda kullan.

## SFTP

Arayüzde seçenek veya soyutlama sınıfları olması SFTP'nin yapıldığı anlamına gelmez. iOS 5/armv7 hedefi için derlenmiş libssh2 gibi gerçek bir SSH/SFTP taşıma katmanı ve fiziksel cihazda doğrulama gerekir.

## FTPS

FTPS, TLS destekli gerçek bir FTP uygulaması gerektirir. iOS 5'in eski TLS yetenekleri günümüz sunucu politikalarıyla uyumsuz olabilir. Güvenlik etkisini anlamadan, yalnızca bu istemciye uyum için üretim sunucusunun TLS yapılandırmasını zayıflatma.

## Kayıtlı şifreler

Kayıtlı sunucu profilleri şifreleri basit tercihler (preferences) içinde saklıyorsa bunu güvenli gizli bilgi saklama değil, kolaylık olarak değerlendir. İleride şifreler iOS 5 uyumlu bir Keychain uygulamasına taşınmalıdır.

## Dağıtımda kullanılan eski SSH

Güncel OpenSSH, jailbreak'li iPad'deki eski SSH sunucusuyla konuşmak için şu uyumluluk ayarını gerektirebilir:

```bash
-o HostKeyAlgorithms=+ssh-rsa
```

Bu ayarı tek komutla veya hosta özel SSH yapılandırmasıyla sınırlı tut. Eski algoritmaları ilgisiz hostlar için genel olarak yeniden açma.

## Güvenlik açığı bildirimi

Bir güvenlik sorunu bildirirken şunları ekleyin:

- etkilenen sürüm;
- iOS sürümü / cihaz;
- ilgili protokol;
- yeniden üretme adımları;
- sorunun kimlik bilgilerini, dosya içeriklerini veya dosya sistemine keyfi erişimi açığa çıkarıp çıkarmadığı;
- davranışın uygulamadan mı yoksa eski platformun kendisinden mi kaynaklandığı.

## Sürüm kuralı

Bir protokolün veya kimlik bilgisi saklama özelliğinin gerçek uygulaması ve cihaz üzerindeki davranışı incelenip test edilmeden onu güvenli diye tanımlama.
