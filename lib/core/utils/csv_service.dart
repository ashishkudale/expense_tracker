import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/categories/domain/entities/category.dart';

class CsvService {
  Future<String> exportTransactionsToCsv({
    required List<Transaction> transactions,
    required List<Category> categories,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final rows = <List<dynamic>>[];
    
    rows.add([
      'Date',
      'Type',
      'Category',
      'Amount',
      'Note',
    ]);
    
    final categoryMap = {
      for (var category in categories) category.id: category.name,
    };
    
    for (var transaction in transactions) {
      final categoryName = categoryMap[transaction.categoryId] ?? 'Unknown';
      rows.add([
        transaction.occurredOn.toIso8601String().split('T')[0],
        transaction.type == TransactionType.spend ? 'Expense' : 'Income',
        categoryName,
        transaction.amount.toStringAsFixed(2),
        transaction.note ?? '',
      ]);
    }
    
    final csv = const ListToCsvConverter().convert(rows);
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'transactions_${startDate.toIso8601String().split('T')[0]}_to_${endDate.toIso8601String().split('T')[0]}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csv);
    
    return file.path;
  }
  
  Future<void> shareTransactionsCsv({
    required List<Transaction> transactions,
    required List<Category> categories,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final filePath = await exportTransactionsToCsv(
      transactions: transactions,
      categories: categories,
      startDate: startDate,
      endDate: endDate,
    );
    
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Expense Report ${startDate.toIso8601String().split('T')[0]} to ${endDate.toIso8601String().split('T')[0]}',
    );
  }
  
  Future<List<Map<String, dynamic>>?> importTransactionsFromCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      
      if (result == null || result.files.single.path == null) {
        return null;
      }
      
      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();
      
      final csvTable = const CsvToListConverter().convert(csvString);
      
      if (csvTable.isEmpty || csvTable.length < 2) {
        throw Exception('Invalid CSV file format');
      }
      
      final headers = csvTable[0].map((e) => e.toString().toLowerCase()).toList();
      final transactions = <Map<String, dynamic>>[];
      
      for (var i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        final transaction = <String, dynamic>{};
        
        for (var j = 0; j < headers.length && j < row.length; j++) {
          transaction[headers[j]] = row[j];
        }
        
        transactions.add(transaction);
      }
      
      return transactions;
    } catch (e) {
      rethrow;
    }
  }
  
  List<Transaction> parseImportedTransactions({
    required List<Map<String, dynamic>> csvData,
    required List<Category> categories,
  }) {
    final transactions = <Transaction>[];
    final categoryMap = <String, String>{};
    
    for (var category in categories) {
      categoryMap[category.name.toLowerCase()] = category.id;
    }
    
    for (var row in csvData) {
      try {
        final dateStr = row['date']?.toString() ?? '';
        final typeStr = row['type']?.toString().toLowerCase() ?? '';
        final categoryName = row['category']?.toString().toLowerCase() ?? '';
        final amountStr = row['amount']?.toString() ?? '0';
        final note = row['note']?.toString() ?? '';
        
        final date = DateTime.tryParse(dateStr) ?? DateTime.now();
        final type = typeStr.contains('income') 
            ? TransactionType.earn 
            : TransactionType.spend;
        final categoryId = categoryMap[categoryName];
        final amount = double.tryParse(amountStr) ?? 0.0;
        
        if (categoryId != null && amount > 0) {
          transactions.add(Transaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: type,
            categoryId: categoryId,
            amount: amount,
            occurredOn: date,
            note: note.isEmpty ? null : note,
            createdAt: DateTime.now(),
          ));
        }
      } catch (e) {
        continue;
      }
    }
    
    return transactions;
  }
}