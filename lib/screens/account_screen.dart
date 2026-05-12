import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  ImageProvider? _profileImage;
  IconData _selectedIcon = Icons.account_circle;
  String _accountName = 'ユーザー名';
  String _height = '';
  String _weight = '';
  String _gender = '男性';
  String _trainingGoal = 'がっつり筋トレ';
  final List<String> _purchaseLogs = [];

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // アカウント情報セクション
              _buildAccountInfo(),
              const SizedBox(height: 24),

              // 身体情報セクション
              _buildPhysicalInfo(),
              const SizedBox(height: 24),

              // トレーニング志向セクション
              _buildTrainingGoal(),
              const SizedBox(height: 24),

              // 購入ログセクション
              _buildPurchaseLog(),
              const SizedBox(height: 24),

              // ログアウトセクション
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

  Widget _buildPhysicalInfo() {
    return InkWell(
      onTap: _showPhysicalInfoDialog,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '身体情報',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('身長: ${_height.isEmpty ? '未設定' : '$_height cm'}'),
              Text('体重: ${_weight.isEmpty ? '未設定' : '$_weight kg'}'),
              Text('性別: $_gender'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingGoal() {
    return InkWell(
      onTap: _showTrainingGoalDialog,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'トレーニング志向',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('目標: $_trainingGoal'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseLog() {
    return InkWell(
      onTap: _showPurchaseLogDialog,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '購入ログ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('${_purchaseLogs.length}件の購入記録'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogout() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
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
            ),
            const SizedBox(height: 8),
            const Text(
              'Google、Apple、メールアドレスでのログイン機能は近日実装予定です',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
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
                    const Text('アイコンを選択'),
                    const SizedBox(height: 12),
                    // 現在のアイコン表示
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: tempImage,
                      child:
                          tempImage == null ? Icon(tempIcon, size: 40) : null,
                    ),
                    const SizedBox(height: 12),
                    // デバイスから選択
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
                      label: const Text('デバイスから選択'),
                    ),
                    const SizedBox(height: 12),
                    const Text('またはプリセットから選択'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availableIcons.map((icon) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              tempIcon = icon;
                              tempImage = null; // プリセット選択時は画像をクリア
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
                  onPressed: () {
                    this.setState(() {
                      _accountName = tempName;
                      _selectedIcon = tempIcon;
                      _profileImage = tempImage;
                    });
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
              DropdownButtonFormField<String>(
                value: tempGender,
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
                  tempGender = newValue!;
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
              onPressed: () {
                setState(() {
                  _height = tempHeight;
                  _weight = tempWeight;
                  _gender = tempGender;
                });
                Navigator.of(context).pop();
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _showTrainingGoalDialog() {
    String tempGoal = _trainingGoal;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('トレーニング志向編集'),
          content: DropdownButtonFormField<String>(
            value: tempGoal,
            decoration: const InputDecoration(
              labelText: 'トレーニングの方向性',
              border: OutlineInputBorder(),
            ),
            items: _trainingGoals.map((String goal) {
              return DropdownMenuItem<String>(
                value: goal,
                child: Text(goal),
              );
            }).toList(),
            onChanged: (String? newValue) {
              tempGoal = newValue!;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _trainingGoal = tempGoal;
                });
                Navigator.of(context).pop();
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _showPurchaseLogDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('購入ログ管理'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addPurchaseLog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('食材を追加'),
                ),
                const SizedBox(height: 16),
                if (_purchaseLogs.isNotEmpty) ...[
                  const Text('現在の購入ログ:'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _purchaseLogs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_purchaseLogs[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _purchaseLogs.removeAt(index);
                              });
                              Navigator.of(context).pop();
                              _showPurchaseLogDialog();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
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

  void _addPurchaseLog() {
    String newItem = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('購入食材を追加'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: '食材名',
              hintText: '例: 鶏胸肉 500g',
            ),
            onChanged: (value) => newItem = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newItem.isNotEmpty) {
                  setState(() {
                    _purchaseLogs.add(newItem);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('追加'),
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
          content: const Text('ログアウトしますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: 実際のログアウト処理を実装
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ログアウトしました')),
                );
              },
              child: const Text('ログアウト'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
