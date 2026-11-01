import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

class UserProfileService {
  UserProfileService(this._client);

  final SupabaseClient _client;

  String get _userId {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError('Sesi pengguna belum tersedia.');
    }

    return user.id;
  }

  Future<UserProfile> fetchProfile() async {
    final row = await _client
        .from('user_profiles')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();

    if (row == null) {
      final newProfile = UserProfile(userId: _userId, name: '', about: '');

      return saveProfile(newProfile);
    }

    return UserProfile.fromJson(Map<String, dynamic>.from(row));
  }

  Future<UserProfile> saveProfile(UserProfile profile) async {
    final row = await _client
        .from('user_profiles')
        .upsert(profile.toJson(), onConflict: 'user_id')
        .select()
        .single();

    return UserProfile.fromJson(Map<String, dynamic>.from(row));
  }
}
