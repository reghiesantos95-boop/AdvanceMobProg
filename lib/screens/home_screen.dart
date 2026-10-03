import 'package:flutter/material.dart';

import '../widgets/custom_text.dart';
import 'cart_screen.dart';
import 'chat_screen.dart';
import 'product_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

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
    final titles = ['Men Fashion', 'Chat', 'Cart', 'Profile'];

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
            ChatScreen(),
            CartScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavButton(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Shop',
                  selected: _selectedIndex == 0,
                  onTap: () => _goToPage(0),
                ),
                _NavButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  selected: _selectedIndex == 1,
                  onTap: () => _goToPage(1),
                ),
                _NavButton(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Cart',
                  selected: _selectedIndex == 2,
                  onTap: () => _goToPage(2),
                ),
                _NavButton(
                  icon: Icons.person,
                  label: 'Profile',
                  selected: _selectedIndex == 3,
                  onTap: () => _goToPage(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToPage(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = selected ? colors.primary : colors.onSurfaceVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        width: 76,
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            CustomText(
              text: label,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
