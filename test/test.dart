import 'package:flutter_test/flutter_test.dart';
import 'package:cam/main.dart';

void main() {
  List<double> blende = [
    0.7,
    1,
    1.4,
    2,
    2.8,
    4,
    5.6,
    8,
    11,
    16,
    22,
    32,
    45,
    64,
    91,
    128
  ];

  List<double> isos = [
    12,
    25,
    50,
    100,
    200,
    400,
    800,
    1600,
    3200,
    6400,
    12500,
    25000
  ];

  List<double> times = [
    1 / 1000,
    1 / 500,
    1 / 250,
    1 / 125,
    1 / 60,
    1 / 30,
    1 / 15,
    1 / 8,
    1 / 4,
    1 / 2,
    1.0,
  ];

  group('Blende', () {
    test('value should be 1.0', () {
      expect(round(blende, 1.0, true), 1);
    });

    test('value should be 1.4', () {
      expect(round(blende, 1.4, true), 1.4);
    });

    test('value should be 1.4', () {
      expect(round(blende, 1.6, true), 1.4);
    });

    test('value should be 2.0', () {
      expect(round(blende, 1.7, true), 2.0);
    });

    test('value should be 2.0', () {
      expect(round(blende, 1.8, true), 2.0);
    });

    test('value should be 0.7', () {
      expect(round(blende, 0.2, true), 0.7);
    });

    test('value should be 16.0', () {
      expect(round(blende, 14, true), 16.0);
    });

    test('value should be 16.0', () {
      expect(round(blende, 16, true), 16.0);
    });

    test('value should be 16.0', () {
      expect(round(blende, 18, true), 16.0);
    });
  });

  group('iso Differences', () {
    test('difference should be 2', () {
      expect(difference(isos, 100, 400), 2);
    });
    test('difference should be 1', () {
      expect(difference(isos, 100, 200), 1);
    });
    test('difference should be -1', () {
      expect(difference(isos, 100, 50), -1);
    });
    test('difference should be 0', () {
      expect(difference(isos, 100, 100), 0);
    });
    test('difference should be -4', () {
      expect(difference(isos, 1600, 100), -4);
    });
    test('difference should be 5', () {
      expect(difference(isos, 50, 1600), 5);
    });
  });

  group('blende Differences', () {
    test('difference should be 1', () {
      expect(difference(blende, 1.4, 2), 1);
    });
    test('difference should be 4', () {
      expect(difference(blende, 1.4, 5.6), 4);
    });
    test('difference should be 0', () {
      expect(difference(blende, 8.0, 8.0), 0);
    });
    test('difference should be -3', () {
      expect(difference(blende, 16, 5.6), -3);
    });
  });

  /*
                  1 / 1000,
                  1 / 500,
                  1 / 250,
                  1 / 125,
                  1 / 60,
                  1 / 30,
                  1 / 15,
                  1 / 8,
                  1 / 4,
                  1 / 2,
                  1.0,
    */

  group('time Differences', () {
    test('difference should be 1', () {
      expect(difference(times, 1 / 30, 1 / 15), 1);
    });
    test('difference should be 4', () {
      expect(difference(times, 1 / 60, 1 / 4), 4);
    });
    test('difference should be 0', () {
      expect(difference(times, 1 / 250, 1 / 250), 0);
    });
    test('difference should be -3', () {
      expect(difference(times, 1 / 8, 1 / 60), -3);
    });
  });

  group('complete Differences', () {
    test('difference should be 1', () {
      expect(
          completeDifference(
              isos, blende, times, 100, 200, 5.6, 5.6, 1 / 250, 1 / 250),
          1);
    });
    test('difference should be 1', () {
      expect(
          completeDifference(
              isos, blende, times, 100, 100, 5.6, 4.8, 1 / 250, 1 / 250),
          1);
    });
    test('difference should be 2', () {
      expect(
          completeDifference(
              isos, blende, times, 100, 100, 16.0, 11.0, 1 / 250, 1 / 125),
          2);
    });
    test('difference should be 3', () {
      expect(
          completeDifference(
              isos, blende, times, 100, 200, 16.0, 11.0, 1 / 250, 1 / 125),
          3);
    });
    test('difference should be 1', () {
      expect(
          completeDifference(
              isos, blende, times, 100, 50, 16.0, 11.0, 1 / 250, 1 / 125),
          1);
    });
    test('difference should be -1', () {
      expect(
          completeDifference(
              isos, blende, times, 3200, 800, 2.0, 2.8, 1 / 125, 1 / 30),
          -1);
    });
    test('difference should be 1', () {
      expect(
          completeDifference(
              isos, blende, times, 800, 3200, 2.8, 2.0, 1 / 30, 1 / 125),
          1);
    });
    test('difference should be greater than 0', () {
      expect(
          completeDifference(
                  isos, blende, times, 800, 800, 16.0, 16.0, 1 / 250, 1 / 125) >
              0,
          true);
    });
    test('difference should be greater than 0', () {
      expect(
          completeDifference(
                  isos, blende, times, 100, 100, 16.0, 11.0, 1 / 250, 1 / 250) >
              0,
          true);
    });
    test('difference should be greater than 0', () {
      expect(
          completeDifference(
                  isos, blende, times, 100, 100, 16.0, 5.6, 1 / 250, 1 / 30) >
              0,
          true);
    });
    // kmz horizont smaller, nokia 7.1 smaller
    test('difference should be 5', () {
      expect(
          completeDifference(
                  isos, blende, times, 100, 100, 16.0, 2.0, 1 / 250, 1 / 500),
          5);
    });
    // nokia 7.1 smaller, kmz horizont smaller
    test('difference should be -5', () {
      expect(
          completeDifference(
                  isos, blende, times, 100, 100, 2.0, 16.0, 1 / 500, 1 / 250),
          -5);
    });
        test('difference should smaller than 0', () {
      expect(
          completeDifference(
                  isos, blende, times, 3200, 50, 16.0, 2.0, 1 / 250, 1 / 500) < 0,
          true);
    });
  });

  group('Distances', () {
    test('distance should be 5.5m-', () {
      expect(getDistance("2.8"), "5.5m-");
    });
    test('distance should be 3.8m-', () {
      expect(getDistance("4.0"), "3.8m-");
    });
    test('distance should be 2.9m-', () {
      expect(getDistance("5.6"), "2.9m-");
    });
    test('distance should be 2m-', () {
      expect(getDistance("8.0"), "2m-");
    });
    test('distance should be 1.5m-', () {
      expect(getDistance("11.0"), "1.5m-");
    });
    test('distance should be 1m-', () {
      expect(getDistance("16.0"), "1m-");
    });
    test('distance should be -', () {
      expect(getDistance("16"), "-");
    });
    test('distance should be -', () {
      expect(getDistance("4"), "-");
    });
  });
}
