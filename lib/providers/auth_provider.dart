import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);

  final AuthService _service;
  UserProfile? _profile;
  UserProfile? _savedProfile;
  bool _loading = true;
  String? _loadError;

  UserProfile? get profile => _profile;
  UserProfile? get savedProfile => _savedProfile;
  bool get isLoading => _loading;
  bool get isAuthenticated => _profile != null;
  String? get loadError => _loadError;

  Future<void> load() async {
    try {
      _savedProfile = await _service.savedProfile();
      _loadError = null;
    } catch (error) {
      _loadError = error is AuthException
          ? error.message
          : 'Could not load the saved account.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createProfile({
    required String name,
    required String email,
    required String password,
  }) async {
    final profile = await _service.createProfile(
      name: name,
      email: email,
      password: password,
    );
    _savedProfile = profile;
    _profile = profile;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    final profile = await _service.login(email: email, password: password);
    _savedProfile = profile;
    _profile = profile;
    notifyListeners();
  }

  void logout() {
    _profile = null;
    notifyListeners();
  }
}
