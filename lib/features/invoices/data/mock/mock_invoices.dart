import 'package:invoice/features/invoices/data/model/invoice_model.dart';
import 'package:invoice/features/shared/models/document_models.dart';
import 'package:invoice/features/shared/models/mock_seller.dart';

/// Static demo data. Stands in for the repository/remote data source until
/// the API layer is connected.
final List<InvoiceModel> mockInvoices = [
  // Paid — short invoice with tax, payment fully settled.
  InvoiceModel(
    id: 'inv-0231',
    number: 'INV-2026-0231',
    issueDate: DateTime(2026, 7, 18),
    dueDate: DateTime(2026, 8, 1),
    paidDate: DateTime(2026, 7, 29),
    status: InvoiceStatus.paid,
    company: sellerCompany,
    customer: const PartyInfo(
      name: 'Al-Rasheed Pharmacy Group',
      addressLine: '62 Karrada Dakhil St.',
      city: 'Baghdad, Iraq',
      phone: '+964 771 884 2210',
      email: 'accounts@alrasheed-pharma.iq',
      taxNumber: '1004917320',
    ),
    items: const [
      DocumentItem(
        name: 'ZKTeco MB460 attendance device',
        description: 'Face + fingerprint, installed and configured',
        quantity: 2,
        unit: 'pcs',
        unitPrice: 210000,
      ),
      DocumentItem(
        name: 'Attendance software annual license',
        quantity: 1,
        unit: 'year',
        unitPrice: 480000,
      ),
      DocumentItem(
        name: 'Staff training session',
        description: 'On-site, up to 10 employees',
        quantity: 1,
        unit: 'session',
        unitPrice: 150000,
      ),
    ],
    taxPercent: 5,
    notes:
        'Payment received in full by bank transfer. Thank you for your business.',
    paymentInfo: const PaymentInfo(
      bankName: 'Trade Bank of Iraq',
      accountName: 'Jasim Technologies Ltd.',
      iban: 'IQ98 TRIQ 0010 2345 6789 012',
    ),
  ),

  // Pending — medium invoice with line discounts + document discount + tax.
  InvoiceModel(
    id: 'inv-0235',
    number: 'INV-2026-0235',
    issueDate: DateTime(2026, 8, 4),
    dueDate: DateTime(2026, 8, 18),
    status: InvoiceStatus.pending,
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
        name: 'Dell OptiPlex 7020 SFF workstation',
        description: 'i5-14500 / 16 GB / 512 GB NVMe, 3-year warranty',
        quantity: 4,
        unit: 'pcs',
        unitPrice: 1150000,
        discountPercent: 10,
      ),
      DocumentItem(
        name: 'Dell P2424H 24" monitor',
        quantity: 4,
        unit: 'pcs',
        unitPrice: 285000,
      ),
      DocumentItem(
        name: 'Windows 11 Pro OEM license',
        quantity: 4,
        unit: 'pcs',
        unitPrice: 240000,
      ),
      DocumentItem(
        name: '24-port PoE gigabit switch',
        description: 'Rack-mounted, configured with VLANs',
        quantity: 1,
        unit: 'pcs',
        unitPrice: 780000,
      ),
      DocumentItem(
        name: 'Cat6 structured cabling',
        quantity: 18,
        unit: 'point',
        unitPrice: 45000,
      ),
      DocumentItem(
        name: 'On-site technical support',
        description: 'Setup, migration and handover',
        quantity: 12,
        unit: 'hour',
        unitPrice: 25000,
      ),
    ],
    discountPercent: 5,
    taxPercent: 5,
    notes:
        'Hardware delivery within 5 business days of payment confirmation. '
        'Warranty claims are handled directly through our service center in Baghdad.',
    paymentInfo: const PaymentInfo(
      bankName: 'Trade Bank of Iraq',
      accountName: 'Jasim Technologies Ltd.',
      iban: 'IQ98 TRIQ 0010 2345 6789 012',
    ),
  ),

  // Overdue — short, high-value invoice.
  InvoiceModel(
    id: 'inv-0228',
    number: 'INV-2026-0228',
    issueDate: DateTime(2026, 6, 25),
    dueDate: DateTime(2026, 7, 25),
    status: InvoiceStatus.overdue,
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
        name: 'CCTV package — 16-ch NVR + 8 cameras',
        description: '4K IP cameras, 30-day retention storage',
        quantity: 3,
        unit: 'set',
        unitPrice: 1450000,
      ),
      DocumentItem(
        name: 'Installation & commissioning',
        description: 'Including cabling and mounting across 3 floors',
        quantity: 1,
        unit: 'job',
        unitPrice: 850000,
      ),
    ],
    taxPercent: 5,
    notes: 'Second payment reminder sent on 3 Aug 2026.',
    paymentInfo: const PaymentInfo(
      bankName: 'Trade Bank of Iraq',
      accountName: 'Jasim Technologies Ltd.',
      iban: 'IQ98 TRIQ 0010 2345 6789 012',
    ),
  ),

  // Draft — long invoice (14 lines) to exercise multi-page PDF later.
  InvoiceModel(
    id: 'inv-0238',
    number: 'INV-2026-0238',
    issueDate: DateTime(2026, 8, 9),
    dueDate: DateTime(2026, 9, 8),
    status: InvoiceStatus.draft,
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
        name: 'Windows 11 Pro OEM license',
        quantity: 6,
        unit: 'pcs',
        unitPrice: 240000,
      ),
      DocumentItem(
        name: 'Microsoft 365 Business Standard',
        quantity: 10,
        unit: 'seat',
        unitPrice: 195000,
      ),
      DocumentItem(
        name: 'APC Smart-UPS 1500VA',
        quantity: 2,
        unit: 'pcs',
        unitPrice: 620000,
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
        name: '12U wall-mount rack cabinet',
        description: 'With PDU and cable management',
        quantity: 1,
        unit: 'pcs',
        unitPrice: 310000,
      ),
      DocumentItem(
        name: 'Cat6 structured cabling',
        quantity: 32,
        unit: 'point',
        unitPrice: 45000,
        discountPercent: 15,
      ),
      DocumentItem(
        name: 'Fiber uplink between floors',
        quantity: 2,
        unit: 'run',
        unitPrice: 180000,
      ),
      DocumentItem(
        name: 'Network documentation & as-built drawings',
        quantity: 1,
        unit: 'set',
        unitPrice: 220000,
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
        'Draft pending final sign-off from Zagros procurement. Prices are locked '
        'for 30 days from the issue date.',
    paymentInfo: const PaymentInfo(
      bankName: 'Trade Bank of Iraq',
      accountName: 'Jasim Technologies Ltd.',
      iban: 'IQ98 TRIQ 0010 2345 6789 012',
    ),
  ),

  // Cancelled — order withdrawn by the customer.
  InvoiceModel(
    id: 'inv-0224',
    number: 'INV-2026-0224',
    issueDate: DateTime(2026, 6, 12),
    dueDate: DateTime(2026, 6, 26),
    status: InvoiceStatus.cancelled,
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
        name: 'Ubiquiti U6-Pro access point',
        quantity: 8,
        unit: 'pcs',
        unitPrice: 265000,
      ),
      DocumentItem(
        name: 'Cat6 structured cabling',
        quantity: 12,
        unit: 'point',
        unitPrice: 45000,
      ),
      DocumentItem(
        name: 'APC Smart-UPS 1500VA',
        quantity: 1,
        unit: 'pcs',
        unitPrice: 620000,
      ),
      DocumentItem(
        name: 'Annual maintenance contract',
        quantity: 21,
        unit: 'device',
        unitPrice: 15000,
      ),
    ],
    taxPercent: 5,
    notes: 'Cancelled at customer request on 20 Jun 2026 — project postponed.',
  ),
];
