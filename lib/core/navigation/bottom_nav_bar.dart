import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              isLightTheme ? (0.1 * 255).round() : (0.3 * 255).round(),
            ),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.library_books,
              label: 'Рецепты',
              isActive: activeIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.dehaze,
              label: 'Конспекты',
              isActive: activeIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Icons.book,
              label: 'Словарь',
              isActive: activeIndex == 2,
              onTap: () => onTap(2),
            ),
            _NavItem(
              icon: Icons.person,
              label: 'Профиль',
              isActive: activeIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final inactiveColor = isLightTheme ? Colors.grey[600] : Colors.grey[400];

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                isActive
                    ? BoxDecoration(
                      gradient: AppTheme.activeGradient,
                      shape: BoxShape.circle,
                    )
                    : null,
            child: Icon(
              icon,
              color: isActive ? Colors.white : inactiveColor,
              size: 20,
            ),
          ),
          if (!isActive) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: inactiveColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
