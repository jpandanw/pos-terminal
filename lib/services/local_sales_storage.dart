import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSalesStorage {
  static const String _salesKey = 'local_sales';

  static Future<void> saveSale(Map<String, dynamic> saleData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> salesList = prefs.getStringList(_salesKey) ?? [];
    
    // Add timestamp if not exists
    if (!saleData.containsKey('timestamp')) {
      saleData['timestamp'] = DateTime.now().toIso8601String();
    }
    
    salesList.add(jsonEncode(saleData));
    await prefs.setStringList(_salesKey, salesList);
    await cleanUpOldSales();
  }

  static Future<List<Map<String, dynamic>>> getSales() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> salesList = prefs.getStringList(_salesKey) ?? [];
    
    // reverse to show newest first
    return salesList.map((s) => jsonDecode(s) as Map<String, dynamic>).toList().reversed.toList();
  }

  static Future<void> cleanUpOldSales() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> salesList = prefs.getStringList(_salesKey) ?? [];
    final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
    
    List<String> filteredList = salesList.where((s) {
      final data = jsonDecode(s);
      if (data['timestamp'] != null) {
        final date = DateTime.parse(data['timestamp']);
        return date.isAfter(twoWeeksAgo);
      }
      return false; // If no timestamp, discard it to be safe
    }).toList();
    
    if (filteredList.length != salesList.length) {
      await prefs.setStringList(_salesKey, filteredList);
    }
  }
}
