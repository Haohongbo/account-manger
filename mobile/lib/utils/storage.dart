import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储工具
class StorageUtil {
  static const String _keyApiUrl = 'api_url';
  static const String defaultApiUrl = 'http://10.0.2.2:8080/api/accounts';

  /// 保存 API 地址
  static Future<void> saveApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiUrl, url);
  }

  /// 获取 API 地址
  static Future<String> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyApiUrl) ?? defaultApiUrl;
  }

  /// 清除 API 地址
  static Future<void> clearApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyApiUrl);
  }
}
