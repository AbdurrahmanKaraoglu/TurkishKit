/// Turkish-aware text helpers: casing, search normalization and sorting.
///
/// Dart's `toUpperCase` / `toLowerCase` ignore the Turkish dotted and dotless
/// i: `'istanbul'.toUpperCase()` gives `ISTANBUL` instead of `İSTANBUL`, and
/// `'IĞDIR'.toLowerCase()` gives `iğdir` instead of `ığdır`. These helpers
/// fix that. See also the [TurkishStringExtension] for the same as extension
/// methods.
abstract final class TurkishText {
  /// Upper-cases [text] with Turkish rules (`i` → `İ`, `ı` → `I`).
  static String toUpperCase(String text) =>
      text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

  /// Lower-cases [text] with Turkish rules (`İ` → `i`, `I` → `ı`).
  static String toLowerCase(String text) => text
      .replaceAll('İ', 'i')
      .replaceAll('I', 'ı')
      .replaceAll('i̇', 'i')
      .toLowerCase();

  /// Upper-cases the first character of [word] and lower-cases the rest,
  /// with Turkish rules: `'istanbul'` → `'İstanbul'`, `'IĞDIR'` → `'Iğdır'`.
  static String capitalize(String word) {
    if (word.isEmpty) return word;
    final first = String.fromCharCode(word.runes.first);
    return toUpperCase(first) + toLowerCase(word.substring(first.length));
  }

  /// Capitalizes every word of [text] (words are separated by whitespace,
  /// and also by `-` and `/`): `'ışık ılık süt iç'` → `'Işık Ilık Süt İç'`.
  ///
  /// Letters after an apostrophe stay lower case: `İstanbul'da`.
  static String toTitleCase(String text) => text.replaceAllMapped(
        RegExp(r'[^\s\-/]+'),
        (match) => capitalize(match[0]!),
      );

  /// Normalizes [text] for accent- and case-insensitive search.
  ///
  /// Lower-cases with Turkish rules, maps `ç ğ ı ö ş ü` (and `â î û`, and
  /// other Latin letters with diacritics) to their plain forms, removes
  /// combining marks and collapses whitespace. `'  IĞDIR  Kâhta '` and
  /// `'igdir kahta'` both become `'igdir kahta'`.
  ///
  /// Apply it to both the query and the data, then compare or use
  /// `contains`. [searchContains] does that for you.
  static String normalizeForSearch(String text) {
    final lower = toLowerCase(text);
    final buffer = StringBuffer();
    var pendingSpace = false;
    for (final rune in lower.runes) {
      if (rune >= 0x0300 && rune <= 0x036F) continue; // combining marks
      if (rune == 0x20 ||
          rune == 0x09 ||
          rune == 0x0A ||
          rune == 0x0D ||
          rune == 0xA0 ||
          rune == 0x202F) {
        pendingSpace = buffer.isNotEmpty;
        continue;
      }
      if (pendingSpace) {
        buffer.write(' ');
        pendingSpace = false;
      }
      final folded = _fold[rune];
      if (folded != null) {
        buffer.write(folded);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// Whether [text] contains [query], ignoring case and accents
  /// (see [normalizeForSearch]). An empty query matches everything.
  static bool searchContains(String text, String query) =>
      normalizeForSearch(text).contains(normalizeForSearch(query));

  /// Compares [a] and [b] in Turkish alphabetical order:
  /// a b c ç d e f g ğ h ı i j k l m n o ö p (q) r s ş t u ü v (w x) y z.
  ///
  /// Case and circumflexes are ignored first (`Çorum` sorts with `çorum`,
  /// `Kâhta` with `Kahta`); only if two strings are otherwise equal does
  /// lower case come before upper case and a plain letter before `â`.
  /// Digits sort before letters, punctuation and spaces before digits.
  ///
  /// Use it as a sort comparator: `names.sort(TurkishText.compare)`.
  static int compare(String a, String b) {
    if (identical(a, b)) return 0;
    final ka = _primaryKey(a);
    final kb = _primaryKey(b);
    final length = ka.length < kb.length ? ka.length : kb.length;
    for (var i = 0; i < length; i++) {
      if (ka[i] != kb[i]) return ka[i] - kb[i];
    }
    if (ka.length != kb.length) return ka.length - kb.length;
    // Tie-break: lower case before upper case, plain before circumflex.
    final ra = a.runes.toList();
    final rb = b.runes.toList();
    final n = ra.length < rb.length ? ra.length : rb.length;
    for (var i = 0; i < n; i++) {
      final ta = _tertiary(ra[i]);
      final tb = _tertiary(rb[i]);
      if (ta != tb) return ta - tb;
    }
    return a.compareTo(b);
  }

  /// Sorts [list] in place in Turkish alphabetical order ([compare]).
  static void sort(List<String> list) => list.sort(compare);
}

/// Turkish-aware versions of common [String] operations.
extension TurkishStringExtension on String {
  /// [TurkishText.toUpperCase] of this string.
  String toTurkishUpperCase() => TurkishText.toUpperCase(this);

  /// [TurkishText.toLowerCase] of this string.
  String toTurkishLowerCase() => TurkishText.toLowerCase(this);

  /// [TurkishText.capitalize] of this string.
  String toTurkishCapitalized() => TurkishText.capitalize(this);

  /// [TurkishText.toTitleCase] of this string.
  String toTurkishTitleCase() => TurkishText.toTitleCase(this);

  /// [TurkishText.normalizeForSearch] of this string.
  String toSearchKey() => TurkishText.normalizeForSearch(this);

  /// Whether this string contains [query], ignoring case and accents.
  bool turkishContains(String query) => TurkishText.searchContains(this, query);

  /// [TurkishText.compare] of this string and [other].
  int turkishCompareTo(String other) => TurkishText.compare(this, other);
}

const String _alphabet = 'abcçdefgğhıijklmnoöpqrsştuüvwxyz';

final Map<int, int> _letterRank = <int, int>{
  for (var i = 0; i < _alphabet.length; i++) _alphabet.codeUnitAt(i): i,
};

/// Letters folded to their base letter for sorting (circumflexes only, so
/// that Turkish letters keep their own place in the alphabet).
const Map<int, int> _sortFold = <int, int>{
  0xE2: 0x61, // â → a
  0xEE: 0x69, // î → i
  0xFB: 0x75, // û → u
};

List<int> _primaryKey(String text) {
  final key = <int>[];
  for (final rune in TurkishText.toLowerCase(text).runes) {
    if (rune >= 0x0300 && rune <= 0x036F) continue;
    final base = _sortFold[rune] ?? rune;
    final rank = _letterRank[base];
    if (rank != null) {
      key.add(1000 + rank);
    } else if (base >= 0x30 && base <= 0x39) {
      key.add(500 + base - 0x30);
    } else if (base < 0x80) {
      key.add(base); // spaces and punctuation first
    } else {
      key.add(2000 + base); // other scripts after z
    }
  }
  return key;
}

int _tertiary(int rune) {
  if (_sortFold.containsKey(rune)) return 2;
  if (rune == 0xC2 || rune == 0xCE || rune == 0xDB) return 3; // Â Î Û
  final lower = TurkishText.toLowerCase(String.fromCharCode(rune));
  return lower == String.fromCharCode(rune) ? 0 : 1;
}

/// Accent folding for [TurkishText.normalizeForSearch] (input is lower case).
const Map<int, String> _fold = <int, String>{
  0xE7: 'c', // ç
  0x11F: 'g', // ğ
  0x131: 'i', // ı
  0xF6: 'o', // ö
  0x15F: 's', // ş
  0xFC: 'u', // ü
  0xE2: 'a', // â
  0xEE: 'i', // î
  0xFB: 'u', // û
  0xE0: 'a', 0xE1: 'a', 0xE3: 'a', 0xE4: 'a', 0xE5: 'a', //
  0xE8: 'e', 0xE9: 'e', 0xEA: 'e', 0xEB: 'e', //
  0xEC: 'i', 0xED: 'i', 0xEF: 'i', //
  0xF2: 'o', 0xF3: 'o', 0xF4: 'o', 0xF5: 'o', //
  0xF9: 'u', 0xFA: 'u', //
  0xF1: 'n', 0xFD: 'y', 0xFF: 'y', 0x15B: 's', 0x107: 'c', //
};
