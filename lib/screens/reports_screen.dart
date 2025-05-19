import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionBox = Hive.box('transactions');
    final transactions = transactionBox.values.toList().cast<Transaction>();

    Map<String, double> dailyExpenses = {};
    transactions.where((txn) => !txn.isIncome).forEach((txn) {
      String dateKey = DateFormat('yyyy-MM-dd').format(txn.date);
      dailyExpenses.update(dateKey, (value) => value + txn.amount, ifAbsent: () => txn.amount);
    });

    List<FlSpot> expenseSpots = [];
    List<String> dateLabels = [];
    int index = 0;
    dailyExpenses.forEach((date, amount) {
      expenseSpots.add(FlSpot(index.toDouble(), amount));
      dateLabels.add(date);
      index++;
    });

    double maxExpense = dailyExpenses.isNotEmpty ? dailyExpenses.values.reduce((a, b) => a > b ? a : b) : 100;
    double interval = (maxExpense / 5).ceilToDouble();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx >= 0 && idx < dateLabels.length) {
                    return Text(
                      DateFormat('MM/dd').format(DateFormat('yyyy-MM-dd').parse(dateLabels[idx])),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('\$${value.toInt()}', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.5),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          lineBarsData: [
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              color: Colors.redAccent,
              barWidth: 4,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.redAccent.withOpacity(0.2),
              ),
            ),
          ],
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black.withOpacity(0.3)),
          ),
          minY: 0,
          maxY: maxExpense + (interval * 2),
        ),
      ),
    );
  }
}
