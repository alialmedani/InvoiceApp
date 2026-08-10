/// Value objects shared by quotations and invoices.
/// JSON methods are included so these plug straight into the existing
/// remote-data-source architecture when the API layer is added.
class PartyInfo {
  final String name;
  final String addressLine;
  final String city;
  final String phone;
  final String email;
  final String? taxNumber;

  const PartyInfo({
    required this.name,
    required this.addressLine,
    required this.city,
    required this.phone,
    required this.email,
    this.taxNumber,
  });

  factory PartyInfo.fromJson(Map<String, dynamic> json) => PartyInfo(
    name: json['name'] ?? '',
    addressLine: json['addressLine'] ?? '',
    city: json['city'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
    taxNumber: json['taxNumber'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'addressLine': addressLine,
    'city': city,
    'phone': phone,
    'email': email,
    'taxNumber': taxNumber,
  };
}

class DocumentItem {
  final String name;
  final String? description;
  final double quantity;
  final String? unit;
  final double unitPrice;

  /// Line-level discount, as a percentage (0..100).
  final double discountPercent;

  const DocumentItem({
    required this.name,
    this.description,
    required this.quantity,
    this.unit,
    required this.unitPrice,
    this.discountPercent = 0,
  });

  double get grossAmount => quantity * unitPrice;
  double get discountAmount => grossAmount * discountPercent / 100;
  double get netAmount => grossAmount - discountAmount;

  factory DocumentItem.fromJson(Map<String, dynamic> json) => DocumentItem(
    name: json['name'] ?? '',
    description: json['description'],
    quantity: (json['quantity'] ?? 0).toDouble(),
    unit: json['unit'],
    unitPrice: (json['unitPrice'] ?? 0).toDouble(),
    discountPercent: (json['discountPercent'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'quantity': quantity,
    'unit': unit,
    'unitPrice': unitPrice,
    'discountPercent': discountPercent,
  };
}

class PaymentInfo {
  final String bankName;
  final String accountName;
  final String iban;

  const PaymentInfo({
    required this.bankName,
    required this.accountName,
    required this.iban,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) => PaymentInfo(
    bankName: json['bankName'] ?? '',
    accountName: json['accountName'] ?? '',
    iban: json['iban'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'bankName': bankName,
    'accountName': accountName,
    'iban': iban,
  };
}

/// Shared money math for any document that carries items, a document-level
/// discount and a tax percentage.
mixin DocumentTotals {
  List<DocumentItem> get items;

  /// Document-level discount applied after line discounts, as a percentage.
  double get discountPercent;

  /// Tax applied on the discounted base, as a percentage.
  double get taxPercent;

  double get subtotal => items.fold(0, (sum, i) => sum + i.grossAmount);

  double get lineDiscountTotal =>
      items.fold(0, (sum, i) => sum + i.discountAmount);

  double get documentDiscountAmount =>
      (subtotal - lineDiscountTotal) * discountPercent / 100;

  double get discountTotal => lineDiscountTotal + documentDiscountAmount;

  double get taxableBase => subtotal - discountTotal;

  double get taxAmount => taxableBase * taxPercent / 100;

  double get total => taxableBase + taxAmount;
}
