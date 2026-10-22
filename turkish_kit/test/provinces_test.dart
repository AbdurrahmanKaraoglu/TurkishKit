import 'package:test/test.dart';
import 'package:turkish_kit/turkish_kit.dart';

void main() {
  test('81 provinces with plate codes 1-81 and 973 districts', () {
    expect(TurkishProvinces.all, hasLength(81));
    for (var i = 0; i < 81; i++) {
      expect(TurkishProvinces.all[i].plateCode, i + 1);
    }
    expect(TurkishProvinces.districtCount, 973);
    expect(TurkishProvinces.all.where((p) => p.isMetropolitan), hasLength(30));
    expect(
      TurkishProvinces.all.where((p) => p.districts.contains('Merkez')),
      hasLength(51),
    );
  });

  test('well-known plate codes', () {
    const known = <int, String>{
      1: 'Adana', 6: 'Ankara', 7: 'Antalya', 16: 'Bursa', 30: 'Hakkari',
      33: 'Mersin', //
      34: 'İstanbul', 35: 'İzmir', 46: 'Kahramanmaraş', 63: 'Şanlıurfa',
      76: 'Iğdır', 81: 'Düzce',
    };
    known.forEach(
      (plate, name) => expect(TurkishProvinces.byPlateCode(plate)!.name, name),
    );
    expect(TurkishProvinces.byPlateCode(0), isNull);
    expect(TurkishProvinces.byPlateCode(82), isNull);
    expect(TurkishProvinces.byPlateCode(6)!.plateCodeText, '06');
    expect(TurkishProvinces.byPlateCode(34).toString(), '34 İstanbul');
  });

  test('district counts of large provinces', () {
    expect(TurkishProvinces.byName('İstanbul')!.districts, hasLength(39));
    expect(TurkishProvinces.byName('Ankara')!.districts, hasLength(25));
    expect(TurkishProvinces.byName('İzmir')!.districts, hasLength(30));
  });

  test('districts are unique per province and sorted the Turkish way', () {
    for (final province in TurkishProvinces.all) {
      expect(
        province.districts.toSet(),
        hasLength(province.districts.length),
        reason: province.name,
      );
      final sorted = [...province.districts]..sort(TurkishText.compare);
      expect(province.districts, sorted, reason: province.name);
      expect(() => province.districts.add('x'), throwsUnsupportedError);
    }
  });

  test('lookup by name ignores case and accents', () {
    expect(TurkishProvinces.byName('istanbul')!.plateCode, 34);
    expect(TurkishProvinces.byName('ISTANBUL')!.plateCode, 34);
    expect(TurkishProvinces.byName(' sanliurfa ')!.plateCode, 63);
    expect(TurkishProvinces.byName('Hakkâri')!.plateCode, 30);
    expect(TurkishProvinces.byName('Atlantis'), isNull);
  });

  test('search puts prefix matches first', () {
    final result = TurkishProvinces.search('kar').map((p) => p.name).toList();
    expect(result.first, 'Kars'); // prefix matches, in plate order
    expect(
      result,
      containsAll(<String>[
        'Karabük',
        'Karaman',
        'Kars',
        'Afyonkarahisar',
        'Ankara',
      ]),
    );
    expect(TurkishProvinces.search(''), hasLength(81));
    expect(TurkishProvinces.search('zzz'), isEmpty);
  });

  test('districts', () {
    final istanbul = TurkishProvinces.byPlateCode(34)!;
    expect(istanbul.isMetropolitan, isTrue);
    expect(istanbul.hasDistrict('kagithane'), isTrue);
    expect(istanbul.hasDistrict('Kâğıthane'), isTrue);
    expect(istanbul.hasDistrict('Çankaya'), isFalse);
    expect(
      TurkishProvinces.byName('Ankara')!.districts,
      contains('Kahramankazan'),
    );
    expect(TurkishProvinces.byName('Samsun')!.districts, contains('19 Mayıs'));
    expect(TurkishProvinces.byName('Bolu')!.isMetropolitan, isFalse);
    final eregli = TurkishProvinces.provincesWithDistrict(
      'ereğli',
    ).map((p) => p.name);
    expect(eregli, containsAll(<String>['Konya', 'Zonguldak']));
    expect(TurkishProvinces.provincesWithDistrict('Merkez'), hasLength(51));
  });
}
