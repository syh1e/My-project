import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  final double searchRadiusKm; // km 단위의 반경

  const MapPage({Key? key, required this.searchRadiusKm}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MapPage> {
  GoogleMapController? mapController;
  LatLng _currentPosition =
      const LatLng(37.24728709551569, 127.078421400296973); // 현재 위치
  LatLng _centerPosition =
      const LatLng(37.24728709551569, 127.078421400296973); // 지도 중심 좌표
  LatLng? _routeCenterPosition; // 경로 탐색을 위한 중심 위치
  LatLng? _destination; // 목적지
  String? _destinationName; // 목적지 이름
  double? _destinationDistance; // 목적지까지의 거리
  double _walkedDistance = 0.0; // 걸은 거리
  int _walkedTime = 0; // 걸은 시간 (초)
  double _caloriesBurned = 0.0;
  Set<Polyline> _polylines = {}; // 경로를 저장할 폴리라인
  Set<Marker> _markers = {}; // 마커 저장
  final String _apiKey =
      "AIzaSyDfRcxqWAvfg_qTl1lhS7y3ScFM36K836I"; // Google API 키 입력

  bool _showCenterConfirmation = true; // 중심 위치 확정 버튼 표시 여부
  bool _showRouteButtons = false; // 다른 경로 찾기 및 경로 확정 버튼 표시 여부
  bool _isWalking = false;
  bool _isPaused = false; // 산책 중 여부
  Timer? _walkTimer; // 시간 타이머
  Timer? _distanceTimer; // 거리 타이머
  Timer? _caloryTimer;
  LatLng? _lastPosition; // 이전 위치

  // main.dart에서 받은 km 단위의 반경을 미터로 변환
  double get _searchRadiusMeters => widget.searchRadiusKm * 1000;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 현재 위치 가져오기
  }

  @override
  void dispose() {
    _walkTimer?.cancel(); // 시간 타이머 종료
    _distanceTimer?.cancel(); // 거리 타이머 종료
    _caloryTimer?.cancel();
    super.dispose();
  }

  // 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _centerPosition = _currentPosition;
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentPosition,
            infoWindow: const InfoWindow(title: '현재 위치'),
          ),
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('현재 위치를 가져올 수 없습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 중심 위치 확정 시 경로 탐색 시작
  Future<void> _updateCenterPosition() async {
    setState(() {
      _routeCenterPosition = _centerPosition; // 경로 탐색 중심 위치 설정
      _markers.clear(); // 중심 마커 제거
      _showCenterConfirmation = false; // 중심 확정 버튼 숨기기
    });
    _fetchNearbyParks();
  }

  // 근처 공원 검색 함수
  Future<void> _fetchNearbyParks() async {
    if (_routeCenterPosition == null) return;

    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=${_routeCenterPosition!.latitude},${_routeCenterPosition!.longitude}"
        "&radius=${_searchRadiusMeters.toInt()}&type=park&key=$_apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          _selectNearbyParkWithinRadius(data['results']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('근처에 공원이 없습니다.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('공원 정보를 가져오는 데 실패했습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('공원 데이터를 가져오는 데 실패했습니다: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 설정된 반경에서 ±1km 범위 내 공원 선택
  void _selectNearbyParkWithinRadius(List<dynamic> parks) {
    final random = Random();
    bool found = false;

    while (!found && parks.isNotEmpty) {
      final randomPark = parks[random.nextInt(parks.length)];
      final parkLocation = LatLng(
        randomPark['geometry']['location']['lat'],
        randomPark['geometry']['location']['lng'],
      );

      final distance = _calculateDistance(_routeCenterPosition!, parkLocation);

      // 지정 반경 ±1km 범위에 해당하는지 확인
      if (distance >= widget.searchRadiusKm - 1 &&
          distance <= widget.searchRadiusKm + 1) {
        setState(() {
          _destination = parkLocation;
          _destinationName = randomPark['name'];
          _destinationDistance = distance;
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: [_routeCenterPosition!, _destination!],
              color: Colors.red,
              width: 5,
            ),
          };
          _markers = {
            Marker(
              markerId: const MarkerId('start'),
              position: _routeCenterPosition!,
              infoWindow: const InfoWindow(title: '출발지'),
            ),
            Marker(
              markerId: const MarkerId('destination'),
              position: _destination!,
              infoWindow: InfoWindow(title: _destinationName),
            ),
          };
          _showRouteButtons = true; // 다른 경로 찾기 및 경로 확정 버튼 표시
        });
        found = true;
      } else {
        parks.remove(randomPark); // 조건에 맞지 않으면 리스트에서 제거
      }
    }

    if (!found) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('설정한 반경 ±1km 내에 공원이 없습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      _findAnotherRoute(); // 조건에 맞는 공원이 없으면 새로운 경로를 찾음
    }
  }

  // 두 위치 간 거리 계산
  double _calculateDistance(LatLng start, LatLng end) {
    final double distanceInMeters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    return distanceInMeters / 1000; // km 단위로 변환
  }

// 다른 경로 찾기
  void _findAnotherRoute() {
    setState(() {
      // 기존 폴리라인과 마커를 지우고 새로운 경로를 찾도록 설정
      _polylines.clear();
      _markers.clear();
      _destination = null;
      _destinationName = null;
      _destinationDistance = null;
      _showRouteButtons = false; // 경로 버튼도 숨기기
    });

    // 새로운 공원을 찾기
    _fetchNearbyParks();
  }

  // 경로 확정 후 산책 시작
  void _confirmRoute() {
    setState(() {
      _showRouteButtons = false; // 버튼 숨기기
      _isWalking = true; // 산책 시작
      _walkedDistance = 0.0;
      _walkedTime = 0;
      _caloriesBurned = 0.0;
      _lastPosition = _currentPosition;
    });
    _startWalking(); // 산책 시작
  }

  void _pauseTimers() {
    _walkTimer?.cancel();
    _distanceTimer?.cancel();
    _caloryTimer?.cancel();
  }

  void _togglePauseWalking() {
    setState(() {
      if (_isPaused) {
        // 일시정지 상태에서 다시 시작
        _startWalking();
      } else {
        // 산책 중지
        _pauseTimers();
      }
      _isPaused = !_isPaused;
    });
  }

  // 산책 시작: 시간 및 거리 갱신
  void _startWalking() {
    // 1초마다 시간 갱신
    _walkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _walkedTime++;
        _caloriesBurned += 180 * (_walkedTime / 3600.0);
      });
    });

    // 5초마다 거리 갱신
    _distanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng newPosition = LatLng(position.latitude, position.longitude);

      if (_lastPosition != null) {
        double distance = _calculateDistance(_lastPosition!, newPosition);
        setState(() {
          _walkedDistance += distance;
          _lastPosition = newPosition;
        });
      }
    });

    // 칼로리 계산 타이머
    _caloryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _caloriesBurned += 180 * (1 / 360.0); // 1초마다 칼로리 소모 계산
      });
    });
  }

// 지도 이동 시 중심 좌표 갱신
  void _onCameraMove(CameraPosition position) {
    _centerPosition = position.target;
  }

// 지도 생성 시 호출
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 15.0),
    );
  }

  // 산책 종료
  void _stopWalking() {
    _walkTimer?.cancel();
    _distanceTimer?.cancel();
    _caloryTimer?.cancel();
    setState(() {
      _isWalking = false;
      _destination = null;
      _destinationName = null;
      _destinationDistance = null;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalkSummaryPage(
          walkedTime: _walkedTime,
          walkedDistance: _walkedDistance,
          caloriesBurned: _caloriesBurned,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('산책 경로 탐색'),
          leading: _showCenterConfirmation
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              : null,
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              polylines: _polylines,
              markers: _markers,
              onCameraMove: _onCameraMove,
            ),
            if (_isWalking) // 산책 중일 때 거리 및 시간 표시
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '산책한 시간: ${(_walkedTime / 60).floor()}분 ${_walkedTime % 60}초'),
                      Text('산책한 거리: ${_walkedDistance.toStringAsFixed(2)} km'),
                      Text(
                          '소모된 칼로리: ${_caloriesBurned.toStringAsFixed(2)} calories'),
                    ],
                  ),
                ),
              ),
            if (_destination != null && !_isWalking) // 경로 정보 표시
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('목적지: $_destinationName'),
                      Text(
                          '거리: ${_destinationDistance?.toStringAsFixed(2)} km'),
                    ],
                  ),
                ),
              ),
            if (_showCenterConfirmation)
              Center(
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            if (_showCenterConfirmation)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: _updateCenterPosition,
                  child: const Text("중심 위치 확정"),
                ),
              ),
            if (_showRouteButtons)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _findAnotherRoute,
                      child: const Text("다른 경로 찾기"),
                    ),
                    ElevatedButton(
                      onPressed: _confirmRoute,
                      child: const Text("경로 확정하기"),
                    ),
                  ],
                ),
              ),
            if (_isWalking)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: _togglePauseWalking,
                  child: Text(_isPaused ? "산책 재개" : "산책 일시정지"),
                ),
              ),
            if (_isWalking)
              Positioned(
                bottom: 80,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: _stopWalking,
                  child: const Text("산책 종료하기"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WalkSummaryPage extends StatelessWidget {
  final int walkedTime;
  final double walkedDistance;
  final double caloriesBurned;

  const WalkSummaryPage({
    Key? key,
    required this.walkedTime,
    required this.walkedDistance,
    required this.caloriesBurned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 시간을 분과 초로 나누어 표시
    int minutes = walkedTime ~/ 60;
    int seconds = walkedTime % 60;
    return Scaffold(
      appBar: AppBar(
        title: const Text('산책 결과'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '산책 결과',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '산책한 시간: $minutes 분 $seconds 초',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '산책한 거리: ${walkedDistance.toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '소모된 칼로리: ${caloriesBurned.toStringAsFixed(2)} kcal',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                // 뒤로 가기 버튼
              },
              child: const Text("돌아가기"),
            ),
          ],
        ),
      ),
    );
  }
}
