import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'analysis_screen.dart';
import 'history_page.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const SoilInputPage(),
      const HistoryPage(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(key: ValueKey(index), child: screens[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => index = 1),
        backgroundColor: Colors.orange.shade600,
        child: const Icon(Icons.analytics),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SizedBox(
        height: 84,
        child: BottomAppBar(
          color: Theme.of(context).colorScheme.surface,
          elevation: 8,
          notchMargin: 8,
          shape: const AutomaticNotchedShape(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            StadiumBorder(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  label: "Home",
                  icon: Icons.home,
                  selected: index == 0,
                  onTap: () => setState(() => index = 0),
                ),
                _NavItem(
                  label: "Analysis",
                  icon: Icons.analytics,
                  selected: index == 1,
                  onTap: () => setState(() => index = 1),
                  activeColor: Colors.orange.shade600,
                ),
                const SizedBox(width: 56),
                _NavItem(
                  label: "History",
                  icon: Icons.history,
                  selected: index == 2,
                  onTap: () => setState(() => index = 2),
                ),
                _NavItem(
                  label: "Profile",
                  icon: Icons.person,
                  selected: index == 3,
                  onTap: () => setState(() => index = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color? activeColor;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.activeColor,
  });
  @override
  Widget build(BuildContext context) {
    final color = selected
        ? (activeColor ?? Theme.of(context).colorScheme.primary)
        : Colors.grey.shade400;
    return SizedBox(
      width: 68,
      height: 56,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
