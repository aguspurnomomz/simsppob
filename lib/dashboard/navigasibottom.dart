import 'package:Nutech/historytransaction/transaction_history.dart';
import 'package:Nutech/profile/profile.dart';
import 'package:Nutech/topup/topup.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'setting.dart';

class NavigasiBottom extends StatefulWidget {
  const NavigasiBottom({Key key}) : super(key: key);

  @override
  State<NavigasiBottom> createState() => _NavigasiBottomState();
}

class _NavigasiBottomState extends State<NavigasiBottom> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    TopUpBalancePage(),
    TransactionHistoryPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Topup',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Trans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
