import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/services/auth_service.dart';

class _MemoryCredentialStore implements CredentialStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async {
    this.value = value;
  }

  @override
  Future<void> delete() async {
    value = null;
  }
}

void main() {
  test('creates a local profile and verifies credentials securely', () async {
    final credentials = _MemoryCredentialStore();
    final auth = AuthService(credentialStore: credentials);
    final profile = await auth.createProfile(
      name: 'Ravi Kumar',
      email: 'RAVI@example.com',
      password: 'a-strong-password',
    );

    expect(profile.email, 'ravi@example.com');
    final savedRecord = jsonDecode(credentials.value!) as Map<String, dynamic>;
    expect(savedRecord['email'], 'ravi@example.com');
    expect(savedRecord['verifier'], isNot('a-strong-password'));
    expect(savedRecord['salt'], isNotEmpty);

    final restored = await auth.savedProfile();
    expect(restored?.name, 'Ravi Kumar');
    expect(
      (await auth.login(
        email: 'Ravi@Example.com',
        password: 'a-strong-password',
      )).email,
      'ravi@example.com',
    );
    await expectLater(
      auth.login(email: 'ravi@example.com', password: 'wrong-password'),
      throwsA(isA<AuthException>()),
    );
  });
}
