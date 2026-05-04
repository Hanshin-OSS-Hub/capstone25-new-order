import 'package:flutter/material.dart';

const Color kAppBackgroundColor = Color(0xFFFAFAFA);
const Color kCardColor = Colors.white;
const Color kPrimaryColor = Color(0xFF2C5CD4); //0xFF2C5CD4 기존 컬러
const Color kTextColor = Color(0xFF1E1E1E);
const Color kSubTextColor = Color(0xFF727784);
const Color kBorderColor = Color(0xFFEAECEF);

const double kSquircleRadius = 28;

ShapeBorder kSquircleShape({
  double radius = kSquircleRadius,
  Color borderColor = kBorderColor,
  double borderWidth = 1,
}) {
  return ContinuousRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
    side: BorderSide(
      color: borderColor,
      width: borderWidth,
    ),
  );
}

List<BoxShadow> get kSoftShadow => const [
  BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  ),
];

class MinimalSquircleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final VoidCallback? onTap;

  const MinimalSquircleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = kSquircleRadius,
    this.color = kCardColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: kSoftShadow,
      ),
      child: Material(
        color: color,
        shape: kSquircleShape(radius: radius),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          customBorder: kSquircleShape(radius: radius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

ButtonStyle minimalPrimaryButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
  );
}

ButtonStyle minimalOutlinedButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: kTextColor,
    padding: const EdgeInsets.symmetric(vertical: 14),
    side: const BorderSide(color: kBorderColor),
    shape: ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
  );
}

InputDecoration minimalInputDecoration({
  required String labelText,
  String? hintText,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: kBorderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: kBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: kPrimaryColor,
        width: 1.2,
      ),
    ),
  );
}