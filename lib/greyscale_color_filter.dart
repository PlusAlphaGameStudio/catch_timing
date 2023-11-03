import 'dart:ui';

ColorFilter get greyscaleColorFilter => ColorFilter.matrix(_greyscaleMatrix);

List<double> get _greyscaleMatrix {
  return <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}

List<double> calculateContrastMatrix(double contrast) {
  final m = List<double>.from(_greyscaleMatrix);

  m[0] = contrast;
  m[6] = contrast;
  m[12] = contrast;

  m[4] = ((1 - contrast) / 2) * 255;
  m[9] = ((1 - contrast) / 2) * 255;
  m[14] = ((1 - contrast) / 2) * 255;

  return m;
}
