import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app locales.
enum AppLocale { en, nb }

/// Persists and exposes the user's language choice.
///
/// Defaults to [AppLocale.en]. Call [load] once at startup to
/// read the persisted preference from SharedPreferences.
class LocaleService {
  LocaleService._();
  static final instance = LocaleService._();
  static const _key = 'app_locale';

  final locale = ValueNotifier<AppLocale>(AppLocale.en);

  /// Reads the stored locale from disk. Safe to call multiple
  /// times; only the first read triggers a prefs lookup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored == AppLocale.nb.name) {
      locale.value = AppLocale.nb;
    }
  }

  /// Persists [value] and notifies listeners so the widget
  /// tree rebuilds with the new language.
  Future<void> setLocale(AppLocale value) async {
    locale.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
  }
}
