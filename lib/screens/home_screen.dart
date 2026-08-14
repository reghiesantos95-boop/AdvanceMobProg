import 'package:flutter/material.dart';

import '../widgets/custom_text.dart';
import 'product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Men Fashion', 'Chat', 'Profile'];

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: CustomText(
            text: titles[_selectedIndex],
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          actions: [
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
          children: const [
            ProductScreen(),
            _PlaceholderScreen(
              icon: Icons.chat_bubble_outline,
              title: 'Chat',
              message: 'Messages will appear here.',
            ),
            _PlaceholderScreen(
              icon: Icons.person_outline,
              title: 'Profile',
              message: 'Profile details will appear here.',
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom),
              label: 'Men Fashion',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: colors.primary),
            const SizedBox(height: 12),
            CustomText(
              text: title,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            CustomText(
              text: message,
              fontSize: 14,
              color: colors.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
