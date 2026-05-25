import 'package:flutter/material.dart';
import 'database_helper.dart';

class DetailsScreen extends StatefulWidget {
  final int ingredientId;
  final String ingredientName;

  const DetailsScreen({
    super.key,
    required this.ingredientId,
    required this.ingredientName,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int _selectedIndex = 0;

  List<PurchaseRecord> purchaseRecords = [];

  @override
  void initState() {
    super.initState();
    loadPurchaseRecords();
  }

  Future<void> loadPurchaseRecords() async {
    final result = await DatabaseHelper.instance.getFoodHistory(
      widget.ingredientId,
    );

    List<PurchaseRecord> loadedRecords = [];

    for (final item in result) {
      loadedRecords.add(
        PurchaseRecord(
          date: item['purchase_date'].toString(),
          quantity: (item['quantity'] as num).toInt(),
          expireDate: item['expire_date'].toString(),
        ),
      );
    }

    setState(() {
      purchaseRecords = loadedRecords;
    });
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF4A4A4A),
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.ingredientName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Purchase Records
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: purchaseRecords.length,
                itemBuilder: (context, index) {
                  return PurchaseRecordCard(record: purchaseRecords[index]);
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF5C5C5C),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),

          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: ''),

          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),

          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        onTap: _onNavBarTapped,
      ),
    );
  }
}

class PurchaseRecord {
  final String date;
  final int quantity;
  final String expireDate;

  PurchaseRecord({
    required this.date,
    required this.quantity,
    required this.expireDate,
  });
}

class PurchaseRecordCard extends StatelessWidget {
  final PurchaseRecord record;

  const PurchaseRecordCard({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final expire = DateTime.parse(record.expireDate);
    final now = DateTime.now();

    final isNearExpire = expire.difference(now).inDays <= 3;

    // quantity がマイナスなら「消費」と判断
    final isConsumption = record.quantity < 0;

    // 背景色
    final Color cardColor = isConsumption
        ? const Color(0xFF4A90E2) // 消費した履歴は青
        : isNearExpire
            ? const Color(0xFFFF6B6B) // 賞味期限が近い購入履歴は赤
            : Colors.white; // 通常は白

    // 文字色
    final Color labelColor = isConsumption || isNearExpire
        ? Colors.white
        : Colors.black54;

    final Color valueColor = isConsumption || isNearExpire
        ? Colors.white
        : Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isConsumption ? '消費日' : '購入日',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            record.date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            isConsumption ? '消費数' : '購入数',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '${record.quantity}個',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '賞味期限',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            record.expireDate,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
