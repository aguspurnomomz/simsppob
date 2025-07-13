import 'package:http/http.dart' as http;
import 'dart:convert';

class TransactionService {
  static Future<Map<String, dynamic>> fetchTransactionHistory(String token, int offset, int limit) async {
    final response = await http.get(
      Uri.parse('https://take-home-test-api.nutech-integrasi.com/transaction/history?offset=$offset&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal Mengambil Data');
    }
  }
}

class TransactionHistory {
  final String invoiceNumber;
  final String transactionType;
  final String description;
  final int totalAmount;
  final String createdOn;

  TransactionHistory({
    this.invoiceNumber,
    this.transactionType,
    this.description,
    this.totalAmount,
    this.createdOn,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      invoiceNumber: json['invoice_number'],
      transactionType: json['transaction_type'],
      description: json['description'],
      totalAmount: json['total_amount'],
      createdOn: json['created_on'],
    );
  }
}
