import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class MagicButton extends StatefulWidget {
  static const Duration _defaultDuration = Duration(seconds: 2);
  static const double _defaultTextSize = 18;
  static const List<double> _stops = [0, 0.16, 0.25, 0.37, 0.5];
  static const double _defaultPadding = 8;

  static const double _defaultScaling = 1.05;
  static const double _defaultIconSize = 20;
  final String? label;
  final TextStyle? labelStyle;
  final TextStyle? labelHoveredStyle;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconHoverColor;
  final double? iconSize;

  final Duration animationDuration;

  final BorderRadius? borderRadius;

  final Color? buttonColor;
  final List<Color>? animatingColors;
  final double? padding;

  final VoidCallback? onPress;

  const MagicButton({
    super.key,
    this.label,
    this.icon,
    this.animationDuration = _defaultDuration,
    this.borderRadius,
    this.buttonColor,
    this.animatingColors,
    this.padding,
    this.onPress,
    this.labelStyle,
    this.labelHoveredStyle,
    this.iconColor,
    this.iconHoverColor,
    this.iconSize,
  });

  @override
  State<MagicButton> createState() => _MagicButtonState();
}

class _MagicButtonState extends State<MagicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late final Color _buttonColor;
  late final List<Color> _animatingColor;
  late double _innerPadding = 30;

  late TextStyle _textStyle;
  late TextStyle _hoveredTextStyle;

  late TextStyle _currentTextStyle;

  late double _scale;

  late Color _currentIconColor;

  late Color _iconColor;
  late Color _iconHoveredColor;

  late double _iconSize;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();
    _buttonColor = widget.buttonColor ?? const Color(0xE61E1637);
    _animatingColor = widget.animatingColors ??
        [Color(0xFFcc00ff), Color(0xFF4d00ff), Color(0xFF00b2ff)];
    _innerPadding = widget.padding ?? MagicButton._defaultPadding;
    _textStyle = widget.labelStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: MagicButton._defaultTextSize,
          fontWeight: FontWeight.w500,
        );
    _hoveredTextStyle = widget.labelHoveredStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: MagicButton._defaultTextSize,
          fontWeight: FontWeight.w500,
        );
    _currentTextStyle = _textStyle;
    _scale = 1.0;
    _iconColor = widget.iconColor ?? Colors.white;
    _iconHoveredColor = widget.iconHoverColor ?? Colors.amber;
    _currentIconColor = _iconColor;
    _iconSize = widget.iconSize ?? MagicButton._defaultIconSize;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _HoverWidget(
      onHover: () {
        _innerPadding = 0;
        _currentTextStyle = _hoveredTextStyle;
        _scale = MagicButton._defaultScaling;
        _currentIconColor = _iconHoveredColor;
        setState(() {});
      },
      onExit: () {
        _innerPadding = widget.padding ?? MagicButton._defaultPadding;
        _currentTextStyle = _textStyle;
        _scale = 1.0;
        _currentIconColor = _iconColor;
        setState(() {});
      },
      child: GestureDetector(
        onTap: widget.onPress,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                gradient: SweepGradient(
                  center: Alignment(0, 0),
                  startAngle: 0.0,
                  endAngle: math.pi * 2,
                  transform: GradientRotation(
                    _animationController.value * math.pi * 2,
                  ),
                  colors: [_buttonColor, ..._animatingColor, _buttonColor],
                  stops: MagicButton._stops,
                ),
              ),
              child: AnimatedPadding(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOutExpo,
                padding: EdgeInsets.all(_innerPadding),
                // Border thickness
                child: Container(
                  decoration: BoxDecoration(
                    color: _buttonColor.withValues(
                        colorSpace: ColorSpace.sRGB,
                        alpha: 0.85), // Dark background color
                    borderRadius: widget.borderRadius?.subtract(
                      BorderRadius.circular(2),
                    ),
                  ),
                  child: Center(
                    child: AnimatedScale(
                      scale: _scale,
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeOutSine,
                      child: Row(
                        spacing: 4,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left:
                                      8.0), // Example padding to the right of the icon
                              child: Icon(
                                widget.icon,
                                color: _currentIconColor,
                                size: _iconSize,
                              ),
                            ),
                          //   widget.icon!,
                          if (widget.label != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 8.0), // Example horizontal padding
                              child:
                                  Text(widget.label!, style: _currentTextStyle),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HoverWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onHover;
  final VoidCallback onExit;

  const _HoverWidget({
    required this.child,
    required this.onHover,
    required this.onExit,
  });

  @override
  State<_HoverWidget> createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<_HoverWidget> {
  @override
  Widget build(BuildContext context) {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return GestureDetector(
          child: widget.child,
          onLongPressDown: (_) => widget.onHover(),
          onLongPressUp: () => widget.onExit(),
        );
      } else {
        return MouseRegion(
          child: widget.child,
          onHover: (_) => widget.onHover(),
          onExit: (_) => widget.onExit(),
        );
      }
    } catch (_) {
      return MouseRegion(
        child: widget.child,
        onHover: (_) => widget.onHover(),
        onExit: (_) => widget.onExit(),
      );
    }
  }
}
