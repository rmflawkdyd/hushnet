import 'package:shared_preferences/shared_preferences.dart';

import '../../core/preference_keys.dart';

class SelectedServerStore {
  const SelectedServerStore();

  Future<void> save(String serverId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(PreferenceKeys.selectedServerId, serverId);
  }

  Future<String?> load() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(PreferenceKeys.selectedServerId);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(PreferenceKeys.selectedServerId);
  }
}
