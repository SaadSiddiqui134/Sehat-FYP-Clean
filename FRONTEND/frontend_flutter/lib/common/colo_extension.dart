import 'package:flutter/material.dart';

class TColor {
  // Function to convert a hex string to Color
  static Color hexToColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
  }

  // Using hexToColor for colors
  static Color get backgroundColor2 => hexToColor('#123524');
  static Color get backgroundColor => hexToColor('#006A67');
  static Color get primaryColor1 => hexToColor('#16423C');
  static Color get primaryColor2 => hexToColor('#6A9C89');

  static Color get secondaryColor1 => hexToColor('#C4DAD2');
  static Color get secondaryColor2 => hexToColor('#E9EFEC');

  static List<Color> get primaryG => [primaryColor2, primaryColor1];
  static List<Color> get secondaryG => [secondaryColor2, secondaryColor1];

  static Color get black => hexToColor('#181C14');
  static Color get gray => hexToColor('#3C3D37');
  static Color get white => Colors.white;
  static Color get lightGray => hexToColor('#F7F8F8');
  static Color get lightGray2 => hexToColor('#F7F8F8');
}
