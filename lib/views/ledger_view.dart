import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/stardew_theme.dart';

class LedgerView extends StatefulWidget {
  const LedgerView({super.key});

  @override
  State<LedgerView> createState() => _LedgerViewState();
}

class _LedgerViewState extends State<LedgerView> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'income'; // 'income' or 'expense'
  String _selectedCategory = 'Cultivos';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final entries = provider.ledgerEntries;
    final currencyFormatter = NumberFormat.currency(symbol: 'g ', decimalDigits: 0);

    double totalIncome = 0;
    double totalExpense = 0;

    for (var entry in entries) {
      final amt = (entry['amount'] as num).toDouble();
      if (entry['type'] == 'income') {
        totalIncome += amt;
      } else {
        totalExpense += amt;
      }
    }
    final netBalance = totalIncome - totalExpense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contabilidad & Libro Mayor de la Granja', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22, color: StardewColors.primaryGold)),
                  const SizedBox(height: 4),
                  const Text('Lleva tus cuentas de ingresos, inversiones en semillas, animales y edificios con SQLite local.', style: TextStyle(color: StardewColors.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddTransactionDialog(context, provider),
                icon: const Icon(Icons.add),
                label: const Text('Registrar Movimiento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StardewColors.emeraldGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildBalanceCard('Ingresos Totales', currencyFormatter.format(totalIncome), Icons.arrow_downward, StardewColors.emeraldGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBalanceCard('Gastos e Inversión', currencyFormatter.format(totalExpense), Icons.arrow_upward, StardewColors.rubyRed),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBalanceCard('Balance Neto', currencyFormatter.format(netBalance), Icons.account_balance_wallet, StardewColors.primaryGold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Gráfico de Ingresos vs Gastos
          if (entries.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resumen Financiero', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  if (val == 0) return const Text('Ingresos', style: TextStyle(color: StardewColors.emeraldGreen, fontWeight: FontWeight.bold));
                                  if (val == 1) return const Text('Gastos', style: TextStyle(color: StardewColors.rubyRed, fontWeight: FontWeight.bold));
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalIncome, color: StardewColors.emeraldGreen, width: 40, borderRadius: BorderRadius.circular(6))]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalExpense, color: StardewColors.rubyRed, width: 40, borderRadius: BorderRadius.circular(6))]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Lista de Transacciones
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Historial de Cuentas (SQLite)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                  const SizedBox(height: 16),
                  if (entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('No hay registros contables aún. ¡Haz clic en Registrar Movimiento!')),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final isIncome = entry['type'] == 'income';
                        final amount = (entry['amount'] as num).toDouble();

                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isIncome ? StardewColors.emeraldGreen.withOpacity(0.2) : StardewColors.rubyRed.withOpacity(0.2),
                              child: Icon(
                                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isIncome ? StardewColors.emeraldGreen : StardewColors.rubyRed,
                              ),
                            ),
                            title: Text(entry['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                            subtitle: Text('${entry['category']} • ${entry['date']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${isIncome ? '+' : '-'}${currencyFormatter.format(amount)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isIncome ? StardewColors.emeraldGreen : StardewColors.rubyRed,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: StardewColors.textMuted, size: 20),
                                  onPressed: () => provider.deleteLedgerEntry(entry['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: StardewColors.textMuted, fontSize: 13)),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, AppStateProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: StardewColors.cardBackground,
            title: const Text('Nuevo Registro Contable', style: TextStyle(color: StardewColors.primaryGold)),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Concepto (ej. Venta de Vinos Starfruit)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Monto (oro)'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Ingreso'),
                          value: 'income',
                          groupValue: _selectedType,
                          onChanged: (v) => setDialogState(() => _selectedType = v!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Gasto'),
                          value: 'expense',
                          groupValue: _selectedType,
                          onChanged: (v) => setDialogState(() => _selectedType = v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = _titleController.text.trim();
                  final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
                  if (title.isNotEmpty && amount > 0) {
                    provider.addLedgerEntry(
                      title: title,
                      type: _selectedType,
                      category: _selectedCategory,
                      amount: amount,
                      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    );
                    _titleController.clear();
                    _amountController.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: StardewColors.primaryGold, foregroundColor: Colors.black),
                child: const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );
  }
}
