import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:muscle_recipe/database_helper.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  const AccountScreen({
    super.key,
    this.onLogout,
    required this.currentThemeMode,
    this.onThemeModeChanged,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  ImageProvider? _profileImage;
  IconData _selectedIcon = Icons.account_circle;
  String _accountName = 'ユーザー名';
  String _height = '';
  String _weight = '';
  String _age = '';
  String _gender = '男性';
  String _trainingGoal = 'がっつり筋トレ';

  final ImagePicker _picker = ImagePicker();

  final List<IconData> _availableIcons = [
    Icons.account_circle,
    Icons.person,
    Icons.face,
    Icons.emoji_people,
    Icons.sports_soccer,
    Icons.fitness_center,
  ];

  final List<String> _genders = ['男性', '女性', 'その他'];
  final List<String> _trainingGoals = ['がっつり筋トレ', 'ダイエット', '健康'];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (kIsWeb) {
      return;
    }
    try {
      final user = await DatabaseHelper.instance.getUser();
      if (user != null && mounted) {
        setState(() {
          _accountName = user['name'] ?? 'ユーザー名';
          _height = user['height']?.toString() ?? '';
          _weight = user['weight']?.toString() ?? '';
          _age = user['age']?.toString() ?? '';
          _gender = user['gender'] ?? '男性';
          _trainingGoal = user['training_preference'] ?? 'がっつり筋トレ';
          if (!_trainingGoals.contains(_trainingGoal)) {
            _trainingGoals.add(_trainingGoal);
          }
        });
      }
    } catch (e) {
      // DB読み込みエラーは無視
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント'),
        centerTitle: true,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF4FC3F7)
            : const Color(0xFFFFB300),
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildAccountInfo(),
              const SizedBox(height: 24),
              _buildGroupedAccountSection(),
              const SizedBox(height: 24),
              _buildSupportSection(),
              const SizedBox(height: 24),
              _buildLogout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo() {
    return InkWell(
      onTap: _showAccountEditDialog,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: _profileImage,
                child: _profileImage == null
                    ? Icon(
                        _selectedIcon,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _accountName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'タップして編集',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedAccountSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: const Text('身体情報'),
            subtitle: Text(
              '身長: ${_height.isEmpty ? '未設定' : '$_height cm'}\n'
              '体重: ${_weight.isEmpty ? '未設定' : '$_weight kg'}\n'
              '年齢: ${_age.isEmpty ? '未設定' : '$_age 歳'}\n'
              '性別: $_gender',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showPhysicalInfoDialog,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('トレーニング志向'),
            subtitle: Text('目標: $_trainingGoal'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showTrainingGoalDialog,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('テーマ設定'),
            subtitle: Text(
              widget.currentThemeMode == ThemeMode.light ? 'ライトモード' : 'ダークモード',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showThemeDialog,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: const Text('利用規約'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showTermsDialog,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('プライバシーポリシー'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showPrivacyDialog,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('お問い合わせ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showContactDialog,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('利用規約'),
          content: SingleChildScrollView(
            child: const Text(
              '本アプリのご利用にあたっては、以下の内容に同意していただく必要があります。\n\n'
              '1. 本アプリは健康管理の参考情報を提供します。\n'
              '2. 本アプリの情報に依存した結果については責任を負いません。\n'
              '3. 利用者は自己の判断で適切な運動・食事管理を行ってください。',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('プライバシーポリシー'),
          content: SingleChildScrollView(
            child: const Text(
              '本アプリは、利用者の入力した身体情報をアプリ内で管理します。\n\n'
              '1. 個人情報は端末内で保存され、外部に送信されません。\n'
              '2. アプリの機能向上のために、利用状況の分析を行う場合がありますが、個人が特定される形ではありません。\n'
              '3. 利用者はいつでもデータの編集・削除が可能です。',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('お問い合わせ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('ご意見・ご要望・不具合報告は、以下のメールアドレスまでお送りください。'),
                SizedBox(height: 12),
                SelectableText('support@musclerecipe.app'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogout() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('ログアウト'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _showAccountEditDialog() {
    String tempName = _accountName;
    IconData tempIcon = _selectedIcon;
    ImageProvider? tempImage = _profileImage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('アカウント編集'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: tempImage,
                      child:
                          tempImage == null ? Icon(tempIcon, size: 40) : null,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final XFile? image = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setState(() {
                            tempImage = FileImage(File(image.path));
                          });
                        }
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('画像を選択'),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _availableIcons.map((icon) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              tempIcon = icon;
                              tempImage = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: tempIcon == icon && tempImage == null
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                                width: tempIcon == icon && tempImage == null
                                    ? 2
                                    : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, size: 32),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'アカウント名',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: tempName),
                      onChanged: (value) => tempName = value,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _accountName = tempName;
                      _selectedIcon = tempIcon;
                      _profileImage = tempImage;
                    });
                    if (!kIsWeb) {
                      try {
                        await DatabaseHelper.instance.saveUser(
                          name: _accountName,
                          height: double.tryParse(_height),
                          weight: double.tryParse(_weight),
                          age: int.tryParse(_age),
                          gender: _gender,
                          trainingPreference: _trainingGoal,
                        );
                      } catch (_) {
                        // アカウント名のみの保存エラーは無視
                      }
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPhysicalInfoDialog() {
    String tempHeight = _height;
    String tempWeight = _weight;
    String tempAge = _age;
    String tempGender = _gender;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('身体情報編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: tempHeight,
                decoration: const InputDecoration(
                  labelText: '身長 (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => tempHeight = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: tempWeight,
                decoration: const InputDecoration(
                  labelText: '体重 (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => tempWeight = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: tempAge,
                decoration: const InputDecoration(
                  labelText: '年齢',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => tempAge = value,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: tempGender,
                decoration: const InputDecoration(
                  labelText: '性別',
                  border: OutlineInputBorder(),
                ),
                items: _genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    tempGender = newValue;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _height = tempHeight;
                  _weight = tempWeight;
                  _age = tempAge;
                  _gender = tempGender;
                });
                if (!kIsWeb) {
                  try {
                    await DatabaseHelper.instance.saveUser(
                      name: _accountName,
                      height: double.tryParse(tempHeight),
                      weight: double.tryParse(tempWeight),
                      age: int.tryParse(tempAge),
                      gender: tempGender,
                      trainingPreference: _trainingGoal,
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('保存に失敗: $e')),
                      );
                    }
                  }
                }
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _showTrainingGoalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('トレーニング志向編集'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _trainingGoals.map((goal) {
                return ListTile(
                  title: Text(goal),
                  trailing:
                      _trainingGoal == goal ? const Icon(Icons.check) : null,
                  onTap: () async {
                    setState(() {
                      _trainingGoal = goal;
                    });
                    if (!kIsWeb) {
                      try {
                        await DatabaseHelper.instance.saveUser(
                          name: _accountName,
                          height: double.tryParse(_height),
                          weight: double.tryParse(_weight),
                          age: int.tryParse(_age),
                          gender: _gender,
                          trainingPreference: goal,
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('保存に失敗: $e')),
                          );
                        }
                      }
                    }
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('テーマ設定'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: widget.currentThemeMode,
                title: const Text('ライトモード'),
                onChanged: (value) {
                  if (value != null) {
                    widget.onThemeModeChanged?.call(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: widget.currentThemeMode,
                title: const Text('ダークモード'),
                onChanged: (value) {
                  if (value != null) {
                    widget.onThemeModeChanged?.call(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログアウト'),
          content: const Text('本当にログアウトしますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onLogout?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('ログアウト'),
            ),
          ],
        );
      },
    );
  }
}
