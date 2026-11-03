import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import 'kid_buttons.dart';

/// Big back button + title used at the top of every gallery-style screen.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.trailing, this.onBack});

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onTap: onBack ?? () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title,
              semanticsLabel: title,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
