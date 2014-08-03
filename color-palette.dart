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
