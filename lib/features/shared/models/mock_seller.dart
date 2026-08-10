import 'package:invoice/features/shared/models/document_models.dart';

/// The issuing company used across all mock documents.
const sellerCompany = PartyInfo(
  name: 'Jasim Technologies Ltd.',
  addressLine: '14 Ramadan St., Al-Mansour',
  city: 'Baghdad, Iraq',
  phone: '+964 770 123 4567',
  email: 'billing@jasimtech.iq',
  taxNumber: '1002453718',
);

/// The seller's standard bank details, prefilled on new invoices.
const sellerPaymentInfo = PaymentInfo(
  bankName: 'Trade Bank of Iraq',
  accountName: 'Jasim Technologies Ltd.',
  iban: 'IQ98 TRIQ 0010 2345 6789 012',
);

/// Known customers, used for quick-pick when creating a new document.
const mockCustomers = [
  PartyInfo(
    name: 'Al-Rasheed Pharmacy Group',
    addressLine: '62 Karrada Dakhil St.',
    city: 'Baghdad, Iraq',
    phone: '+964 771 884 2210',
    email: 'accounts@alrasheed-pharma.iq',
    taxNumber: '1004917320',
  ),
  PartyInfo(
    name: 'Tigris Logistics LLC',
    addressLine: 'Warehouse 7, Um Qasr Port Rd.',
    city: 'Basra, Iraq',
    phone: '+964 780 445 9034',
    email: 'finance@tigrislogistics.iq',
    taxNumber: '1003662184',
  ),
  PartyInfo(
    name: 'Babylon Grand Mall',
    addressLine: '40th St., Facility Management Office',
    city: 'Hillah, Iraq',
    phone: '+964 782 331 7755',
    email: 'fm@babylongrandmall.iq',
  ),
  PartyInfo(
    name: 'Zagros Engineering Co.',
    addressLine: 'Italian Village, Office 214',
    city: 'Erbil, Iraq',
    phone: '+964 750 220 8811',
    email: 'procurement@zagroseng.krd',
    taxNumber: '1005520447',
  ),
  PartyInfo(
    name: 'Al-Salam Private Hospital',
    addressLine: 'Al-Zuhour District, Gate 2',
    city: 'Mosul, Iraq',
    phone: '+964 773 918 6642',
    email: 'admin@alsalam-hospital.iq',
  ),
];
