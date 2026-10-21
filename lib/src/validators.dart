/// The kind of a Turkish phone number, see [TurkishValidators.phoneType].
enum TurkishPhoneType {
  /// A GSM number: the national number starts with 5 (for example 532).
  mobile,

  /// A geographic fixed-line number: the area code starts with 2, 3 or 4
  /// (for example 212 for Istanbul Europe, 312 for Ankara).
  landline,

  /// A non-geographic number: 800 (toll free), 850 (nationwide) or
  /// 900 (premium rate).
  nonGeographic,
}

const Set<String> _nonGeographicPrefixes = <String>{'800', '850', '900'};

/// Pure functions that validate and normalize Turkish identifiers.
///
/// Every function accepts user input as typed: surrounding whitespace and,
/// where it makes sense, spaces, dashes, dots and parentheses are ignored.
abstract final class TurkishValidators {
  /// Whether [value] is a valid T.C. kimlik numarası (Turkish national ID).
  ///
  /// The number has 11 digits, does not start with 0, and its last two digits
  /// are check digits:
  /// * 10th digit = ((d1 + d3 + d5 + d7 + d9) * 7 - (d2 + d4 + d6 + d8)) mod 10
  /// * 11th digit = (d1 + d2 + ... + d10) mod 10
  ///
  /// Only the checksum is verified; this does not prove the number belongs
  /// to a real person (that needs the government MERNİS service).
  static bool isValidTcKimlik(String? value) {
    final digits = _digitsOnly(value, allowSeparators: true);
    if (digits == null || digits.length != 11 || digits.codeUnitAt(0) == 0x30) {
      return false;
    }
    final d = _toDigits(digits);
    final odd = d[0] + d[2] + d[4] + d[6] + d[8];
    final even = d[1] + d[3] + d[5] + d[7];
    // Dart's % is always non-negative for a positive divisor.
    if ((odd * 7 - even) % 10 != d[9]) return false;
    var sum = 0;
    for (var i = 0; i < 10; i++) {
      sum += d[i];
    }
    return sum % 10 == d[10];
  }

  /// Whether [value] is a valid vergi kimlik numarası (VKN, 10-digit tax
  /// number of companies and other legal entities), using the check-digit
  /// algorithm of the Turkish Revenue Administration (GİB).
  ///
  /// Individuals use their 11-digit T.C. kimlik numarası as tax number;
  /// [isValidTaxNumber] accepts either.
  static bool isValidVergiKimlik(String? value) {
    final digits = _digitsOnly(value, allowSeparators: true);
    if (digits == null || digits.length != 10) return false;
    final d = _toDigits(digits);
    var sum = 0;
    for (var i = 0; i < 9; i++) {
      final shifted = (d[i] + 9 - i) % 10;
      var weighted = (shifted * (1 << (9 - i))) % 9;
      if (shifted != 0 && weighted == 0) weighted = 9;
      sum += weighted;
    }
    return (10 - sum % 10) % 10 == d[9];
  }

  /// Whether [value] is a valid tax number: a 10-digit VKN
  /// ([isValidVergiKimlik]) or an 11-digit T.C. kimlik numarası
  /// ([isValidTcKimlik]), as accepted on Turkish e-invoices.
  static bool isValidTaxNumber(String? value) =>
      isValidVergiKimlik(value) || isValidTcKimlik(value);

  /// Removes whitespace and upper-cases [value], for example
  /// `'tr33 0006 1005'` becomes `'TR3300061005'`.
  static String normalizeIban(String value) =>
      value.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  /// Whether [value] is a valid Turkish IBAN.
  ///
  /// A Turkish IBAN is `TR`, 2 check digits and 22 digits (5-digit bank code,
  /// 1 reserved digit, 16-digit account number): 26 characters. Spaces and
  /// lower-case letters are accepted. The check digits are verified with the
  /// ISO 13616 mod-97 algorithm.
  static bool isValidIban(String? value) {
    if (value == null) return false;
    final iban = normalizeIban(value);
    if (!RegExp(r'^TR\d{24}$').hasMatch(iban)) return false;
    return _mod97(iban) == 1;
  }

  /// Formats a Turkish IBAN in groups of four characters
  /// (`TR33 0006 1005 1978 6457 8413 26`), or returns `null` if [value] is
  /// not a valid Turkish IBAN.
  static String? formatIban(String? value) {
    if (!isValidIban(value)) return null;
    final iban = normalizeIban(value!);
    final buffer = StringBuffer();
    for (var i = 0; i < iban.length; i += 4) {
      if (i > 0) buffer.write(' ');
      buffer
          .write(iban.substring(i, i + 4 > iban.length ? iban.length : i + 4));
    }
    return buffer.toString();
  }

  /// The 5-digit bank code of a valid Turkish IBAN (for example `'00061'`),
  /// or `null` if [value] is not valid.
  static String? ibanBankCode(String? value) =>
      isValidIban(value) ? normalizeIban(value!).substring(4, 9) : null;

  /// The 10-digit national phone number (without the leading 0 or +90), or
  /// `null` if [value] is not a valid Turkish phone number.
  ///
  /// Accepts `0532 123 45 67`, `532-123-4567`, `(0532) 123 45 67`,
  /// `+90 532 123 45 67`, `0090 532 123 45 67` and `905321234567`.
  static String? nationalPhoneNumber(String? value) {
    if (value == null) return null;
    var text = value.trim();
    var international = false;
    if (text.startsWith('+')) {
      international = true;
      text = text.substring(1);
    }
    final digits = _digitsOnly(text, allowSeparators: true);
    if (digits == null) return null;
    String national;
    if (international) {
      if (!digits.startsWith('90')) return null;
      national = digits.substring(2);
    } else if (digits.startsWith('0090')) {
      national = digits.substring(4);
    } else if (digits.length == 12 && digits.startsWith('90')) {
      national = digits.substring(2);
    } else if (digits.length == 11 && digits.startsWith('0')) {
      national = digits.substring(1);
    } else {
      national = digits;
    }
    if (national.length != 10) return null;
    return _phoneTypeOfNational(national) == null ? null : national;
  }

  /// The [TurkishPhoneType] of [value], or `null` if it is not a valid
  /// Turkish phone number.
  static TurkishPhoneType? phoneType(String? value) {
    final national = nationalPhoneNumber(value);
    return national == null ? null : _phoneTypeOfNational(national);
  }

  /// Whether [value] is a valid Turkish phone number (mobile, landline or
  /// non-geographic). See [nationalPhoneNumber] for accepted spellings.
  static bool isValidPhone(String? value) => nationalPhoneNumber(value) != null;

  /// Whether [value] is a valid Turkish mobile (GSM) number.
  static bool isValidMobilePhone(String? value) =>
      phoneType(value) == TurkishPhoneType.mobile;

  /// Whether [value] is a valid Turkish geographic landline number.
  static bool isValidLandlinePhone(String? value) =>
      phoneType(value) == TurkishPhoneType.landline;

  /// The phone number in E.164 form (`+905321234567`), or `null` if [value]
  /// is not a valid Turkish phone number. Use this form for storage and APIs.
  static String? normalizePhone(String? value) {
    final national = nationalPhoneNumber(value);
    return national == null ? null : '+90$national';
  }

  /// The phone number for display: `0532 123 45 67`, or
  /// `+90 532 123 45 67` when [international] is true. Returns `null` if
  /// [value] is not a valid Turkish phone number.
  static String? formatPhone(String? value, {bool international = false}) {
    final n = nationalPhoneNumber(value);
    if (n == null) return null;
    final body =
        '${n.substring(0, 3)} ${n.substring(3, 6)} ${n.substring(6, 8)} '
        '${n.substring(8)}';
    return international ? '+90 $body' : '0$body';
  }

  static TurkishPhoneType? _phoneTypeOfNational(String national) {
    switch (national.codeUnitAt(0)) {
      case 0x35: // 5
        return TurkishPhoneType.mobile;
      case 0x32: // 2
      case 0x33: // 3
      case 0x34: // 4
        return TurkishPhoneType.landline;
    }
    return _nonGeographicPrefixes.contains(national.substring(0, 3))
        ? TurkishPhoneType.nonGeographic
        : null;
  }
}

/// Returns the digits of [value], or `null` if it contains anything other
/// than digits (and, with [allowSeparators], spaces, dashes, dots and
/// parentheses).
String? _digitsOnly(String? value, {required bool allowSeparators}) {
  if (value == null) return null;
  final buffer = StringBuffer();
  for (final unit in value.trim().codeUnits) {
    if (unit >= 0x30 && unit <= 0x39) {
      buffer.writeCharCode(unit);
    } else if (allowSeparators &&
        (unit == 0x20 ||
            unit == 0x2D ||
            unit == 0x2E ||
            unit == 0x28 ||
            unit == 0x29)) {
      continue;
    } else {
      return null;
    }
  }
  final result = buffer.toString();
  return result.isEmpty ? null : result;
}

List<int> _toDigits(String digits) =>
    <int>[for (final unit in digits.codeUnits) unit - 0x30];

/// ISO 7064 mod 97-10 remainder of an IBAN (letters A-Z become 10-35).
int _mod97(String iban) {
  final rearranged = iban.substring(4) + iban.substring(0, 4);
  var remainder = 0;
  for (final unit in rearranged.codeUnits) {
    if (unit >= 0x30 && unit <= 0x39) {
      remainder = (remainder * 10 + unit - 0x30) % 97;
    } else {
      remainder = (remainder * 100 + unit - 0x41 + 10) % 97;
    }
  }
  return remainder;
}
