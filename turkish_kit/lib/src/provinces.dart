import 'data/provinces_data.dart';
import 'text.dart';

/// One of Turkey's 81 provinces (il) with its districts (ilçe).
///
/// Data: T.C. İçişleri Bakanlığı, e-İçişleri "Mülki İdare Bölümleri",
/// retrieved 2026-10-22 (81 provinces, 973 districts). Names follow the
/// official spelling (for example `Hakkari`, `Kahta`, `Kağıthane`).
final class TurkishProvince {
  const TurkishProvince._(this.plateCode, this.name, this.districts);

  /// The vehicle plate code, which is also the official province code
  /// (1 = Adana … 34 = İstanbul … 81 = Düzce).
  final int plateCode;

  /// The official province name, for example `İstanbul`.
  final String name;

  /// The districts, in Turkish alphabetical order. In the 51 provinces that
  /// are not metropolitan municipalities, the central district is called
  /// `Merkez`.
  final List<String> districts;

  /// The plate code with two digits: `'06'` for Ankara.
  String get plateCodeText => plateCode.toString().padLeft(2, '0');

  /// Whether the province is a metropolitan municipality (büyükşehir; 30
  /// provinces). In these provinces every district has its own name and
  /// there is no `Merkez` district.
  bool get isMetropolitan => !districts.contains('Merkez');

  /// Whether [district] is a district of this province, ignoring case and
  /// accents (`'kagithane'` matches `Kağıthane`).
  bool hasDistrict(String district) {
    final key = TurkishText.normalizeForSearch(district);
    return districts.any((d) => TurkishText.normalizeForSearch(d) == key);
  }

  @override
  String toString() => '$plateCodeText $name';
}

/// Lookup of the 81 provinces of Turkey and their districts, embedded in the
/// package (no network needed).
abstract final class TurkishProvinces {
  /// All 81 provinces, ordered by plate code.
  static final List<TurkishProvince> all =
      List<TurkishProvince>.unmodifiable(<TurkishProvince>[
        for (final (plate, name, districts) in provinceData)
          TurkishProvince._(plate, name, List<String>.unmodifiable(districts)),
      ]);

  static final Map<String, TurkishProvince> _byKey = <String, TurkishProvince>{
    for (final province in all)
      TurkishText.normalizeForSearch(province.name): province,
  };

  /// The total number of districts (973).
  static int get districtCount =>
      all.fold(0, (sum, province) => sum + province.districts.length);

  /// The province with plate code [plateCode] (1-81), or `null`.
  static TurkishProvince? byPlateCode(int plateCode) =>
      plateCode >= 1 && plateCode <= all.length ? all[plateCode - 1] : null;

  /// The province called [name], ignoring case and accents
  /// (`'istanbul'`, `'İSTANBUL'` and `'Istanbul'` all work), or `null`.
  static TurkishProvince? byName(String name) =>
      _byKey[TurkishText.normalizeForSearch(name)];

  /// Provinces whose name contains [query], ignoring case and accents, in
  /// plate-code order. Provinces whose name starts with the query come
  /// first.
  static List<TurkishProvince> search(String query) {
    final key = TurkishText.normalizeForSearch(query);
    final starts = <TurkishProvince>[];
    final contains = <TurkishProvince>[];
    for (final province in all) {
      final name = TurkishText.normalizeForSearch(province.name);
      if (name.startsWith(key)) {
        starts.add(province);
      } else if (name.contains(key)) {
        contains.add(province);
      }
    }
    return <TurkishProvince>[...starts, ...contains];
  }

  /// All provinces that have a district called [district], ignoring case
  /// and accents. Some names exist in several provinces (for example
  /// `Ereğli` in Konya and Zonguldak, and `Merkez` in 51 provinces).
  static List<TurkishProvince> provincesWithDistrict(String district) =>
      <TurkishProvince>[
        for (final province in all)
          if (province.hasDistrict(district)) province,
      ];
}
