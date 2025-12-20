import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../services/api_service.dart';
import '../utils/storage.dart';

/// 搜索过滤条件
class SearchFilters {
  String userName = '';
  double? jingBiMin;
  double? jingBiMax;
  double? zhuanshiMin;
  double? zhuanshiMax;
  int? vipMin;
  int? vipMax;
  String phoneTail = '';
  bool phoneEmpty = false;

  void reset() {
    userName = '';
    jingBiMin = null;
    jingBiMax = null;
    zhuanshiMin = null;
    zhuanshiMax = null;
    vipMin = null;
    vipMax = null;
    phoneTail = '';
    phoneEmpty = false;
  }

  bool get isEmpty =>
      userName.isEmpty &&
      jingBiMin == null &&
      jingBiMax == null &&
      zhuanshiMin == null &&
      zhuanshiMax == null &&
      vipMin == null &&
      vipMax == null &&
      phoneTail.isEmpty &&
      !phoneEmpty;
}

/// 账号状态管理
class AccountProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Account> _accounts = [];
  List<Account> _filteredAccounts = [];
  bool _isLoading = false;
  String? _error;
  final SearchFilters filters = SearchFilters();

  List<Account> get accounts => _filteredAccounts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get apiUrl => _apiService.baseUrl;

  AccountProvider() {
    _init();
  }

  Future<void> _init() async {
    final url = await StorageUtil.getApiUrl();
    _apiService.setBaseUrl(url);
    await loadAccounts();
  }

  /// 设置 API 地址
  Future<void> setApiUrl(String url) async {
    await StorageUtil.saveApiUrl(url);
    _apiService.setBaseUrl(url);
    notifyListeners();
  }

  /// 重置为默认 API 地址
  Future<void> resetApiUrl() async {
    await StorageUtil.clearApiUrl();
    _apiService.setBaseUrl(StorageUtil.defaultApiUrl);
    notifyListeners();
  }

  /// 测试连接
  Future<bool> testConnection(String url) async {
    return await _apiService.testConnection(url);
  }

  /// 加载账号列表
  Future<void> loadAccounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _accounts = await _apiService.getAll();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _accounts = [];
      _filteredAccounts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 应用搜索过滤
  void applyFilters() {
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredAccounts = _accounts.where((account) {
      // 用户名过滤
      if (filters.userName.isNotEmpty &&
          !account.userName.toLowerCase().contains(filters.userName.toLowerCase())) {
        return false;
      }

      // 金币范围过滤
      if (filters.jingBiMin != null && account.jingBiValue < filters.jingBiMin!) {
        return false;
      }
      if (filters.jingBiMax != null && account.jingBiValue > filters.jingBiMax!) {
        return false;
      }

      // 钻石范围过滤
      if (filters.zhuanshiMin != null && account.zhuanshiValue < filters.zhuanshiMin!) {
        return false;
      }
      if (filters.zhuanshiMax != null && account.zhuanshiValue > filters.zhuanshiMax!) {
        return false;
      }

      // VIP 等级过滤
      if (filters.vipMin != null || filters.vipMax != null) {
        final vip = account.vipLevel;
        if (vip == null) return false;
        if (filters.vipMin != null && vip < filters.vipMin!) return false;
        if (filters.vipMax != null && vip > filters.vipMax!) return false;
      }

      // 手机尾号过滤
      if (filters.phoneEmpty) {
        if (account.phoneTail != null) return false;
      } else if (filters.phoneTail.isNotEmpty) {
        final tail = account.phoneTail;
        if (tail == null || !tail.contains(filters.phoneTail)) return false;
      }

      return true;
    }).toList();
  }

  /// 重置过滤
  void resetFilters() {
    filters.reset();
    _applyFilters();
    notifyListeners();
  }

  /// 创建账号
  Future<bool> createAccount(Account account) async {
    try {
      await _apiService.create(account);
      await loadAccounts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 更新账号
  Future<bool> updateAccount(int id, Account account) async {
    try {
      await _apiService.update(id, account);
      await loadAccounts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 删除账号
  Future<bool> deleteAccount(int id) async {
    try {
      await _apiService.delete(id);
      await loadAccounts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
