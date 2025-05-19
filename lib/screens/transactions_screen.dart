import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionBox = Hive.box('transactions');
    return ValueListenableBuilder(
      valueListenable: transactionBox.listenable(),
      builder: (context, box, _) {
        if (box.isEmpty) {
          return const Center(
            child: Text('No transactions yet.'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: box.length,
          itemBuilder: (context, index) {
            final transaction = box.getAt(index) as Transaction;
            final isIncome = transaction.isIncome;
            final formattedDate = DateFormat.yMMMd().format(transaction.date);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isIncome ? Colors.green : Colors.red,
                ),
                title: Text(transaction.category),
                subtitle: Text(formattedDate),
                trailing: Text(
                  isIncome
                      ? '+ \$${transaction.amount.toStringAsFixed(2)}'
                      : '- \$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
