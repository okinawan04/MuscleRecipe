import 'package:flutter/material.dart';
import 'package:muscle_recipe/database_helper.dart';

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

    final List<PurchaseRecord> loadedRecords = [];

    for (final item in result) {
      loadedRecords.add(
        PurchaseRecord(
          date: item['purchase_date'].toString(),
          quantity: (item['quantity'] as num).toInt(),
          expireDate: item['expire_date'].toString(),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      purchaseRecords = loadedRecords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF4A4A4A),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 12),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: Text(
                  widget.ingredientName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),

            Expanded(
              child: purchaseRecords.isEmpty
                  ? const Center(
                      child: Text(
                        '履歴がありません',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: purchaseRecords.length,
                      itemBuilder: (context, index) {
                        return PurchaseRecordCard(
                          record: purchaseRecords[index],
                        );
                      },
                    ),
            ),
          ],
        ),
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
    DateTime? expire;
    try {
      expire = DateTime.parse(record.expireDate);
    } catch (_) {
      expire = null;
    }

    final now = DateTime.now();
    final isNearExpire =
        expire != null && expire.difference(now).inDays <= 3;

    final isConsumption = record.quantity < 0;

    final Color cardColor = isConsumption
        ? const Color(0xFF4A90E2)
        : isNearExpire
            ? const Color(0xFFFF6B6B)
            : Colors.white;

    final Color labelColor =
        isConsumption || isNearExpire ? Colors.white : Colors.black54;

    final Color valueColor =
        isConsumption || isNearExpire ? Colors.white : Colors.black;

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
            '${record.quantity.abs()}個',
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