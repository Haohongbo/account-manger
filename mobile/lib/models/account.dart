/// 账号数据模型
class Account {
  final int? id;
  final String userName;
  final String passWord;
  final String jingBi;
  final String zhuanshi;
  final String? dataTime;
  final String status;

  Account({
    this.id,
    required this.userName,
    required this.passWord,
    this.jingBi = '0',
    this.zhuanshi = '0',
    this.dataTime,
    this.status = '',
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      userName: json['userName'] ?? '',
      passWord: json['passWord'] ?? '',
      jingBi: json['jingBi'] ?? '0',
      zhuanshi: json['zhuanshi'] ?? '0',
      dataTime: json['dataTime'],
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userName': userName,
      'passWord': passWord,
      'jingBi': jingBi,
      'zhuanshi': zhuanshi,
      'status': status,
    };
  }

  /// 解析 VIP 等级
  int? get vipLevel {
    final match = RegExp(r'vip[等级]*\s*(\d+)', caseSensitive: false)
        .firstMatch(status);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  /// 解析手机尾号
  String? get phoneTail {
    final match = RegExp(r'[手机尾号：:]+\s*(\d+)').firstMatch(status);
    return match?.group(1);
  }

  /// 解析金币数值
  double get jingBiValue {
    final num = double.tryParse(jingBi.replaceAll(RegExp(r'[^\d.-]'), ''));
    return num ?? 0;
  }

  /// 解析钻石数值
  double get zhuanshiValue {
    final num = double.tryParse(zhuanshi.replaceAll(RegExp(r'[^\d.-]'), ''));
    return num ?? 0;
  }
}
