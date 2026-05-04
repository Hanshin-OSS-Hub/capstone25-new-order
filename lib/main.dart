import 'package:flutter/material.dart';

import 'app_design.dart';

import 'screens/home_screen.dart';
import 'screens/near_search_page.dart';
import 'screens/favorites_page.dart';
import 'screens/order_history_page.dart';
import 'screens/mypage_screen.dart';

void main() {
  runApp(const NewOrderApp());
}

class NewOrderApp extends StatelessWidget {
  const NewOrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '원격 주문 앱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: kAppBackgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          background: kAppBackgroundColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kAppBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: kTextColor),
          titleTextStyle: TextStyle(
            fontFamily: 'Pretendard',
            color: kTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Color(0xFF8A8F98),
          selectedLabelStyle: TextStyle(fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/home': (_) => const HomeScreen(),
        '/near': (_) => const NearSearchPage(),
        '/favorites': (_) => const FavoritesPage(),
        '/orders': (_) => const OrderHistoryPage(),
        '/mypage': (_) => const MyPageScreen(),
      },
    );
  }
}