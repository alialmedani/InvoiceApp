import 'package:invoice/features/shared/models/document_models.dart';

enum InvoiceStatus { draft, pending, paid, overdue, cancelled }

class InvoiceModel with DocumentTotals {
  final String id;
  final String number;
  final DateTime issueDate;
  final DateTime dueDate;
  final InvoiceStatus status;
  final PartyInfo company;
  final PartyInfo customer;
  @override
  final List<DocumentItem> items;
  @override
  final double discountPercent;
  @override
  final double taxPercent;
  final String? notes;
  final PaymentInfo? paymentInfo;
  final DateTime? paidDate;

  const InvoiceModel({
    required this.id,
    required this.number,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    required this.company,
    required this.customer,
    required this.items,
    this.discountPercent = 0,
    this.taxPercent = 0,
    this.notes,
    this.paymentInfo,
    this.paidDate,
  });

  int get overdueDays => status == InvoiceStatus.overdue
      ? DateTime.now().difference(dueDate).inDays
      : 0;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
    id: json['id'] ?? '',
    number: json['number'] ?? '',
    issueDate: DateTime.parse(json['issueDate']),
    dueDate: DateTime.parse(json['dueDate']),
    status: InvoiceStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => InvoiceStatus.draft,
    ),
    company: PartyInfo.fromJson(json['company'] ?? {}),
    customer: PartyInfo.fromJson(json['customer'] ?? {}),
    items: ((json['items'] ?? []) as List)
        .map((e) => DocumentItem.fromJson(e))
        .toList(),
    discountPercent: (json['discountPercent'] ?? 0).toDouble(),
    taxPercent: (json['taxPercent'] ?? 0).toDouble(),
    notes: json['notes'],
    paymentInfo: json['paymentInfo'] == null
        ? null
        : PaymentInfo.fromJson(json['paymentInfo']),
    paidDate: json['paidDate'] == null
        ? null
        : DateTime.parse(json['paidDate']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'issueDate': issueDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'status': status.name,
    'company': company.toJson(),
    'customer': customer.toJson(),
    'items': items.map((e) => e.toJson()).toList(),
    'discountPercent': discountPercent,
    'taxPercent': taxPercent,
    'notes': notes,
    'paymentInfo': paymentInfo?.toJson(),
    'paidDate': paidDate?.toIso8601String(),
  };
}
