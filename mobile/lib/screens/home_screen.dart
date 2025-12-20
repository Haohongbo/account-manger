import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import 'account_form.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSearch = false;

  // 搜索控制器
  final _userNameController = TextEditingController();
  final _jingBiMinController = TextEditingController();
  final _jingBiMaxController = TextEditingController();
  final _zhuanshiMinController = TextEditingController();
  final _zhuanshiMaxController = TextEditingController();
  final _vipMinController = TextEditingController();
  final _vipMaxController = TextEditingController();
  final _phoneTailController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _jingBiMinController.dispose();
    _jingBiMaxController.dispose();
    _zhuanshiMinController.dispose();
    _zhuanshiMaxController.dispose();
    _vipMinController.dispose();
    _vipMaxController.dispose();
    _phoneTailController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(msg: '$label 已复制');
  }

  void _applyFilters() {
    final provider = context.read<AccountProvider>();
    provider.filters.userName = _userNameController.text;
    provider.filters.jingBiMin = double.tryParse(_jingBiMinController.text);
    provider.filters.jingBiMax = double.tryParse(_jingBiMaxController.text);
    provider.filters.zhuanshiMin = double.tryParse(_zhuanshiMinController.text);
    provider.filters.zhuanshiMax = double.tryParse(_zhuanshiMaxController.text);
    provider.filters.vipMin = int.tryParse(_vipMinController.text);
    provider.filters.vipMax = int.tryParse(_vipMaxController.text);
    provider.filters.phoneTail = _phoneTailController.text;
    provider.applyFilters();
  }

  void _resetFilters() {
    _userNameController.clear();
    _jingBiMinController.clear();
    _jingBiMaxController.clear();
    _zhuanshiMinController.clear();
    _zhuanshiMaxController.clear();
    _vipMinController.clear();
    _vipMaxController.clear();
    _phoneTailController.clear();
    context.read<AccountProvider>().resetFilters();
    context.read<AccountProvider>().loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账号管理系统'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.search_off : Icons.search),
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索面板
          if (_showSearch) _buildSearchPanel(),
          
          // 账号列表
          Expanded(child: _buildAccountList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AccountFormScreen()),
        ),
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            children: [
              // 第一行
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _userNameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRangeInput('金币(亿)', _jingBiMinController, _jingBiMaxController),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 第二行
              Row(
                children: [
                  Expanded(
                    child: _buildRangeInput('钻石(万)', _zhuanshiMinController, _zhuanshiMaxController),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRangeInput('VIP等级', _vipMinController, _vipMaxController),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 第三行
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneTailController,
                      decoration: const InputDecoration(
                        labelText: '手机尾号',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: provider.filters.phoneEmpty,
                        onChanged: (v) {
                          provider.filters.phoneEmpty = v ?? false;
                          provider.applyFilters();
                        },
                      ),
                      const Text('空尾号'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('重置'),
                    onPressed: _resetFilters,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('搜索'),
                    onPressed: _applyFilters,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRangeInput(String label, TextEditingController minCtrl, TextEditingController maxCtrl) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: minCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '$label 最小',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('-'),
        ),
        Expanded(
          child: TextField(
            controller: maxCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '最大',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountList() {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('加载失败', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => provider.loadAccounts(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (provider.accounts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('暂无账号数据', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadAccounts(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.accounts.length,
            itemBuilder: (context, index) {
              return _buildAccountCard(provider.accounts[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildAccountCard(Account account) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部信息
            Row(
              children: [
                Expanded(
                  child: Text(
                    account.userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    account.status.isNotEmpty ? account.status : '未知',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 详细信息
            Row(
              children: [
                _buildInfoChip('密码', account.passWord),
                const SizedBox(width: 8),
                _buildInfoChip('金币', account.jingBi),
                const SizedBox(width: 8),
                _buildInfoChip('钻石', account.zhuanshi),
              ],
            ),
            const SizedBox(height: 8),
            // 复制按钮
            Row(
              children: [
                _buildCopyButton('用户名', account.userName),
                const SizedBox(width: 4),
                _buildCopyButton('密码', account.passWord),
                const SizedBox(width: 4),
                _buildCopyButton('账密', '${account.userName}----${account.passWord}'),
                const Spacer(),
                // 编辑和删除
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountFormScreen(account: account),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _confirmDelete(account),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildCopyButton(String label, String value) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        textStyle: const TextStyle(fontSize: 11),
      ),
      onPressed: () => _copyToClipboard(value, label),
      child: Text(label),
    );
  }

  void _confirmDelete(Account account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除账号 "${account.userName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<AccountProvider>().deleteAccount(account.id!);
              if (success) {
                Fluttertoast.showToast(msg: '删除成功');
              } else {
                Fluttertoast.showToast(msg: '删除失败');
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
