import 'package:Nutech/historytransaction/transaction_history_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<TransactionHistory> transactions = [];
  int offset = 0;
  int limit = 5;
  bool isLoading = false;
  bool hasMore = true;
  Future<double> futureBalance;

  @override
  void initState() {
    super.initState();
    _loadTransactionHistory();
    futureBalance = _fetchBalance();
  }

  Future<void> _loadTransactionHistory() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    try {
      final response = await TransactionService.fetchTransactionHistory(token, offset, limit);
      if (response['status'] == 0) {
        List<dynamic> records = response['data']['records'];
        setState(() {
          transactions.addAll(records.map((record) => TransactionHistory.fromJson(record)).toList());
          offset += limit;
          hasMore = records.length == limit;
        });
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      print('Error loading transaction history: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<double> _fetchBalance() async {
    // Simulating fetching balance from SharedPreferences or API
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('balance') ?? 0.0; // Return balance
  }

  Widget _buildBalance() {
    return FutureBuilder<double>(
      future: futureBalance,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final saldo = snapshot.data;
          return Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: 16.0),
            child: Container(
              height: 100.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.red, // Background color
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Jumlah Saldo',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    Text(
                      'Rp ${saldo.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Center(child: Text('No data found'));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalance(),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(transaction.description),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nomor Invoice: ${transaction.invoiceNumber}'),
                          Text('Total: Rp ${transaction.totalAmount}'),
                          Text('Tanggal: ${transaction.createdOn}'),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
            if (hasMore && !isLoading)
              ElevatedButton(
                onPressed: _loadTransactionHistory,
                child: Text('Show More'),
              ),
            if (isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
