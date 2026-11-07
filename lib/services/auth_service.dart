import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_profile.dart';

abstract class CredentialStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

class SecureCredentialStore implements CredentialStore {
  SecureCredentialStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'jobnest_local_account_v1';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);

  @override
  Future<void> delete() => _storage.delete(key: _key);
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({CredentialStore? credentialStore})
    : _credentialStore = credentialStore ?? SecureCredentialStore();

  static const int _iterations = 120000;
  static const int _saltLength = 16;
  static const int _keyLength = 256;

  final CredentialStore _credentialStore;
  final Pbkdf2 _passwordHasher = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: _keyLength,
  );

  Future<UserProfile?> savedProfile() async {
    final record = await _readRecord();
    if (record == null) return null;
    return UserProfile(name: record.name, email: record.email);
  }

  Future<UserProfile> createProfile({
    required String name,
    required String email,
    required String password,
  }) async {
    if (await _readRecord() != null) {
      throw const AuthException(
        'An account already exists on this device. Please log in.',
      );
    }

    final normalizedEmail = email.trim().toLowerCase();
    final salt = List<int>.generate(
      _saltLength,
      (_) => Random.secure().nextInt(256),
    );
    final verifier = await _deriveVerifier(password, salt);
    final record = _AccountRecord(
      name: name.trim(),
      email: normalizedEmail,
      salt: base64Encode(salt),
      verifier: base64Encode(verifier),
    );
    await _credentialStore.write(jsonEncode(record.toJson()));
    return UserProfile(name: record.name, email: record.email);
  }

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final record = await _readRecord();
    final normalizedEmail = email.trim().toLowerCase();
    if (record == null || normalizedEmail != record.email) {
      throw const AuthException('Email or password is incorrect.');
    }

    final salt = base64Decode(record.salt);
    final expected = base64Decode(record.verifier);
    final actual = await _deriveVerifier(password, salt);
    if (!_constantTimeEquals(actual, expected)) {
      throw const AuthException('Email or password is incorrect.');
    }
    return UserProfile(name: record.name, email: record.email);
  }

  Future<List<int>> _deriveVerifier(String password, List<int> salt) async {
    final key = await _passwordHasher.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    return key.extractBytes();
  }

  Future<_AccountRecord?> _readRecord() async {
    final saved = await _credentialStore.read();
    if (saved == null || saved.isEmpty) return null;
    try {
      return _AccountRecord.fromJson(jsonDecode(saved) as Map<String, dynamic>);
    } on Object {
      throw const AuthException(
        'The saved account could not be read. Please reinstall the app or '
        'contact support.',
      );
    }
  }

  bool _constantTimeEquals(List<int> first, List<int> second) {
    var difference = first.length ^ second.length;
    final length = min(first.length, second.length);
    for (var index = 0; index < length; index++) {
      difference |= first[index] ^ second[index];
    }
    return difference == 0;
  }
}

class _AccountRecord {
  const _AccountRecord({
    required this.name,
    required this.email,
    required this.salt,
    required this.verifier,
  });

  final String name;
  final String email;
  final String salt;
  final String verifier;

  factory _AccountRecord.fromJson(Map<String, dynamic> json) {
    return _AccountRecord(
      name: json['name'] as String,
      email: json['email'] as String,
      salt: json['salt'] as String,
      verifier: json['verifier'] as String,
    );
  }

  Map<String, String> toJson() => {
    'name': name,
    'email': email,
    'salt': salt,
    'verifier': verifier,
  };
}
