import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_card_quiz_app/pages/card_edit.dart';
import 'package:flash_card_quiz_app/pages/card_list.dart';
import 'package:flash_card_quiz_app/pages/profile.dart';
import 'package:flash_card_quiz_app/widgets/list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/authentication_services.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final User? user = AuthenticationService().currentUser;
  int _activeIndex = 0;

  // Define your pages here
  final List<Widget> _pages = [CardsList(), CardEditPage(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    Provider.of<CardListProvider>(context, listen: false).loadUserCards();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthenticationService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const LoginPage();
          }
          return Consumer<CardListProvider>(
            builder: (context, cardListProvider, child) {
              return Scaffold(
                backgroundColor: const Color.fromRGBO(0, 192, 255, 1.0),
                body: IndexedStack(
                  index: _activeIndex,
                  children: _pages,
                ),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _activeIndex,
                  onTap: (index) => setState(() => _activeIndex = index),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      label: 'Add Card',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
