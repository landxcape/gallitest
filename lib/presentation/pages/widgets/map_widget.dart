import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:galli_vector_package/galli_vector_package.dart';
import 'package:gallitest/app/constants.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapLibreMapController controller;
  static Future<Uint8List> getUint8ListFromSvg(
    String assetName, {
    Size size = const Size(48, 48),
    Color color = const Color(0xFF000000),
    BlendMode blendMode = BlendMode.srcIn,
  }) async {
    final byte = await getBytesFromSvg(assetName,
        size: size, color: color, blendMode: blendMode);
    return byte.buffer.asUint8List();
  }

  static Future<ByteData> getBytesFromSvg(
    String assetName, {
    Size size = const Size(48, 48),
    Color color = const Color(0xFF000000),
    BlendMode blendMode = BlendMode.srcIn,
  }) async {
    final pictureInfo = await vg.loadPicture(
      SvgAssetLoader(assetName),
      null,
    );

    double devicePixelRatio =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    int width = (size.width * devicePixelRatio).toInt();
    int height = (size.height * devicePixelRatio).toInt();

    final scaleFactor = min(
      width / pictureInfo.size.width,
      height / pictureInfo.size.height,
    );

    final recorder = ui.PictureRecorder();

    ui.Canvas(recorder)
      ..scale(scaleFactor)
      ..drawPicture(pictureInfo.picture)
      ..drawColor(color, blendMode);

    final rasterPicture = recorder.endRecording();

    final image = rasterPicture.toImageSync(width, height);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    return bytes;
  }

  Future<Uint8List> _initCustomMarkers() async {
    final stationMarkerIcon = await getUint8ListFromSvg(
      'assets/station_map_marker-ic.svg',
      size: const Size(15, 30),
      blendMode: BlendMode.modulate,
      color: Colors.yellow,
    );
    return stationMarkerIcon;
  }

  addFill() async {
    await controller.addGeoJsonSource(
      'fillSourceId',
      {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'id': 'id',
            'properties': {},
            'geometry': <String, dynamic>{
              'type': 'Polygon',
              'coordinates': [
                [
                  [85.32641149144914, 27.687458775707956],
                  [85.33074582639657, 27.681986629659708],
                  [85.33370700560444, 27.68650869679327],
                  [85.32988761900164, 27.689092843292404],
                  [85.32641149144914, 27.687458775707956],
                ]
              ],
            },
          },
        ],
      },
    );
    await controller.addFillLayer(
      'fillSourceId',
      'fillLayerId',
      FillLayerProperties(
        fillColor: '#0c0caa',
        fillOpacity: 0.8,
      ),
    );
  }

  updateFill() async {
    await controller.setGeoJsonSource(
      'fillSourceId',
      {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'id': 'id',
            'properties': {},
            'geometry': <String, dynamic>{
              'type': 'Polygon',
              'coordinates': [
                [
                  [85.32422280900494, 27.711491975561685],
                  [85.33074582639657, 27.681986629659708],
                  [85.33370700560444, 27.68650869679327],
                  [85.32988761900164, 27.689092843292404],
                  [85.32641149144914, 27.687458775707956],
                  [85.32422280900494, 27.711491975561685],
                ]
              ],
            },
          },
        ],
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GalliMap(
      size: (height: double.maxFinite, width: double.maxFinite),
      authToken: "xyz",
      showCurrentLocation: true,
      showSearchWidget: false,
      showThree60Widget: false,
      showCurrentLocationButton: true,
      initialCameraPostion:
          CameraPosition(target: Constants.defaultLatLng, zoom: 13),
      onMapCreated: (c) {
        controller = c;
        addFill();
      },
      rotateGestureEnabled: false,
      tiltGestureEnabled: false,
      showCompass: false,
      minMaxZoomPreference: const MinMaxZoomPreference(
        Constants.minZoomLevel,
        Constants.maxZoomLevel,
      ),
      onMapClick: (latLng) {
        updateFill();
      },
    );
  }
}
