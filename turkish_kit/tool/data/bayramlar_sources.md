# Bayram dates: sources and verification notes

Retrieved 2026-10-22 (curl over Git Bash, plus web search for 2020/2021 and the 2027-2029 cross-checks).

## Primary source: Diyanet (vakithesaplama.diyanet.gov.tr)

Per-year "Dini Günler" lists. Each row shows the Hijri date, the Gregorian date and the weekday. I checked every weekday against `date`:
- 2022-2026: https://vakithesaplama.diyanet.gov.tr/dinigunler.php?yil=YYYY
- 2027: https://vakithesaplama.diyanet.gov.tr/icerik.php?icerik=154
- 2028-2035: https://vakithesaplama.diyanet.gov.tr/icerik.php?icerik=185 to 192 (185 = 2028 ... 192 = 2035)

Diyanet's own "Resmi Tatiller" pages, used as an internal consistency check. All checked years agree with the Dini Günler pages, including arife = the day before the first day and the "1/2 GÜN" label:
- 2022: https://vakithesaplama.diyanet.gov.tr/resmitatiller.php?yil=2022
- 2023-2027: icerik=155 to 159; 2028-2035: icerik=193 to 200

**Range Diyanet covers:** the per-year lists run from 2022 to 2035. No list exists for 2036 or later; `dinigunler.php?yil=2036` returns no data. The search tool at https://vakithesaplama.diyanet.gov.tr/dini_gunler.php is labelled "1900-2027". It is a POST form protected by an F5 bot token (as_sfid), and it returned an empty table to curl, so I did not use it. `dinigunler.php?yil=2020/2021` also return no data.

**2020 and 2021 (not on the vakithesaplama per-year pages):**
- 2021: Diyanet's mobile calendar https://mobil.diyanet.gov.tr/mobile/dinigunler/dinigunler.html (covers 2021-2028; for 2021-2028 it matches the vakithesaplama pages exactly). The Devrek Müftülüğü list agrees: https://webdosyasp.diyanet.gov.tr/muftuluk/UserFiles/zonguldak/Ilceler/devrek/UserFiles/Files/2021%20Y%C4%B1l%C4%B1%20Dini%20G%C3%BCnler%20Listesi_25819f9c-e4ff-4d15-9a01-87e86550921b.pdf
- 2020 Ramazan, 24 May: Karaman Müftülüğü (Diyanet domain), https://karaman.diyanet.gov.tr/sayfalar/contentdetail.aspx?MenuCategory=Kurumsal&ContentId=748
- 2020 Kurban, 31 Jul (Friday): Alanya Müftülüğü (Diyanet domain), https://antalya.diyanet.gov.tr/alanya/sayfalar/contentdetail.aspx?MenuCategory=Kurumsal&ContentId=947
- These come from provincial müftülük pages, not a central Diyanet year list. I saw them as web-search summaries and did not curl them.

## Independent cross-check

- timeanddate.com, https://www.timeanddate.com/holidays/turkey/YYYY for 2020-2036. It labels 2027 onward "Tentative".
- Turkish press for 2027 (it cites Diyanet's 2027 calendar): https://www.evrensel.net/haber/5997565/diyanet-2027-takvimini-duyurdu-ramazan-ne-zaman-basliyor and https://www.gazetevatan.com/galeri/ramazan-bayrami-2027-ne-zaman-diyanet-takvimine-gore-2027-ramazan-baslangici-ve-bayram-tarihleri-2405578

## Discrepancies

| Year | Bayram | Diyanet | timeanddate | Status |
|---|---|---|---|---|
| 2027 | Ramazan | 2027-03-09 (Tue) | 2027-03-10 | Press reports of Diyanet's 2027 calendar give 9 Mar, so cross_check_ok=yes |
| 2028 | Ramazan | 2028-02-26 (Sat) | 2028-02-27 | No independent match, so cross_check_ok=no |
| 2029 | Ramazan | 2029-02-14 (Wed) | 2029-02-15 | No independent match, so cross_check_ok=no |

Diyanet's dini günler page and its resmi tatiller page agree with each other in all three cases. Diyanet sets these dates by its own calculation (the 1978 Istanbul criteria); timeanddate's future dates are estimates. Diyanet's dates are the ones Turkish law follows, so I kept them in the CSV. Before shipping the 2028 and 2029 Ramazan dates, re-check them once the official calendar for that year is published. Every other year from 2020 to 2035 matches timeanddate exactly.

## Years with zero or two of a bayram (Hijri drift)

- **2033:** two Ramazan Bayramı (2033-01-02 = 1 Şevval 1454, and 2033-12-23 = 1 Şevval 1455), plus one Kurban (2033-03-11). Diyanet's 2033 resmi tatiller page confirms both Ramazan holidays.
- **2034 and 2035:** one of each. 2034: Kurban 2034-03-01, Ramazan 2034-12-12. 2035: Kurban 2035-02-18, Ramazan 2035-12-01.
- No year from 2020 to 2035 is missing either bayram.
- Edge cases: the 2033-01-02 bayram's arife is 2033-01-01, so it falls on the New Year holiday. Bayrams can also run across a month boundary (Kurban 2023: 06-28 to 07-01) or a year boundary.
- **Not verifiable (outside Diyanet's range):** timeanddate's tentative dates for 2036 are Kurban 2036-02-08 and Ramazan 2036-11-19. I left them out of the CSV.

## Law No. 2429 (as in force)

Sources: the official consolidated text, https://www.mevzuat.gov.tr/mevzuatmetin/1.5.2429.pdf (curl, then pdftotext), and Diyanet's copy, https://vakithesaplama.diyanet.gov.tr/2429_kanun.php. The two texts agree.
- Adopted 17/3/1981; published in Resmî Gazete 19/3/1981, issue 17284.
- Art. 1: 29 Ekim is the national holiday. It "begins on 28 Ekim at 13.00", so 28 Ekim is a half day.
- Art. 2/A: 23 Nisan, 19 Mayıs and 30 Ağustos.
- Art. 2/B: Ramazan Bayramı is 3.5 days counted from 13.00 on arefe day. Kurban Bayramı is 4.5 days counted from 13.00 on arefe day. Arefe therefore starts at **13:00**.
- Art. 2/C (as amended by 6752): 1 Ocak, 1 Mayıs (Emek ve Dayanışma Günü) and 15 Temmuz (Demokrasi ve Milli Birlik Günü).
- **1 Mayıs** was added by Law 5892 of 22/4/2009, in force 27/4/2009. 1 May 2009 was the first such holiday.
- **15 Temmuz** was added by Law 6752 of 25/10/2016, in force 29/10/2016. 15 July 2017 was the first such holiday.
- Art. 3/A also sets a half day for Saturday afternoons (weekly-rest rule). This is not a holiday rule and is noted only for context.
- Extra days, such as "idari izin" bridge days or the 9-day bayram extensions, are set by separate Presidential/Cabinet decisions. They are not part of Law 2429. Some timeanddate rows reflect them, for example 2022-07-13/14 and 2024-06-20/21.
