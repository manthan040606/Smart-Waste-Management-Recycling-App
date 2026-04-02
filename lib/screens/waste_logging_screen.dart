import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/waste_log.dart';
import '../providers/app_provider.dart';

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
    'organic': 'Please drain liquids. Use compostable bags. Keep free from plastic wrappers.',
    'plastic': 'Rinse to remove food residue. Crush to save space. Remove caps if not attached.',
    'e-waste': 'Do not crush. Batteries should be removed. Erase personal data from devices.',
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
        syncStatus: 0, // offline by default until synced
      );

      // Use provider
      await Provider.of<AppProvider>(context, listen: false).addWasteLog(log);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Waste log saved! You earned $earnedPoints points.'),
          backgroundColor: Colors.green,
        ),
      );

      _descController.clear();
      _quantityController.clear();
      setState(() {
        _selectedCategory = 'organic';
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Waste'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                color: Colors.green.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.green, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        'Proper Disposal Guidance',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _guidance[_selectedCategory]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.green.shade900),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Waste Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.category),
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
                  labelText: 'Description (e.g. food scraps)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: (val) => val!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity (Kg)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter quantity';
                  if (double.tryParse(val) == null) return 'Must be a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitLog,
                icon: const Icon(Icons.save),
                label: const Text('Log Waste', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
