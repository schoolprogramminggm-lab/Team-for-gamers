import 'package:flutter/material.dart';
import 'package:team_for_gamers/app/theme/app_colors.dart';

/// Search bar with neon purple glow on focus
/// 
/// Modern gaming-style search input with icon and neon accent
class NeonSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const NeonSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search players, teams or games...',
    this.onChanged,
    this.onTap,
  });

  @override
  State<NeonSearchBar> createState() => _NeonSearchBarState();
}

class _NeonSearchBarState extends State<NeonSearchBar> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isFocused ? AppColors.primary : AppColors.glassBorder,
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: AppColors.textSecondary),
            prefixIcon: Icon(
              Icons.search,
              color: _isFocused ? AppColors.primary : AppColors.textSecondary,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
