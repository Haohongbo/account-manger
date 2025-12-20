import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';

class AccountFormScreen extends StatefulWidget {
  final Account? account;

  const AccountFormScreen({super.key, this.account});

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userNameController;
  late TextEditingController _passWordController;
  late TextEditingController _jingBiController;
  late TextEditingController _zhuanshiController;
  late TextEditingController _statusController;
  bool _isLoading = false;

  bool get isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.account?.userName ?? '');
    _passWordController = TextEditingController(text: widget.account?.passWord ?? '');
    _jingBiController = TextEditingController(text: widget.account?.jingBi ?? '0');
    _zhuanshiController = TextEditingController(text: widget.account?.zhuanshi ?? '0');
    _statusController = TextEditingController(text: widget.account?.status ?? '');
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passWordController.dispose();
    _jingBiController.dispose();
    _zhuanshiController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final account = Account(
      userName: _userNameController.text.trim(),
      passWord: _passWordController.text.trim(),
      jingBi: _jingBiController.text.trim().isEmpty ? '0' : _jingBiController.text.trim(),
      zhuanshi: _zhuanshiController.text.trim().isEmpty ? '0' : _zhuanshiController.text.trim(),
      status: _statusController.text.trim(),
    );

    final provider = context.read<AccountProvider>();
    bool success;

    if (isEditing) {
      success = await provider.updateAccount(widget.account!.id!, account);
    } else {
      success = await provider.createAccount(account);
    }

    setState(() => _isLoading = false);

    if (success) {
      Fluttertoast.showToast(msg: isEditing ? '更新成功' : '创建成功');
      if (mounted) Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: isEditing ? '更新失败' : '创建失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑账号' : '添加账号'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: '用户名 *',
                hintText: '请输入用户名',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入用户名';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passWordController,
              decoration: const InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _jingBiController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '金币',
                      hintText: '0',
                      prefixIcon: Icon(Icons.monetization_on),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _zhuanshiController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '钻石',
                      hintText: '0',
                      prefixIcon: Icon(Icons.diamond),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: '状态',
                hintText: '例如: vip等级10 手机尾号：6571',
                prefixIcon: Icon(Icons.info),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? '保存修改' : '创建账号'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
