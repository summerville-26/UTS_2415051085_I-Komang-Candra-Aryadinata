import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfileProvider({required SupabaseClient client})
    : _service = UserProfileService(client);

  final UserProfileService _service;

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _service.fetchProfile();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile({
    required String name,
    required String about,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _profile?.userId;

      if (userId == null) {
        throw StateError('Profil belum dimuat.');
      }

      _profile = await _service.saveProfile(
        UserProfile(
          userId: userId,
          name: name.trim(),
          about: about.trim(),
          createdAt: _profile?.createdAt,
        ),
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
