import 'dart:ui';

class ColorsUtil extends Color{

  ColorsUtil(String hex, {double? alpha}): super.fromRGBO(_getColorFromHex
    (hex).red, _getColorFromHex
    (hex).green, _getColorFromHex
    (hex).blue, alpha ?? 1.0);

  static Color _getColorFromHex(String hex) {
    String colorStr = hex;
    // colorString未带0xff前缀并且长度为6
    if (!colorStr.startsWith('0xff') && colorStr.length == 6) {
      colorStr = '0xff$colorStr';
    }
    // colorString为8位，如0x000000
    if (colorStr.startsWith('0x') && colorStr.length == 8) {
      colorStr = colorStr.replaceRange(0, 2, '0xff');
    }
    // colorString为7位，如#000000
    if (colorStr.startsWith('#') && colorStr.length == 7) {
      colorStr = colorStr.replaceRange(0, 1, '0xff');
    }
    // 先分别获取色值的RGB通道
    Color color = Color(int.parse(colorStr));
    return color;
  }
}