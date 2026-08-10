import 'package:flutter/material.dart';

/// Single source of truth for the 5 floating bottom nav destinations, plus
/// the shared bottom-padding every tab body needs so its scrollable content
/// clears the floating nav bar.
class NavDestination {
  const NavDestination({
    required this.key,
    required this.icon,
    required this.labelKey,
  });

  final Key key;
  final IconData icon;

  /// easy_localization key for the label under the icon.
  final String labelKey;
}

const List<NavDestination> navDestinations = [
  NavDestination(
    key: Key('nav_home'),
    icon: Icons.home_rounded,
    labelKey: 'home',
  ),
  NavDestination(
    key: Key('nav_invoices'),
    icon: Icons.receipt_long_rounded,
    labelKey: 'invoices',
  ),
  NavDestination(
    key: Key('nav_create'),
    icon: Icons.add_rounded,
    labelKey: 'create',
  ),
  NavDestination(
    key: Key('nav_quotations'),
    icon: Icons.description_rounded,
    labelKey: 'quotations',
  ),
  NavDestination(
    key: Key('nav_account'),
    icon: Icons.person_rounded,
    labelKey: 'account',
  ),
];

/// Bottom padding every tab body should reserve so its content can scroll
/// clear of the floating bottom nav (bar height + its margins + breathing
/// room).
const double kFloatingNavClearance = 108;
