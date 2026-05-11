import 'package:flutter/material.dart';

/// Круглая кнопка: короткое сжатие при нажатии.
class ScaleCalcButton extends StatefulWidget {
  const ScaleCalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.background,
    this.foreground,
    this.fontSize = 22,
    this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Color? background;
  final Color? foreground;
  final double fontSize;
  final Widget? child;

  @override
  State<ScaleCalcButton> createState() => _ScaleCalcButtonState();
}

class _ScaleCalcButtonState extends State<ScaleCalcButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 85),
  );
  late final Animation<double> _s = Tween(begin: 1.0, end: 0.93).animate(
    CurvedAnimation(parent: _c, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.background ?? const Color(0xFFECECEC);
    final fg = widget.foreground ?? const Color(0xFF424242);
    return ScaleTransition(
      scale: _s,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: Colors.black12,
          highlightColor: Colors.black06,
          onTapDown: (_) => _c.forward(),
          onTap: () {
            _c.reverse();
            widget.onTap();
          },
          onTapCancel: () => _c.reverse(),
          child: Center(
            child: widget.child ??
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
