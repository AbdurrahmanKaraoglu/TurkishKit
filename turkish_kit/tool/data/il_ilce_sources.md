# il_ilce.json — kaynaklar, lisans ve çapraz kontrol

Erişim tarihi: 2026-10-22. Çıktı: `il_ilce.json` (81 il, 973 ilçe, plaka sırası, ilçeler Türk alfabesine göre sıralı, UTF-8, LF).

## Kaynak 1 (birincil, resmi) — T.C. İçişleri Bakanlığı, e-İçişleri "Türkiye Mülki İdare Bölümleri Envanteri"

- URL: https://www.e-icisleri.gov.tr/Anasayfa/MulkiIdariBolumleri.aspx
- Yöntem: Sayfa curl/Python ile alındı; il açılır listesi (`DropDownListIl`, option value = plaka kodu) okundu, her il için ASP.NET postback ile `DropDownListIlce` listesi çekildi (81 istek, 0,5 sn aralıklı).
- Sayfadaki özet sayaçlar (aynı gün): İl 81, İlçe 922 (kaymakamlıklı ilçe; il merkezi ilçeleri hariç), Büyükşehir 30, İl belediyesi 51. 922 + 51 "MERKEZ" = 973. Açılır listelerdeki toplam: **973**, 51 ilde "MERKEZ" var.
- Ham veri: `dl/eic.json` (sha256 1b556850d86c0660d2292a077b31061ad3051396a4d2f43dc22673affe16444f). Adlar BÜYÜK HARFLİ ve şapkasız (ör. KAHTA, BALA, KAĞITHANE).
- Lisans / hukuki durum: Sayfada açık bir lisans (CC, açık veri lisansı vb.) BELİRTİLMİYOR. İl/ilçe adları ve hangi ile bağlı oldukları olgudur (fact); tek başına eser niteliği taşımaz. İlçe kuruluşları ve ad değişiklikleri kanunla yapılır (ör. 6360 sayılı Kanun), FSEK md. 31 kanun, tüzük, yönetmelik ve Resmî Gazete'de yayımlanan resmî metinleri koruma dışında tutar. Bu bir hukuki görüş değildir; ticari dağıtım öncesi kullanıcı değerlendirmelidir.

## Kaynak 2 (bağımsız çapraz kontrol) — Türkçe Vikipedi "Türkiye'nin ilçeleri"

- URL: https://tr.wikipedia.org/wiki/T%C3%BCrkiye%27nin_il%C3%A7eleri
- API ile alındı: https://tr.wikipedia.org/w/api.php?action=parse&page=T%C3%BCrkiye%27nin_il%C3%A7eleri&prop=wikitext&format=json&formatversion=2
- Revizyon: revid 37373921, 2026-06-23T06:05:10Z. Ham: `dl/wiki.json` (sha256 ca5fcf4a3aec4326ebb6fa090384770c441b605c18e2365b9db574598a0a0251).
- "İlçelerin listesi" tablosu ayrıştırıldı: 973 satır, 81 il. Büyükşehir olmayan illerde merkez ilçe il adıyla yazılıyor (ör. "Zonguldak"); karşılaştırmada "Merkez"e eşlendi.
- Not: Vikipedi metni de 973 rakamı için e-İçişleri'ni kaynak gösteriyor; yani sayım tamamen bağımsız değil, ancak ilçe listesi ayrı (gönüllü) düzenlenmiş bir tablodur.
- Lisans: CC BY-SA 4.0 (metin). Bu projede Vikipedi'den metin/tablo kopyalanmadı; yalnızca olgusal karşılaştırma için kullanıldı. JSON'daki adlar resmi kaynaktan türetildi.

## Dönüşüm kuralları

- Resmi BÜYÜK HARF adlar Türkçe kurala göre başlık harfine çevrildi (I→ı, İ→i; her kelimenin ilk harfi büyük). "MERKEZ" → "Merkez". Çok kelimeli tek ad: "19 Mayıs" (Samsun).
- İl adları da resmi listeden: Afyonkarahisar, Hakkari, Kahramanmaraş, Şanlıurfa, Tunceli, Mersin (resmi listede "MERSİN"). Ankara'da "Kahramankazan" var (eski Kazan).
- Sıralama: Türk alfabesi (a b c ç d e f g ğ h ı i j k l m n o ö p r s ş t u ü v y z), rakamla başlayan ad başta.

## Çapraz kontrol sonucu

İl sayısı 81/81, toplam ilçe 973/973, **her ilde ilçe sayısı iki kaynakta aynı** (tablo aşağıda). Ad eşleşmesi (büyük/küçük harf ve şapka yok sayılarak) 969/973 birebir. Farklar:

| İl | Resmi (e-İçişleri) | Vikipedi | Çözüm |
|---|---|---|---|
| 02 Adıyaman | KAHTA → Kahta | Kâhta | Resmi yazım alındı (şapkasız) |
| 06 Ankara | BALA → Bala | Balâ | Resmi yazım alındı |
| 34 İstanbul | KAĞITHANE → Kağıthane | Kâğıthane | Resmi yazım alındı |
| 67 Zonguldak | EREĞLİ → Ereğli | Karadeniz Ereğli | Resmi ad alındı (Vikipedi yaygın/belediye adını kullanıyor) |
| 30 Hakkari (il) | HAKKARİ | Hakkâri | Resmi yazım "Hakkari" alındı |

Açık sorular (kullanıcı kararı):
1. Şapkalı yazım (Kâhta, Balâ, Kâğıthane, Hakkâri) istenir mi? Resmi liste şapkasız; JSON şapkasız.
2. Zonguldak'taki ilçe "Ereğli" (resmi) mi, "Karadeniz Ereğli" (yaygın) mı gösterilsin? Konya'da da "Ereğli" var; aynı ad iki ilde bulunuyor.
3. Büyükşehir olmayan 51 ilde merkez "Merkez" olarak tutuldu; arayüzde "Merkez (Zonguldak)" gibi bir gösterim gerekebilir.

## İl başına ilçe sayıları

| Plaka | �l | Resmi | Wikipedia | Merkez |
|---|---|---|---|---|
| 01 | Adana | 15 | 15 | - |
| 02 | Ad�yaman | 9 | 9 | evet |
| 03 | Afyonkarahisar | 18 | 18 | evet |
| 04 | A�r� | 8 | 8 | evet |
| 05 | Amasya | 7 | 7 | evet |
| 06 | Ankara | 25 | 25 | - |
| 07 | Antalya | 19 | 19 | - |
| 08 | Artvin | 9 | 9 | evet |
| 09 | Ayd�n | 17 | 17 | - |
| 10 | Bal�kesir | 20 | 20 | - |
| 11 | Bilecik | 8 | 8 | evet |
| 12 | Bing�l | 8 | 8 | evet |
| 13 | Bitlis | 7 | 7 | evet |
| 14 | Bolu | 9 | 9 | evet |
| 15 | Burdur | 11 | 11 | evet |
| 16 | Bursa | 17 | 17 | - |
| 17 | �anakkale | 12 | 12 | evet |
| 18 | �ank�r� | 12 | 12 | evet |
| 19 | �orum | 14 | 14 | evet |
| 20 | Denizli | 19 | 19 | - |
| 21 | Diyarbak�r | 17 | 17 | - |
| 22 | Edirne | 9 | 9 | evet |
| 23 | Elaz�� | 11 | 11 | evet |
| 24 | Erzincan | 9 | 9 | evet |
| 25 | Erzurum | 20 | 20 | - |
| 26 | Eski�ehir | 14 | 14 | - |
| 27 | Gaziantep | 9 | 9 | - |
| 28 | Giresun | 16 | 16 | evet |
| 29 | G�m��hane | 6 | 6 | evet |
| 30 | Hakkari | 5 | 5 | evet |
| 31 | Hatay | 15 | 15 | - |
| 32 | Isparta | 13 | 13 | evet |
| 33 | Mersin | 13 | 13 | - |
| 34 | �stanbul | 39 | 39 | - |
| 35 | �zmir | 30 | 30 | - |
| 36 | Kars | 8 | 8 | evet |
| 37 | Kastamonu | 20 | 20 | evet |
| 38 | Kayseri | 16 | 16 | - |
| 39 | K�rklareli | 8 | 8 | evet |
| 40 | K�r�ehir | 7 | 7 | evet |
| 41 | Kocaeli | 12 | 12 | - |
| 42 | Konya | 31 | 31 | - |
| 43 | K�tahya | 13 | 13 | evet |
| 44 | Malatya | 13 | 13 | - |
| 45 | Manisa | 17 | 17 | - |
| 46 | Kahramanmara� | 11 | 11 | - |
| 47 | Mardin | 10 | 10 | - |
| 48 | Mu�la | 13 | 13 | - |
| 49 | Mu� | 6 | 6 | evet |
| 50 | Nev�ehir | 8 | 8 | evet |
| 51 | Ni�de | 6 | 6 | evet |
| 52 | Ordu | 19 | 19 | - |
| 53 | Rize | 12 | 12 | evet |
| 54 | Sakarya | 16 | 16 | - |
| 55 | Samsun | 17 | 17 | - |
| 56 | Siirt | 7 | 7 | evet |
| 57 | Sinop | 9 | 9 | evet |
| 58 | Sivas | 17 | 17 | evet |
| 59 | Tekirda� | 11 | 11 | - |
| 60 | Tokat | 12 | 12 | evet |
| 61 | Trabzon | 18 | 18 | - |
| 62 | Tunceli | 8 | 8 | evet |
| 63 | �anl�urfa | 13 | 13 | - |
| 64 | U�ak | 6 | 6 | evet |
| 65 | Van | 13 | 13 | - |
| 66 | Yozgat | 14 | 14 | evet |
| 67 | Zonguldak | 8 | 8 | evet |
| 68 | Aksaray | 8 | 8 | evet |
| 69 | Bayburt | 3 | 3 | evet |
| 70 | Karaman | 6 | 6 | evet |
| 71 | K�r�kkale | 9 | 9 | evet |
| 72 | Batman | 6 | 6 | evet |
| 73 | ��rnak | 7 | 7 | evet |
| 74 | Bart�n | 4 | 4 | evet |
| 75 | Ardahan | 6 | 6 | evet |
| 76 | I�d�r | 4 | 4 | evet |
| 77 | Yalova | 6 | 6 | evet |
| 78 | Karab�k | 6 | 6 | evet |
| 79 | Kilis | 4 | 4 | evet |
| 80 | Osmaniye | 7 | 7 | evet |
| 81 | D�zce | 8 | 8 | evet |
| | **Toplam** | **973** | **973** | **51** |

Çıktı sha256: 199c554bc6efa1b6033b64891a21ce80e10e1296ce67270e79fd912bb8f46dc3
Betikler: scripts/eic.py, scripts/wiki.py, scripts/build.py (yeniden üretilebilir).
