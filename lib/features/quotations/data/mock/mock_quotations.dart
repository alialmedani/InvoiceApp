import 'package:invoice/features/quotations/data/model/quotation_model.dart';
import 'package:invoice/features/shared/models/document_models.dart';
import 'package:invoice/features/shared/models/mock_seller.dart';

/// Static demo data. Stands in for the repository/remote data source until
/// the API layer is connected.
final List<QuotationModel> mockQuotations = [
  // Sent — full office network + ERP proposal.
  QuotationModel(
    id: 'quo-0087',
    number: 'QUO-2026-0087',
    issueDate: DateTime(2026, 8, 2),
    expiryDate: DateTime(2026, 9, 1),
    status: QuotationStatus.sent,
    company: sellerCompany,
    customer: const PartyInfo(
      name: 'Zagros Engineering Co.',
      addressLine: 'Italian Village, Office 214',
      city: 'Erbil, Iraq',
      phone: '+964 750 220 8811',
      email: 'procurement@zagroseng.krd',
      taxNumber: '1005520447',
    ),
    items: const [
      DocumentItem(
        name: 'ERP annual license — 10 users',
        description: 'Finance, inventory and HR modules',
        quantity: 1,
        unit: 'year',
        unitPrice: 3600000,
      ),
      DocumentItem(
        name: 'ERP implementation & data migration',
        quantity: 6,
        unit: 'day',
        unitPrice: 350000,
      ),
      DocumentItem(
        name: 'Dell OptiPlex 7020 SFF workstation',
        description: 'i5-14500 / 16 GB / 512 GB NVMe',
        quantity: 6,
        unit: 'pcs',
        unitPrice: 1150000,
        discountPercent: 8,
      ),
      DocumentItem(
        name: 'Dell P2424H 24" monitor',
        quantity: 6,
        unit: 'pcs',
        unitPrice: 285000,
      ),
      DocumentItem(
        name: 'Ubiquiti U6-Pro access point',
        quantity: 4,
        unit: 'pcs',
        unitPrice: 265000,
      ),
      DocumentItem(
        name: '24-port PoE gigabit switch',
        quantity: 2,
        unit: 'pcs',
        unitPrice: 780000,
      ),
      DocumentItem(
        name: 'Cat6 structured cabling',
        quantity: 32,
        unit: 'point',
        unitPrice: 45000,
        discountPercent: 15,
      ),
      DocumentItem(
        name: 'Staff training',
        description: 'ERP end-user and admin training',
        quantity: 3,
        unit: 'day',
        unitPrice: 300000,
      ),
      DocumentItem(
        name: 'On-site technical support',
        description: 'Post-go-live support window',
        quantity: 24,
        unit: 'hour',
        unitPrice: 25000,
      ),
    ],
    discountPercent: 7.5,
    taxPercent: 5,
    notes:
        'Delivery and installation within 3 weeks of purchase-order confirmation.',
    terms:
        '1. Prices are valid until the expiry date shown above.\n'
        '2. 50% advance payment on order confirmation, 50% on delivery.\n'
        '3. Hardware carries the manufacturer warranty; installation work is '
        'guaranteed for 12 months.\n'
        '4. Any scope change is quoted separately before execution.',
  ),

  // Accepted — clinic attendance + CCTV package.
  QuotationModel(
    id: 'quo-0082',
    number: 'QUO-2026-0082',
    issueDate: DateTime(2026, 7, 12),
    expiryDate: DateTime(2026, 8, 11),
    status: QuotationStatus.accepted,
    company: sellerCompany,
    customer: const PartyInfo(
      name: 'Al-Salam Private Hospital',
      addressLine: 'Al-Zuhour District, Gate 2',
      city: 'Mosul, Iraq',
      phone: '+964 773 918 6642',
      email: 'admin@alsalam-hospital.iq',
    ),
    items: const [
      DocumentItem(
        name: 'ZKTeco MB460 attendance device',
        quantity: 4,
        unit: 'pcs',
        unitPrice: 210000,
        discountPercent: 5,
      ),
      DocumentItem(
        name: 'Attendance software annual license',
        quantity: 1,
        unit: 'year',
        unitPrice: 480000,
      ),
      DocumentItem(
        name: 'CCTV package — 16-ch NVR + 8 cameras',
        quantity: 1,
        unit: 'set',
        unitPrice: 1450000,
      ),
      DocumentItem(
        name: 'Installation & commissioning',
        quantity: 1,
        unit: 'job',
        unitPrice: 400000,
      ),
      DocumentItem(
        name: 'Staff training session',
        quantity: 2,
        unit: 'session',
        unitPrice: 150000,
      ),
    ],
    taxPercent: 5,
    notes: 'Accepted on 28 Jul 2026 — pending purchase order for invoicing.',
    terms:
        '1. Prices are valid until the expiry date shown above.\n'
        '2. Full payment within 14 days of delivery.\n'
        '3. Installation work is guaranteed for 12 months.',
  ),

  // Expired — proposal that was never confirmed.
  QuotationModel(
    id: 'quo-0078',
    number: 'QUO-2026-0078',
    issueDate: DateTime(2026, 6, 8),
    expiryDate: DateTime(2026, 7, 8),
    status: QuotationStatus.expired,
    company: sellerCompany,
    customer: const PartyInfo(
      name: 'Babylon Grand Mall',
      addressLine: '40th St., Facility Management Office',
      city: 'Hillah, Iraq',
      phone: '+964 782 331 7755',
      email: 'fm@babylongrandmall.iq',
    ),
    items: const [
      DocumentItem(
        name: 'Digital signage display 55"',
        description: 'Commercial-grade, 24/7 rated, wall-mounted',
        quantity: 6,
        unit: 'pcs',
        unitPrice: 950000,
      ),
      DocumentItem(
        name: 'Signage content management license',
        quantity: 1,
        unit: 'year',
        unitPrice: 720000,
      ),
      DocumentItem(
        name: 'Installation & configuration',
        quantity: 1,
        unit: 'job',
        unitPrice: 380000,
      ),
    ],
    discountPercent: 5,
    taxPercent: 5,
    terms:
        '1. Prices are valid until the expiry date shown above.\n'
        '2. 50% advance payment on order confirmation, 50% on delivery.',
  ),

  // Draft — small support renewal, still being prepared.
  QuotationModel(
    id: 'quo-0089',
    number: 'QUO-2026-0089',
    issueDate: DateTime(2026, 8, 9),
    expiryDate: DateTime(2026, 9, 8),
    status: QuotationStatus.draft,
    company: sellerCompany,
    customer: const PartyInfo(
      name: 'Tigris Logistics LLC',
      addressLine: 'Warehouse 7, Um Qasr Port Rd.',
      city: 'Basra, Iraq',
      phone: '+964 780 445 9034',
      email: 'finance@tigrislogistics.iq',
      taxNumber: '1003662184',
    ),
    items: const [
      DocumentItem(
        name: 'Annual maintenance contract',
        description: 'Covers workstations, network and CCTV equipment',
        quantity: 34,
        unit: 'device',
        unitPrice: 15000,
      ),
      DocumentItem(
        name: 'Priority response SLA upgrade',
        description: '4-hour on-site response, business days',
        quantity: 1,
        unit: 'year',
        unitPrice: 900000,
      ),
    ],
    notes: 'Renewal proposal for the 2026–2027 support period.',
  ),
];
