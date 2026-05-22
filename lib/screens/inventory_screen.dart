import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../database_helper.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _foods = [];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    if (kIsWeb) {
      // Web環境ではDBが使用できないため、すぐに完了
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    try {
      final foods = await DatabaseHelper.instance.getFoodsWithIngredient();
      if (mounted) {
        setState(() {
          _foods = foods;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('在庫管理'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _foods.isEmpty
                ? _buildEmptyState(context)
                : _buildFoodList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          const Text(
            '在庫が登録されていません',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            '初期データを作成しました。再起動すると反映されます。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList() {
    return ListView.separated(
      itemCount: _foods.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final food = _foods[index];
        final ingredientName = food['ingredient_name'] as String? ?? '食材';
        return ListTile(
          title: Text(ingredientName),
          subtitle: Text('数量: ${food['quantity']} ${food['unit'] ?? ''}'),
          trailing: Text(food['expire_date'] as String? ?? ''),
        );
      },
    );
  }
}
