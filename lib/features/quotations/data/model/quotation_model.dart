import 'package:invoice/features/shared/models/document_models.dart';

enum QuotationStatus { draft, sent, accepted, declined, expired }

class QuotationModel with DocumentTotals {
  final String id;
  final String number;
  final DateTime issueDate;
  final DateTime expiryDate;
  final QuotationStatus status;
  final PartyInfo company;
  final PartyInfo customer;
  @override
  final List<DocumentItem> items;
  @override
  final double discountPercent;
  @override
  final double taxPercent;
  final String? notes;
  final String? terms;

  const QuotationModel({
    required this.id,
    required this.number,
    required this.issueDate,
    required this.expiryDate,
    required this.status,
    required this.company,
    required this.customer,
    required this.items,
    this.discountPercent = 0,
    this.taxPercent = 0,
    this.notes,
    this.terms,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) => QuotationModel(
    id: json['id'] ?? '',
    number: json['number'] ?? '',
    issueDate: DateTime.parse(json['issueDate']),
    expiryDate: DateTime.parse(json['expiryDate']),
    status: QuotationStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => QuotationStatus.draft,
    ),
    company: PartyInfo.fromJson(json['company'] ?? {}),
    customer: PartyInfo.fromJson(json['customer'] ?? {}),
    items: ((json['items'] ?? []) as List)
        .map((e) => DocumentItem.fromJson(e))
        .toList(),
    discountPercent: (json['discountPercent'] ?? 0).toDouble(),
    taxPercent: (json['taxPercent'] ?? 0).toDouble(),
    notes: json['notes'],
    terms: json['terms'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'issueDate': issueDate.toIso8601String(),
    'expiryDate': expiryDate.toIso8601String(),
    'status': status.name,
    'company': company.toJson(),
    'customer': customer.toJson(),
    'items': items.map((e) => e.toJson()).toList(),
    'discountPercent': discountPercent,
    'taxPercent': taxPercent,
    'notes': notes,
    'terms': terms,
  };
}
