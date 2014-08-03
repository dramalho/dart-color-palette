import 'color-palette.dart';

import 'dart:html';

void main() {
  var img = querySelector('.orig');
  window.onLoad.listen((e) {
    processPalette(img);
  });
}

List sortColorMapByRGB(Map colorMap) {
  var list = colorMap.values.toList();
  list.sort( (x, y) => x['rgb'].reduce((a,b) => a + b).compareTo(y['rgb'].reduce((a,b) => a + b)));

  return list;
}

List sortColoMapByFrequency(Map colorMap) {
  var list = colorMap.values.toList();
  list.sort( (x, y) => x['count'].compareTo(y['count']));

  return list;
}

void transformImage(ImageElement img) {
  CanvasElement canvas = querySelector('#transformed');

  ImageData pixels = new ColorPalette(img).transformImage();

  canvas.width = pixels.width;
  canvas.height = pixels.height;
  canvas.getContext('2d') as CanvasRenderingContext2D
      ..putImageData(pixels, 0, 0);
}

String colorPercentage(ImageElement img, int pixelCount ) {
  return (pixelCount / (img.width * img.height ) * 100).toStringAsFixed(2);
}

void processPalette(ImageElement img) {
  var results_el = querySelector('#results');

  var sortedColors = sortColorMapByRGB( new ColorPalette(img).getColors() );

  // sortedColorMapKeys(colors).forEach( (key) {
  sortedColors.forEach( (value) {
    var color_el = new LIElement();
    var rgb = value['rgb'];
    var count = value['count'];
    var countLabel = new SpanElement();
    countLabel.appendText("${colorPercentage(img, value['count'])} %");

    color_el.style.backgroundColor = "rgba(${rgb[0]}, ${rgb[1]}, ${rgb[2]}, 1.0)";


    color_el.children.add(countLabel);

    results_el.children.add(color_el);
  });
}
