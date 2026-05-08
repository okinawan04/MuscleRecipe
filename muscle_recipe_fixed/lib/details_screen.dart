import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuscleRecipe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DetailsScreen(),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int _selectedIndex = 0;

  final List<PurchaseRecord> purchaseRecords = [
    PurchaseRecord(
      date: '2026/04/01',
      quantity: 1,
      isHighlighted: true,
    ),
    PurchaseRecord(
      date: '2026/04/15',
      quantity: 1,
      isHighlighted: false,
    ),
  ];

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
            // Top Bar with Back Button
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
                    '人参',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Purchase Records List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF5C5C5C),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        onTap: _onNavBarTapped,
      ),
    );
  }
}

class PurchaseRecord {
  final String date;
  final int quantity;
  final bool isHighlighted;

  PurchaseRecord({
    required this.date,
    required this.quantity,
    this.isHighlighted = false,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: record.isHighlighted
            ? const Color(0xFFFF6B6B)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '購入日',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: record.isHighlighted ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            record.date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: record.isHighlighted ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '購入数',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: record.isHighlighted ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${record.quantity}本',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: record.isHighlighted ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
