import 'dart:html';
import "package:neuquant/neuquant.dart";

class ColorPalette {
  ImageData pixels;

  ColorPalette(ImageElement img) {
    pixels = getPixels(img);
  }

  // Get image pixels from image element.
  ImageData getPixels(ImageElement img) {
    var canvas = new CanvasElement(width: img.width, height: img.height);

    CanvasRenderingContext2D context = canvas.getContext('2d');
    context.drawImage(img, 0, 0);
    return context.getImageData(0, 0, canvas.width, canvas.height);
  }

  Map getColors() {
    var d = pixels.data;
    var m = {};

    neuquant(d, 10);

    for (var i = 0; i < d.length; i += 4) {
      var idx = (d[i] + d[i+1] + d[i+2]);
      // var idx = d[i] + d[i+1] + d[i+2];

      if (m[idx] == null) {
        m[idx] = {'rgb': [d[i],d[i+1],d[i+2]], 'count': 0};
      }

      m[idx]['count'] += 1;
    }

    // Remove under-populated colors (less than 1% of pixels)
    m.keys.toList().forEach( (key) {
      if (m[key]['count'] < (d.length / 4 / 200)) {
        m.remove(key);
      }
    });

    return m;
  }
}

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

void processPalette(ImageElement img) {
  var results_el = querySelector('#results');

  var sortedColors = sortColorMapByRGB( new ColorPalette(img).getColors() );

  // sortedColorMapKeys(colors).forEach( (key) {
  sortedColors.forEach( (value) {
    var color_el = new LIElement();
    var rgb = value['rgb'];
    var count = value['count'];
    var countLabel = new SpanElement();
    countLabel.appendText(count.toString());

    color_el.style.backgroundColor = "rgba(${rgb[0]}, ${rgb[1]}, ${rgb[2]}, 1.0)";


    color_el.children.add(countLabel);

    results_el.children.add(color_el);
  });
}
