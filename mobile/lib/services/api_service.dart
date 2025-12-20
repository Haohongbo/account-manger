import 'package:dio/dio.dart';
import '../models/account.dart';

/// API 服务
class ApiService {
  late Dio _dio;
  String _baseUrl;

  ApiService({String baseUrl = 'http://10.0.2.2:8080/api/accounts'})
      : _baseUrl = baseUrl {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  String get baseUrl => _baseUrl;

  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  /// 获取所有账号
  Future<List<Account>> getAll() async {
    try {
      final response = await _dio.get(_baseUrl);
      final List<dynamic> data = response.data;
      return data.map((json) => Account.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取数据失败: $e');
    }
  }

  /// 获取单个账号
  Future<Account> getById(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/$id');
      return Account.fromJson(response.data);
    } catch (e) {
      throw Exception('获取账号失败: $e');
    }
  }

  /// 创建账号
  Future<Account> create(Account account) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: account.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return Account.fromJson(response.data);
    } catch (e) {
      throw Exception('创建失败: $e');
    }
  }

  /// 更新账号
  Future<Account> update(int id, Account account) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/$id',
        data: account.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return Account.fromJson(response.data);
    } catch (e) {
      throw Exception('更新失败: $e');
    }
  }

  /// 删除账号
  Future<void> delete(int id) async {
    try {
      await _dio.delete('$_baseUrl/$id');
    } catch (e) {
      throw Exception('删除失败: $e');
    }
  }

  /// 测试连接
  Future<bool> testConnection(String url) async {
    try {
      final response = await _dio.get(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
