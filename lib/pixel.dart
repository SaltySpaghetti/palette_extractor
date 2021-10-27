import 'package:image/image.dart' as imageLib;

class Pixel implements Comparable {
  int x;
  int y;
  int red;
  int green;
  int blue;
  int alpha;

  Pixel({
    required this.x,
    required this.y,
    required this.red,
    required this.green,
    required this.blue,
    required this.alpha,
  });

  @override
  int compareTo(other) {
    var aHue = imageLib.rgbToHsl(this.red, this.green, this.blue)[0];
    var bHue = imageLib.rgbToHsl(other.red, other.green, other.blue)[0];

    if (aHue == bHue) return 0;
    return aHue > bHue ? 1 : -1;
  }
}
