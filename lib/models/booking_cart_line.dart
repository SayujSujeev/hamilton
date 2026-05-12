class BookingCartLine {
  const BookingCartLine({
    required this.title,
    required this.amount,
    this.subtitle,
    this.serviceTypeId,
  });

  final String title;
  final double amount;
  final String? subtitle;
  /// Backend `service_type` UUID when known; otherwise matched from slot payload by title.
  final String? serviceTypeId;
}