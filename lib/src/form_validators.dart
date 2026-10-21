import 'validators.dart';

/// A form field validator: returns an error message, or `null` when the
/// value is valid.
///
/// This is exactly the signature of Flutter's `FormFieldValidator<String>`,
/// so the functions of [TurkishFormValidators] can be passed directly to
/// `TextFormField(validator: ...)` without this package depending on Flutter.
typedef TurkishFieldValidator = String? Function(String? value);

/// Error messages used by [TurkishFormValidators].
///
/// Use [TurkishValidationMessages.tr] or [TurkishValidationMessages.en], or
/// create your own (for example from your app's localizations).
class TurkishValidationMessages {
  /// Creates a set of messages.
  const TurkishValidationMessages({
    required this.required,
    required this.tcKimlik,
    required this.vergiKimlik,
    required this.taxNumber,
    required this.iban,
    required this.phone,
    required this.mobilePhone,
    required this.landlinePhone,
  });

  /// Turkish messages (the default).
  static const TurkishValidationMessages tr = TurkishValidationMessages(
    required: 'Bu alan zorunludur.',
    tcKimlik: 'Geçerli bir T.C. kimlik numarası girin.',
    vergiKimlik: 'Geçerli bir vergi kimlik numarası girin.',
    taxNumber: 'Geçerli bir vergi veya T.C. kimlik numarası girin.',
    iban: 'Geçerli bir TR IBAN girin.',
    phone: 'Geçerli bir telefon numarası girin.',
    mobilePhone: 'Geçerli bir cep telefonu numarası girin.',
    landlinePhone: 'Geçerli bir sabit telefon numarası girin.',
  );

  /// English messages.
  static const TurkishValidationMessages en = TurkishValidationMessages(
    required: 'This field is required.',
    tcKimlik: 'Enter a valid Turkish ID number.',
    vergiKimlik: 'Enter a valid tax ID number.',
    taxNumber: 'Enter a valid tax or Turkish ID number.',
    iban: 'Enter a valid Turkish IBAN.',
    phone: 'Enter a valid phone number.',
    mobilePhone: 'Enter a valid mobile phone number.',
    landlinePhone: 'Enter a valid landline phone number.',
  );

  /// Shown when a required field is empty.
  final String required;

  /// Shown for an invalid T.C. kimlik numarası.
  final String tcKimlik;

  /// Shown for an invalid vergi kimlik numarası.
  final String vergiKimlik;

  /// Shown for an invalid tax number (VKN or T.C. kimlik).
  final String taxNumber;

  /// Shown for an invalid IBAN.
  final String iban;

  /// Shown for an invalid phone number.
  final String phone;

  /// Shown for an invalid mobile phone number.
  final String mobilePhone;

  /// Shown for an invalid landline phone number.
  final String landlinePhone;
}

/// Ready-made form field validators built on [TurkishValidators].
///
/// ```dart
/// TextFormField(validator: TurkishFormValidators.tcKimlik());
/// ```
///
/// When [required] is false, an empty value is accepted; otherwise it gets
/// [TurkishValidationMessages.required]. Pass [message] to override a single
/// error text, or [messages] for a whole language.
abstract final class TurkishFormValidators {
  /// Validates a T.C. kimlik numarası.
  static TurkishFieldValidator tcKimlik({
    bool required = true,
    String? message,
    TurkishValidationMessages messages = TurkishValidationMessages.tr,
  }) =>
      _build(TurkishValidators.isValidTcKimlik, required, messages,
          message ?? messages.tcKimlik);

  /// Validates a vergi kimlik numarası (10 digits).
  static TurkishFieldValidator vergiKimlik({
    bool required = true,
    String? message,
    TurkishValidationMessages messages = TurkishValidationMessages.tr,
  }) =>
      _build(TurkishValidators.isValidVergiKimlik, required, messages,
          message ?? messages.vergiKimlik);

  /// Validates a tax number: VKN (10 digits) or T.C. kimlik (11 digits).
  static TurkishFieldValidator taxNumber({
    bool required = true,
    String? message,
    TurkishValidationMessages messages = TurkishValidationMessages.tr,
  }) =>
      _build(TurkishValidators.isValidTaxNumber, required, messages,
          message ?? messages.taxNumber);

  /// Validates a Turkish IBAN.
  static TurkishFieldValidator iban({
    bool required = true,
    String? message,
    TurkishValidationMessages messages = TurkishValidationMessages.tr,
  }) =>
      _build(TurkishValidators.isValidIban, required, messages,
          message ?? messages.iban);

  /// Validates any Turkish phone number.
  static TurkishFieldValidator phone({
    bool required = true,
    String? message,
    TurkishValidationMessages messages = TurkishValidationMessages.tr,
  }) =>
      _build(TurkishValidators.isValidPhone, required, messages,
          message ?? messages.phone);

  /// Validates a Turkish mobile phone number.
  static TurkishFieldValidator mobilePhone({
    bool required = true,
    String? message,
    TurkishValidationMessages messages = TurkishValidationMessages.tr,
  }) =>
      _build(TurkishValidators.isValidMobilePhone, required, messages,
          message ?? messages.mobilePhone);

  /// Validates a Turkish landline phone number.
  static TurkishFieldValidator landlinePhone({
    bool required = true,
    String? message,
    TurkishValidationMessages messages = TurkishValidationMessages.tr,
  }) =>
      _build(TurkishValidators.isValidLandlinePhone, required, messages,
          message ?? messages.landlinePhone);

  /// Runs [validators] in order and returns the first error.
  static TurkishFieldValidator combine(
          List<TurkishFieldValidator> validators) =>
      (value) {
        for (final validator in validators) {
          final error = validator(value);
          if (error != null) return error;
        }
        return null;
      };

  static TurkishFieldValidator _build(
    bool Function(String?) isValid,
    bool required,
    TurkishValidationMessages messages,
    String error,
  ) =>
      (value) {
        if (value == null || value.trim().isEmpty) {
          return required ? messages.required : null;
        }
        return isValid(value) ? null : error;
      };
}
