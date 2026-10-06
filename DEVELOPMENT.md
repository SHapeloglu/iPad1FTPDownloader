# DEVELOPMENT.md

## Geliştirme ortamı

Tipik kurulum:

- Windows ana makine
- WSL Ubuntu
- Ubuntu içinde kurulu Theos
- Aynı yerel ağda jailbreak'li iPad 1
- Hedef: iOS 5.1.1 / armv7

## Proje konumu

Güncel geliştirme klasörü düzeni:

```text
~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
```

`make` çalıştırmadan önce her zaman proje klasöründe olduğunu doğrula:

```bash
pwd
ls
```

Beklenen dosyalar:

```text
Makefile
Info.plist
control
src/
README.md
```

## Saat kayması geçici çözümü

Windows/WSL ile indirilen arşivler WSL'e göre gelecekte görünen zaman damgaları içerebilir.

Derlemeden önce:

```bash
find . -type f -exec touch {} +
```

Ardından:

```bash
make clean
make package FINALPACKAGE=1
```

`Clock skew detected` gibi bir uyarı her zaman derlemeyi durdurmayabilir, ancak zaman damgalarını düzeltmek belirsizliği ortadan kaldırır.

## Beklenen paket

v1.3 için:

```text
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb
```

Kontrol:

```bash
ls -lh packages/
```

## Ağ kontrolü

iPad'in DHCP adresi değişebilir. SCP'den önce erişilebilirliği kontrol et:

```bash
ping -c 4 192.168.1.2
```

Farklıysa güncel adresi kullan.

## iPad'e kopyalama

Eski iOS OpenSSH, RSA host anahtarı uyumluluğu gerektirebilir:

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb \
root@192.168.1.2:/var/mobile/
```

Bu eski SSH sunucusuna bağlanırken güncel OpenSSH'nin "post-quantum" uyarısı vermesi beklenir. Uyumluluk ayarı bu cihaz/komutla sınırlı kalmalıdır.

## iPad kabuğuna girme

```bash
ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.1.2
```

İstem (prompt) şuna benzer bir satırdan:

```text
yeliz@DESKTOP-CSC9788:...
```

şuna dönüşür:

```text
apaches-iPad:~ root#
```

iPad paket komutlarını yalnızca bu değişiklikten sonra kullan.

## Kurulum

iPad'de:

```bash
dpkg -i /var/mobile/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb
su mobile -c "/usr/bin/uicache"
killall SpringBoard
```

Bazı eski `uicache` sürümleri ölümcül olmayan süreç/önbellek mesajları basar. Her mesajı kurulum hatası saymak yerine gerçek uygulama paketini ve açılış davranışını kontrol et.

## Uygulama paketi tanılama

```bash
ls -la /Applications/iPad1FTPDownloader.app
```

Paket en az şunları içermelidir:

```text
Info.plist
iPad1FTPDownloader
```

Simge görünmüyorsa önbelleği / SpringBoard'u yenile. Uygulama açılıp hemen kapanıyorsa, çalışma zamanı hatasını görmek için çalıştırılabilir dosyayı iPad kabuğundan başlat:

```bash
/Applications/iPad1FTPDownloader.app/iPad1FTPDownloader
```

## Sürüm disiplini

Sürüm çıkmadan önce şunları uyumlu tut:

- `control` paket sürümü
- `Info.plist` bundle sürümleri
- README örnekleri
- dokümanlardaki paket dosya adı
- CHANGELOG bölümü

## Git akışı

Önerilen:

```bash
git status
git add .
git commit -m "feat: ..."
git push origin main
```

Push'tan önce yanlışlıkla eklenmiş kimlik bilgisi olup olmadığına bak:

```bash
git diff --cached
```

FTP şifrelerini, özel sunucu kimlik bilgilerini, SSH özel anahtarlarını veya hassas üretim yapılandırmalarını commit etme.

## Hata ayıklama ilkesi

Bu projede, davranışın şu nedenlerle farklılaşabileceği her durumda fiziksel iPad'de yeniden üret:

- iOS 5 CFNetwork;
- eski UIKit;
- dosya sistemi izinleri;
- SpringBoard önbelleği;
- armv7 bağlama (linking);
- eski OpenSSH;
- düşük bellek baskısı.
