import 'package:flutter/material.dart';
import '../models/waste_log.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class WasteLoggingScreen extends StatefulWidget {
  const WasteLoggingScreen({Key? key}) : super(key: key);

  @override
  State<WasteLoggingScreen> createState() => _WasteLoggingScreenState();
}

class _WasteLoggingScreenState extends State<WasteLoggingScreen> {
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedCategory = 'organic';
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final List<String> _categories = ['organic', 'plastic', 'e-waste'];

  void _submitLog() async {
    if (_formKey.currentState!.validate()) {
      final log = WasteLog(
        id: const Uuid().v4(),
        category: _selectedCategory,
        description: _descController.text,
        quantityKg: double.parse(_quantityController.text),
        timestamp: DateTime.now(),
      );

      await _storageService.saveWasteLog(log);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waste log saved successfully! (Offline sync ready)')),
      );

      _descController.clear();
      _quantityController.clear();
      setState(() {
        _selectedCategory = 'organic';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Waste')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Waste Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                ),
                validator: (val) => val!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity (Kg)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter quantity';
                  if (double.tryParse(val) == null) return 'Must be a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitLog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Log Waste', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
