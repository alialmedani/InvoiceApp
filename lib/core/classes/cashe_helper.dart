import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoice/core/constant/end_points/cashe_helper_constant.dart';

class CacheHelper {
  static late Box<dynamic> box;
  static late Box<dynamic> wishlistBox;
  static late Box<dynamic> cartBox;
  static late Box<dynamic> currentUserBox;
  static late Box<dynamic> settingBox;
  static late Box<dynamic> attendanceBox;

  static init() async {
    await Hive.initFlutter();

    box = await Hive.openBox("default_box");
    wishlistBox = await Hive.openBox("model_box");
    cartBox = await Hive.openBox("cart_box");
    currentUserBox = await Hive.openBox("current_user_box");
    settingBox = await Hive.openBox("setting_box");
    attendanceBox = await Hive.openBox("attendance_box");
  }

  static Future<void> setLang(String value) => box.put(languageValue, value);

  static Future<void> setToken(String? value) =>
      box.put(accessToken, value ?? '');
  static Future<void> setDeviceToken(String? value) =>
      box.put(deviceToken, value ?? '');
  static Future<void> setRefreshToken(String? value) =>
      box.put(refreshToken, value ?? '');
  static Future<void> setUserId(String? value) => box.put(userId, value ?? 0);
  static Future<void> setUserName(String? value) =>
      box.put(userName, value ?? 0);
  static Future<void> setExpiresIn(int? value) =>
      box.put(expiresIn, value ?? 0);
  static Future<void> setFirstTime(bool value) => box.put(isFirstTime, value);

  static Future<void> setTheme(String value) => box.put('app_theme', value);
  static Future<void> setThemeMode(String value) =>
      box.put('theme_mode', value);

  static Future<void> setLocale(String value) => box.put('app_locale', value);
  static Future<void> setLanguageCode(String value) =>
      box.put('language_code', value);

  static Future<void> setCountryCode(String? value) {
    if (value == null) {
      return box.delete('country_code').then((_) => null);
    }
    return box.put('country_code', value);
  }

  static Future<void> setBaseUrl(String value) => box.put(baseUrl, value);

  // Notification settings
  static Future<void> setDailyReminderEnabled(bool value) =>
      box.put('daily_reminder_enabled', value);
  static Future<void> setLastCheckinTime(DateTime value) =>
      box.put('last_checkin_time', value.toIso8601String());

  // Remote work setting
  static Future<void> setRemoteWorkEnabled(bool value) =>
      box.put('remote_work_enabled', value);

  static Future<void> setDateWithExpiry(int expiresInSeconds) {
    DateTime expiryDateTime = DateTime.now().add(
      Duration(seconds: expiresInSeconds),
    );
    return box.put(date, expiryDateTime);
  }

  // ======================= GET =======================

  static String get lang => box.get(languageValue) ?? 'ar';
  static String get theme => box.get('app_theme', defaultValue: 'light');
  static String get themeMode => box.get('theme_mode', defaultValue: 'light');

  static String get locale => box.get('app_locale', defaultValue: 'ar');

  static String get languageCode =>
      box.get('language_code', defaultValue: 'ar');
  static String? get countryCode => box.get('country_code');

  /// ✅ أهم شي: هل المستخدم اختار لغة و انحفظت؟
  /// يتحقق من وجود مفتاح اللغة و أنه غير فارغ
  static bool get hasSavedLocale {
    if (!box.containsKey('language_code')) return false;
    final v = box.get('language_code');
    return v != null && v.toString().trim().isNotEmpty;
  }

  static String get apiBaseUrl => box.get(baseUrl) ?? '';

  static String? get token {
    if (!box.containsKey(accessToken)) return null;
    return "${box.get(accessToken)}";
  }

  static String? get getDeviceToken {
    if (!box.containsKey(deviceToken)) return null;
    return "${box.get(deviceToken)}";
  }

  static String? get refreshtoken {
    if (!box.containsKey(refreshToken)) return null;
    return "${box.get(refreshToken)}";
  }

  static String? get userID {
    if (!box.containsKey(userId)) return null;
    return "${box.get(userId)}";
  }

  static String? get userNAme {
    if (!box.containsKey(userName)) return null;
    return "${box.get(userName)}";
  }

  static bool get firstTime => box.get(isFirstTime) ?? true;
  static int? get expiresin => box.get(expiresIn);
  static DateTime? get datenow => box.get(date);

  // Notification getters
  static bool get isDailyReminderEnabled =>
      box.get('daily_reminder_enabled', defaultValue: true);
  static DateTime? get lastCheckinTime {
    final String? timeString = box.get('last_checkin_time');
    if (timeString == null) return null;
    return DateTime.tryParse(timeString);
  }

  // Remote work getter
  static bool get isRemoteWorkEnabled =>
      box.get('remote_work_enabled', defaultValue: false);

  static void deleteCertificates() {
    setToken(null);
    setUserId(null);
  }

  static Future<void> deleteAllAttendance() async {
    await attendanceBox.clear();
  }
}
