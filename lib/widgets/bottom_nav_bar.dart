import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class UseByBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const UseByBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Penggunaan MediaQuery untuk safe area bawah di HP
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.padding.bottom;
    final bottomPadding = bottomInset > 0 ? bottomInset + 4 : 12.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8, 8, 8, bottomPadding),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: AppTheme.mintBorder.withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _NavItem(
              index: 0,
              selectedIndex: selectedIndex,
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Beranda',
              onTap: onTap,
            ),
          ),
          Expanded(
            child: _NavItem(
              index: 1,
              selectedIndex: selectedIndex,
              icon: Icons.inventory_2_outlined,
              activeIcon: Icons.inventory_2_rounded,
              label: 'Pantau',
              onTap: onTap,
            ),
          ),
          Expanded(
            child: _NavItem(
              index: 2,
              selectedIndex: selectedIndex,
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profil',
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    final isSmall = MediaQuery.of(context).size.width < 360;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Align(
        alignment: Alignment.center,
        heightFactor: 1.25,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? (isSmall ? 10 : 16) : 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.mintLight : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(
                    color: AppTheme.primaryMint.withValues(alpha: 0.35),
                    width: 1.2,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppTheme.mintDark : AppTheme.textLight,
                size: isSmall ? 20 : 22,
              ),
              if (isSelected) ...[
                SizedBox(width: isSmall ? 4 : 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppTheme.mintDark,
                    fontSize: isSmall ? 12 : 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
