import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String currentAccountKey = 'current_account_phone';

  Future<String?> loadCurrentAccountPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(currentAccountKey);
  }

  Future<void> saveCurrentAccountPhone(String? phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    if (phoneNumber == null) {
      await prefs.remove(currentAccountKey);
    } else {
      await prefs.setString(currentAccountKey, phoneNumber);
    }
  }
}
