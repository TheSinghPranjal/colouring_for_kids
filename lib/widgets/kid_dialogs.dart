import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'kid_buttons.dart';

/// A simple yes / no question with big picture-led buttons.
Future<bool> confirmWithChild(
  BuildContext context, {
  required String question,
  required IconData icon,
  String yes = 'Yes',
  String no = 'No',
  Color yesColor = AppColors.coral,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: yesColor),
            const SizedBox(height: 12),
            Text(question, textAlign: TextAlign.center, style: AppTextStyles.heading),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                BigPillButton(
                  icon: Icons.close_rounded,
                  label: no,
                  color: AppColors.mintDeep,
                  height: 56,
                  onTap: () => Navigator.pop(context, false),
                ),
                BigPillButton(
                  icon: Icons.check_rounded,
                  label: yes,
                  color: yesColor,
                  height: 56,
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// A grown-up check: a sum a preschooler is unlikely to solve. Returns true
/// only when answered correctly.
Future<bool> showParentGate(BuildContext context) async {
  final rnd = math.Random();
  final a = 11 + rnd.nextInt(8);
  final b = 6 + rnd.nextInt(8);
  final answer = a + b;
  final options = {answer, answer + 1 + rnd.nextInt(3), answer - 1 - rnd.nextInt(3)}.toList()..shuffle(rnd);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('For grown-ups'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('To continue, tap the answer to $a + $b.', style: AppTextStyles.body),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            children: [
              for (final o in options)
                SizedBox(
                  width: 72,
                  height: 56,
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.pop(context, o == answer),
                    child: Text('$o', style: AppTextStyles.heading),
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel'))],
    ),
  );
  return ok ?? false;
}
