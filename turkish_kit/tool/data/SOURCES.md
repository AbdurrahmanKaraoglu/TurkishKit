# Data sources / Veri kaynakları

The embedded data in `lib/src/data/` is generated from the files in this
folder by `dart run tool/generate_data.dart`. Nothing was typed in by hand.

| File | Content | Source | Retrieved |
| --- | --- | --- | --- |
| `il_ilce.json` | 81 provinces (plate code, name) and 973 districts | T.C. İçişleri Bakanlığı, e-İçişleri "Mülki İdare Bölümleri" — https://www.e-icisleri.gov.tr/Anasayfa/MulkiIdariBolumleri.aspx ; cross-checked with Turkish Wikipedia "Türkiye'nin ilçeleri" (rev. 37373921) | 2026-10-22 |
| `bayramlar.csv` | First day of Ramazan and Kurban Bayramı, 2020–2035 | Diyanet İşleri Başkanlığı — https://vakithesaplama.diyanet.gov.tr/ (dini günler / resmi tatiller), 2020–2021 from Diyanet mobile calendar and müftülük pages; cross-checked with timeanddate.com | 2026-10-22 |

Details, per-province counts, discrepancies and how they were resolved:

* [il_ilce_sources.md](il_ilce_sources.md) (Türkçe)
* [bayramlar_sources.md](bayramlar_sources.md) (English)

## Licence notes

* Province and district names are facts and official records. Turkish
  copyright law (FSEK art. 31) leaves laws, regulations and official
  announcements unprotected. The government page states no licence. No
  Wikipedia text (CC BY-SA) is included; Wikipedia was only used to compare
  counts and names.
* Holiday rules come from Law No. 2429 (Ulusal Bayram ve Genel Tatiller
  Hakkında Kanun, https://www.mevzuat.gov.tr/mevzuatmetin/1.5.2429.pdf).
  Bayram dates are facts published by Diyanet.

## Known differences

* Official spelling is used: `Hakkari`, `Kahta`, `Bala`, `Kağıthane`
  (Wikipedia: Hakkâri, Kâhta, Balâ, Kâğıthane) and Zonguldak's `Ereğli`
  (Wikipedia: Karadeniz Ereğli).
* Ramazan Bayramı 2028 (26 Feb) and 2029 (14 Feb): Diyanet's date is used;
  timeanddate.com shows one day later (marked tentative there). Re-check when
  Diyanet publishes the final calendar for those years.

## Updating

1. Update `il_ilce.json` or `bayramlar.csv` from the official source.
2. `dart run tool/generate_data.dart && dart format lib`
3. Update `TurkishHolidays.lastYear` if the bayram table grows, and the tests.
