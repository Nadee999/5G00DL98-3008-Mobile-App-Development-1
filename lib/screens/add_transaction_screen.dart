import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'Food';
  final _amountController = TextEditingController();
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                icon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter an amount' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                icon: Icon(Icons.category),
              ),
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
              items: ['Food', 'Transportation', 'Entertainment']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Income'),
              value: _isIncome,
              onChanged: (value) {
                setState(() {
                  _isIncome = value;
                });
              },
              secondary: Icon(
                _isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: _isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final transaction = Transaction(
                    category: _category,
                    amount: double.parse(_amountController.text),
                    isIncome: _isIncome,
                    date: _selectedDate,
                  );
                  Hive.box('transactions').add(transaction);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction added!')),
                  );
                  _formKey.currentState!.reset();
                  setState(() {
                    _category = 'Food';
                    _isIncome = false;
                    _selectedDate = DateTime.now();
                  });
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
