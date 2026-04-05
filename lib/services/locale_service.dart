import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const _key = 'locale';

  late SharedPreferences _prefs;
  late ValueNotifier<Locale> localeNotifier;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs.getString(_key) ?? 'zh';
    localeNotifier = ValueNotifier(Locale(saved));
  }

  Locale get current => localeNotifier.value;

  Future<void> setLocale(String languageCode) async {
    await _prefs.setString(_key, languageCode);
    localeNotifier.value = Locale(languageCode);
  }

  bool get isZh => current.languageCode == 'zh';
}
