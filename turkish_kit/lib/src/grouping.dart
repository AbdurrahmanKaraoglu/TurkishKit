/// Groups [digits] (only ASCII digits, no sign) in threes from the right with
/// [separator]: `'1234567'` → `'1.234.567'`.
///
/// The single place where Turkish thousands grouping is defined; used by
/// TurkishNumberFormat, TurkishMoney and TurkishMoneyInputMask.
String groupThousands(String digits, [String separator = '.']) {
  final buffer = StringBuffer();
  final head = digits.length % 3;
  if (head > 0) buffer.write(digits.substring(0, head));
  for (var i = head; i < digits.length; i += 3) {
    if (buffer.isNotEmpty) buffer.write(separator);
    buffer.write(digits.substring(i, i + 3));
  }
  return buffer.toString();
}
