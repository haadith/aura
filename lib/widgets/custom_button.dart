import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double height;
  final bool haptic;
  final double fontSize;

  const CustomButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white,
    this.borderRadius = 12,
    this.height = 56,
    this.haptic = true,
    this.fontSize = 16,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.haptic) {
          HapticFeedback.mediumImpact();
        }
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: SizedBox(
        width: double.infinity,
        height: widget.height,
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: Icon(widget.icon, color: widget.textColor),
          label: Text(
            widget.label,
            style: TextStyle(color: widget.textColor, fontSize: widget.fontSize),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            elevation: _isPressed ? 1 : 15,
          ),
        ),
      ),
    );
  }
}
