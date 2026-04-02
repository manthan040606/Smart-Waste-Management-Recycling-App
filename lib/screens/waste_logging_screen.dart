import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/waste_log.dart';
import '../providers/app_provider.dart';
import '../widgets/notification_badge.dart';

class WasteLoggingScreen extends StatefulWidget {
  const WasteLoggingScreen({Key? key}) : super(key: key);

  @override
  State<WasteLoggingScreen> createState() => _WasteLoggingScreenState();
}

class _WasteLoggingScreenState extends State<WasteLoggingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedCategory = 'organic';
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final List<String> _categories = ['organic', 'plastic', 'e-waste'];

  final Map<String, String> _guidance = {
    'organic': 'Drain liquids. Use compostable bags. No plastic wrappers.',
    'plastic': 'Rinse to remove food. Crush to save space. Remove caps.',
    'e-waste': 'Do not crush. Erase data. Remove batteries.',
  };

  final Map<String, int> _pointsFactor = {
    'organic': 5,
    'plastic': 10,
    'e-waste': 25,
  };

  void _submitLog() async {
    if (_formKey.currentState!.validate()) {
      double quantity = double.parse(_quantityController.text);
      int earnedPoints = (quantity * _pointsFactor[_selectedCategory]!).round();

      final log = WasteLog(
        id: const Uuid().v4(),
        category: _selectedCategory,
        description: _descController.text,
        quantityKg: quantity,
        timestamp: DateTime.now(),
        points: earnedPoints,
        syncStatus: 0,
      );

      await Provider.of<AppProvider>(context, listen: false).addWasteLog(log);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star, color: Colors.yellow),
              const SizedBox(width: 8),
              Expanded(child: Text('Waste logged! You earned $earnedPoints points.')),
            ],
          ),
          backgroundColor: Colors.green.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      _descController.clear();
      _quantityController.clear();
      setState(() => _selectedCategory = 'organic');
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  static const double _cardOverlap = 56;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight + 8;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Log Waste', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [NotificationBadge()],
      ),
      body: CustomScrollView(
        clipBehavior: Clip.none,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(24, topInset, 24, 24 + _cardOverlap),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green.shade600, Colors.green.shade900],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tips_and_updates_rounded, color: Colors.white, size: 36),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pro Tip',
                                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _guidance[_selectedCategory]!,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -_cardOverlap),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Form(
                          key: _formKey,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Waste Details',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.green),
                                  decoration: InputDecoration(
                                    labelText: 'Category',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(Icons.category_rounded, color: Colors.green),
                                  ),
                                  items: _categories.map((cat) {
                                    return DropdownMenuItem(value: cat, child: Text(cat.toUpperCase()));
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedCategory = val!),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _descController,
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    hintText: 'e.g. food scraps, batteries',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(Icons.description_rounded, color: Colors.green),
                                  ),
                                  validator: (val) => val!.isEmpty ? 'Please enter a description' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _quantityController,
                                  decoration: InputDecoration(
                                    labelText: 'Quantity (Kg)',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(Icons.scale_rounded, color: Colors.green),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) return 'Please enter quantity';
                                    if (double.tryParse(val) == null) return 'Must be a number';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: _submitLog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 4,
                                    shadowColor: Colors.green.withOpacity(0.5),
                                  ),
                                  child: const Text(
                                    'LOG WASTE',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Recent Logs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<AppProvider>(
                          builder: (context, provider, child) {
                            final logs = provider.wasteLogs;
                            if (logs.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    'No recent logs. Start recycling today!',
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: logs.length > 5 ? 5 : logs.length,
                              itemBuilder: (context, index) {
                                final log = logs[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: log.syncStatus == 1 ? Colors.green.shade50 : Colors.orange.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        log.syncStatus == 1 ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded,
                                        color: log.syncStatus == 1 ? Colors.green.shade600 : Colors.orange.shade600,
                                      ),
                                    ),
                                    title: Text(
                                      '${log.category.toUpperCase()} - ${log.quantityKg}kg',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    subtitle: Text(log.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '+${log.points}',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700, fontSize: 16),
                                        ),
                                        const Text('pts', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
