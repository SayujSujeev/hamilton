class BookingCartLine {
  const BookingCartLine({
    required this.title,
    this.subtitle,
    this.serviceTypeId,
  });

  final String title;
  final String? subtitle;
  /// Backend `service_type` UUID when known; otherwise matched from slot payload by title.
  final String? serviceTypeId;
}