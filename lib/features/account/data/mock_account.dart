/// Static signed-in user shown on the Account tab. There is no auth in this
/// app — this is display-only mock data, same convention as `mock_seller.dart`.
class MockAccountUser {
  const MockAccountUser({
    required this.name,
    required this.role,
    required this.initials,
  });

  final String name;
  final String role;
  final String initials;
}

const mockAccountUser = MockAccountUser(
  name: 'Ahmed Al-Jasim',
  role: 'Finance Manager',
  initials: 'AJ',
);
