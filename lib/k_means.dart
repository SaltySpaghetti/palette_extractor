import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:palette_extractor/pixel.dart';
import 'package:image/image.dart' as imageLib;

class KMeansRunner {
  Future<List<Color>> run(String assetName) async {
    print('Started');
    var image = await _getImage(assetName);

    if (image == null) {
      return [];
    }

    var pixels = _getPixels(image);

    //Setto K = 10 come nell'esempio
    var k = 10;
    var centroids = _extractCentroids(pixels, k);

    var clusters = List.generate(centroids.length, (index) => [centroids[index]]);

    //Valore preso totalmente a caso
    var maxIterations = 10;
    var palette = _performKMeanClustering(pixels, centroids, clusters, maxIterations);

    //Riodino in base all'HUE del colore
    palette.sort();

    List<Color> colorList = [
      ...palette.map((paletteColor) {
        return Color(
          imageLib.Color.fromRgb(
            paletteColor.blue,
            paletteColor.green,
            paletteColor.red,
          ),
        );
      })
    ];

    return colorList;
  }

  Future<imageLib.Image?> _getImage(String assetName) async {
    Uint8List bytes = (await rootBundle.load(assetName)).buffer.asUint8List();

    var image = imageLib.decodeImage(bytes)!;
    return imageLib.copyResize(image, height: 100);
  }

  List<Pixel> _getPixels(imageLib.Image image) {
    print('Getting pixels');

    List<Pixel> pixels = [];
    for (var i = 0; i < image.height; i++) {
      for (var j = 0; j < image.width; j++) {
        var pixel = image.getPixel(j, i);

        pixels.add(
          Pixel(
            x: j,
            y: i,
            red: imageLib.getRed(pixel),
            green: imageLib.getGreen(pixel),
            blue: imageLib.getBlue(pixel),
            alpha: imageLib.getAlpha(pixel),
          ),
        );
      }
    }

    print('Pixels extracted');
    return pixels;
  }

  List<Pixel> _extractCentroids(List pixels, int k) {
    return List.generate(k, (index) => pixels[Random().nextInt(pixels.length - 1)]);
  }

  List<Pixel> _performKMeanClustering(
    List<Pixel> imagePixels,
    List<Pixel> centroids,
    List<List<Pixel>> clusters,
    int maxIterations,
  ) {
    if (maxIterations == 0) {
      return centroids;
    }

    imagePixels.forEach((pixel) {
      var minDistance;
      var matchIndex;
      centroids.asMap().forEach((index, centroid) {
        var distance = _calculateEuclideanDistance(pixel, centroid);

        if ((minDistance == null || matchIndex == null) || distance < minDistance) {
          minDistance = distance;
          matchIndex = index;
        }
      });

      clusters[matchIndex].add(pixel);
    });

    clusters.asMap().forEach(
      (index, cluster) {
        centroids[index] = _calculateAveragePixel(cluster);
        cluster.clear();
      },
    );

    return _performKMeanClustering(
      imagePixels,
      centroids,
      clusters,
      maxIterations - 1,
    );
  }

  double _calculateEuclideanDistance(Pixel pixelP, Pixel pixelQ) {
    return sqrt(pow((pixelP.red - pixelQ.red), 2) +
        pow((pixelP.green - pixelQ.green), 2) +
        pow((pixelP.blue - pixelQ.blue), 2));
  }

  Pixel _calculateAveragePixel(List<Pixel> cluster) {
    Pixel averagePixel = Pixel(
      x: 0,
      y: 0,
      red: 0,
      green: 0,
      blue: 0,
      alpha: 0,
    );

    cluster.forEach((pixel) {
      averagePixel.red = averagePixel.red + pixel.red;
      averagePixel.green = averagePixel.green + pixel.green;
      averagePixel.blue = averagePixel.blue + pixel.blue;
      averagePixel.alpha = averagePixel.alpha + pixel.alpha;
      averagePixel.x = averagePixel.x + pixel.x;
      averagePixel.y = averagePixel.y + pixel.y;
    });

    averagePixel.red = averagePixel.red ~/ cluster.length;
    averagePixel.green = averagePixel.green ~/ cluster.length;
    averagePixel.blue = averagePixel.blue ~/ cluster.length;
    averagePixel.alpha = averagePixel.alpha ~/ cluster.length;
    averagePixel.x = averagePixel.x ~/ cluster.length;
    averagePixel.y = averagePixel.y ~/ cluster.length;

    return averagePixel;
  }
}
