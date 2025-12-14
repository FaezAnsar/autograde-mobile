import 'package:autograde_mobile/core/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHandler<T> {
  const SharedPreferenceHandler({
    required SharedPreferences sharedPreferences,
    required this.key,
    required this.defaultValue,
    String? Function(T)? serializer,
    T Function(String?)? deserializer,
  })  : _sharedPreferences = sharedPreferences,
        _deserializer = deserializer,
        _serializer = serializer;

  final SharedPreferences _sharedPreferences;
  final String key;
  final T defaultValue;
  final String? Function(T value)? _serializer;
  final T Function(String? value)? _deserializer;

  Future<void> save(T value) async {
    if (value == null) {
      _sharedPreferences.remove(key);
      return;
    }
    // Save the serialized value to shared preferences
    if (value is String) {
      _sharedPreferences.setString(key, value);
    } else if (value is int) {
      _sharedPreferences.setInt(key, value);
    } else if (value is double) {
      _sharedPreferences.setDouble(key, value);
    } else if (value is bool) {
      _sharedPreferences.setBool(key, value);
    } else if (value is List<String>) {
      _sharedPreferences.setStringList(key, value);
    } else {
      if (_serializer != null) {
        _sharedPreferences.setString(key, _serializer(value) ?? '');
      } else {
        throw Exception('Unsupported type: ${value.runtimeType}');
      }
    }
  }

  T get() {
    // Retrieve the value from shared preferences
    if (_sharedPreferences.containsKey(key)) {
      if (isType<T, String>() || isType<T, String?>()) {
        return _sharedPreferences.getString(key) as T;
      } else if (isType<T, int>() || isType<T, int?>()) {
        return _sharedPreferences.getInt(key) as T;
      } else if (isType<T, double>() || isType<T, int?>()) {
        return _sharedPreferences.getDouble(key) as T;
      } else if (isType<T, bool>() || isType<T, int?>()) {
        return _sharedPreferences.getBool(key) as T;
      } else if (isType<T, List<String>>() || isType<T, List<String>?>()) {
        return _sharedPreferences.getStringList(key) as T;
      } else {
        if (_deserializer != null) {
          return _deserializer(_sharedPreferences.getString(key));
        } else {
          throw Exception('Unsupported type: ${T.toString()}');
        }
      }
    }
    return defaultValue;
  }

  Future<void> delete() async {
    await _sharedPreferences.remove(key);
  }
}
