import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Squishes slightly when pressed. Used by every big tappable thing so the
/// app feels consistent and responsive to small fingers.
class Squishy extends StatefulWidget {
  const Squishy({super.key, required this.child, this.onTap, this.enabled = true});

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<Squishy> createState() => _SquishyState();
}

class _SquishyState extends State<Squishy> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: active ? (_) => setState(() => _down = true) : null,
      onTapCancel: active ? () => setState(() => _down = false) : null,
      onTapUp: active ? (_) => setState(() => _down = false) : null,
      onTap: active ? widget.onTap : null,
      child: AnimatedScale(
        scale: _down ? 0.94 : 1,
        duration: const Duration(milliseconds: 90),
        child: AnimatedOpacity(
          opacity: active ? 1 : 0.4,
          duration: const Duration(milliseconds: 150),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Large rounded pill with an icon and a short label.
class BigPillButton extends StatelessWidget {
  const BigPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.coral,
    this.foreground = Colors.white,
    this.height = 64,
    this.expand = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Color foreground;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Squishy(
        onTap: onTap,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: height * 0.4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(color, Colors.white, 0.18)!, color],
            ),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: height * 0.46),
              SizedBox(width: height * 0.16),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.button.copyWith(color: foreground, fontSize: height * 0.33),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round icon button with a tooltip and (optionally) a tiny caption.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 52,
    this.color = AppColors.card,
    this.iconColor = AppColors.ink,
    this.selected = false,
    this.caption,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final double size;
  final Color color;
  final Color iconColor;
  final bool selected;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final button = Squishy(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selected ? AppColors.butter : color,
          shape: BoxShape.circle,
          border: Border.all(color: selected ? AppColors.ink : AppColors.shadow, width: selected ? 3 : 1.5),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      label: tooltip,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: caption == null
            ? button
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  button,
                  const SizedBox(height: 2),
                  Text(caption!, style: AppTextStyles.caption.copyWith(fontSize: 12, color: AppColors.ink)),
                ],
              ),
      ),
    );
  }
}
