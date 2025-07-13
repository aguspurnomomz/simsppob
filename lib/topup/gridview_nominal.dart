import 'package:flutter/material.dart';

class TopUpGridPage extends StatelessWidget {
  final List<int> nominalTopUp = [10000, 20000, 50000, 100000, 250000, 500000];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nominal Top Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Jumlah kolom dalam grid
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2, // Rasio tinggi dan lebar
          ),
          itemCount: nominalTopUp.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Lakukan aksi saat nominal di-tap, misalnya menyimpan ke controller
                print('Selected amount: ${nominalTopUp[index]}');
                // Anda dapat menyimpan nominal ke controller atau melanjutkan proses top up
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${nominalTopUp[index]}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
