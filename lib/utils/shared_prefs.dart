import 'package:shared_preferences/shared_preferences.dart';

import 'constantes.dart';

class SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  //static const String _token = keyToken;
  static const String _autoGetData = keyAutoGetData;
  static const String _maxArchivo = keyMaxArchivo;
  static const String _storageComparador = keyStorageComparador;

  //static const String _autoSave = keyAutoSave;

  Future<void> init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  //String get token => _sharedPrefs?.getString(_token) ?? '';

  //set token(String value) => _sharedPrefs?.setString(_token, value);

  bool get autoGetData => _sharedPrefs?.getBool(_autoGetData) ?? true;

  set autoGetData(bool value) => _sharedPrefs?.setBool(_autoGetData, value);

  int get maxArchivo => _sharedPrefs?.getInt(_maxArchivo) ?? 0;

  set maxArchivo(int value) => _sharedPrefs?.setInt(_maxArchivo, value);

  bool get storageComparador =>
      _sharedPrefs?.getBool(_storageComparador) ?? false;

  set storageComparador(bool value) =>
      _sharedPrefs?.setBool(_storageComparador, value);

  //bool get autoSave => _sharedPrefs?.getBool(_autoSave) ?? true;
  //set autoSave(bool value) => _sharedPrefs?.setBool(_autoSave, value);
}
