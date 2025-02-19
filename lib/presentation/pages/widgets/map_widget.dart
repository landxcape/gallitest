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
  static Future<Uint8List> getUint8ListFromSvg(
    String assetName, {
    Size size = const Size(48, 48),
    Color color = const Color(0xFF000000),
    BlendMode blendMode = BlendMode.srcIn,
  }) async {
    final byte = await getBytesFromSvg(assetName, size: size, color: color, blendMode: blendMode);
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

    double devicePixelRatio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
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

  void _onStylesLoadedCallback(MapLibreMapController controller) async {
    final stationMarkerIcon = await _initCustomMarkers();
    controller.addImage('symbolIcon', stationMarkerIcon);

    await controller.setSymbolIconAllowOverlap(true);

    await controller.addSource(
      'fillSourceId',
      GeojsonSourceProperties(
        data: {
          'type': 'geojson',
          'features': <Map<String, dynamic>>[],
        },
        lineMetrics: false,
      ),
    );
    await controller.addSource(
      'lineSourceId',
      GeojsonSourceProperties(
        data: {
          'type': 'geojson',
          'features': <Map<String, dynamic>>[],
        },
        lineMetrics: true,
      ),
    );
    await controller.addSource(
      'symbolSourceId',
      GeojsonSourceProperties(
        data: {
          'type': 'geojson',
          'features': <Map<String, dynamic>>[],
        },
        lineMetrics: false,
      ),
    );

    await controller.addFillLayer(
      'fillSourceId',
      'fillLayerId',
      FillLayerProperties(
        fillColor: '#0c0caa',
        fillOpacity: 0.8,
      ),
    );
    await controller.addLineLayer(
      'lineSourceId',
      'lineLayerId',
      LineLayerProperties(
        lineColor: '#F0CF0F',
        lineWidth: 8,
        lineOpacity: 0.8,
        lineCap: 'round',
        lineJoin: 'round',
      ),
    );
    await controller.addSymbolLayer(
      'symbolSourceId',
      'symbolLayerId',
      SymbolLayerProperties(
        iconImage: [
          Expressions.get,
          'iconName',
        ],
      ),
    );

    controller.setGeoJsonSource(
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
    controller.setGeoJsonSource(
      'lineSourceId',
      {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'id': 'id',
            'properties': {},
            'geometry': <String, dynamic>{
              'type': 'LineString',
              'coordinates': [
                [85.32057488784143, 27.693956723414807],
                [85.32379363054457, 27.69247483388617],
                [85.32928673679733, 27.689890853468754],
                [85.33550922210189, 27.688256588115742],
              ],
            },
          },
        ],
      },
    );
    controller.setGeoJsonSource(
      'symbolSourceId',
      {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'id': 'id',
            'properties': {
              'iconName': 'symbolIcon',
            },
            'geometry': <String, dynamic>{
              'type': 'Point',
              'coordinates': [85.32654030681317, 27.684342689879042],
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
      authToken: '',
      showCurrentLocation: true,
      showSearchWidget: false,
      showThree60Widget: false,
      showCurrentLocationButton: true,
      initialCameraPostion: CameraPosition(target: Constants.defaultLatLng, zoom: 13),
      onMapCreated: (controller) {
        _onStylesLoadedCallback(controller);
      },
      rotateGestureEnabled: false,
      tiltGestureEnabled: false,
      showCompass: false,
      minMaxZoomPreference: const MinMaxZoomPreference(
        Constants.minZoomLevel,
        Constants.maxZoomLevel,
      ),
      onMapClick: (latLng) {},
    );
  }
}
