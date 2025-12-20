import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../utils/storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  String _connectionStatus = '未检测';
  Color _statusColor = Colors.grey;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadApiUrl();
  }

  Future<void> _loadApiUrl() async {
    final url = await StorageUtil.getApiUrl();
    setState(() {
      _urlController.text = url;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      Fluttertoast.showToast(msg: '请输入接口地址');
      return;
    }

    setState(() {
      _isTesting = true;
      _connectionStatus = '测试中...';
      _statusColor = Colors.orange;
    });

    final success = await context.read<AccountProvider>().testConnection(url);

    setState(() {
      _isTesting = false;
      if (success) {
        _connectionStatus = '连接成功';
        _statusColor = Colors.green;
      } else {
        _connectionStatus = '连接失败';
        _statusColor = Colors.red;
      }
    });

    Fluttertoast.showToast(msg: success ? '连接测试成功' : '连接测试失败');
  }

  Future<void> _saveSettings() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      Fluttertoast.showToast(msg: '请输入接口地址');
      return;
    }

    await context.read<AccountProvider>().setApiUrl(url);
    await context.read<AccountProvider>().loadAccounts();
    Fluttertoast.showToast(msg: '设置已保存');
  }

  Future<void> _resetToDefault() async {
    await context.read<AccountProvider>().resetApiUrl();
    _urlController.text = StorageUtil.defaultApiUrl;
    setState(() {
      _connectionStatus = '未检测';
      _statusColor = Colors.grey;
    });
    await context.read<AccountProvider>().loadAccounts();
    Fluttertoast.showToast(msg: '已恢复默认设置');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '后端接口地址',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: '例如: http://192.168.1.100:8080/api/accounts',
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '提示: 安卓模拟器使用 10.0.2.2 访问本机',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '连接状态: $_connectionStatus',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.restore),
                  label: const Text('恢复默认'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: _resetToDefault,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: _isTesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering),
                  label: const Text('测试连接'),
                  onPressed: _isTesting ? null : _testConnection,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('保存设置'),
              onPressed: _saveSettings,
            ),
          ),
        ],
      ),
    );
  }
}
