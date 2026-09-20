import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../routes/side_navigation_bar.dart' as navigation;
import '../widgets/kavach_logo.dart';

void main() {
  runApp(const IBVAPApp());
}

// ============================================================
// APP
// ============================================================

class IBVAPApp extends StatelessWidget {
  const IBVAPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IBVAP - Coverage Intelligence',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const CoverageIntelView(),
    );
  }
}

// ============================================================
// COLORS
// ============================================================

class AppColors {
  static const background = Color(0xFF07101A);
  static const panel = Color(0xFF0B1622);
  static const panel2 = Color(0xFF0F1C2A);
  static const panel3 = Color(0xFF142333);

  static const cyan = Color(0xFF00E5FF);
  static const green = Color(0xFF00E676);
  static const yellow = Color(0xFFFFC107);
  static const red = Color(0xFFFF3D4D);
  static const grey = Color(0xFF8A99A8);

  static const white = Color(0xFFE7F0F5);
  static const border = Color(0xFF203444);

  static const blue = Color(0xFF1688FF);
}

// ============================================================
// DATA MODEL
// ============================================================

enum CameraStatus {
  online,
  degraded,
  offline,
  blackScreen,
}

class CameraData {
  final String id;
  final double x;
  final double y;
  final double angle;
  CameraStatus status;
  double coverage;
  double signal;

  CameraData({
    required this.id,
    required this.x,
    required this.y,
    required this.angle,
    required this.status,
    required this.coverage,
    required this.signal,
  });
}

// ============================================================
// MAIN VIEW
// ============================================================

class CoverageIntelView extends StatefulWidget {
  const CoverageIntelView({super.key});

  @override
  State<CoverageIntelView> createState() => _CoverageIntelViewState();
}

class _CoverageIntelViewState extends State<CoverageIntelView> {
  Timer? timer;

  double zoom = 1.0;
  bool showCoverage = true;
  bool showHeatmap = true;

  CameraData? selectedCamera;

  final List<CameraData> cameras = [];

  @override
  void initState() {
    super.initState();

    _createCameras();

    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        _simulateTelemetry();
      },
    );
  }

  void _createCameras() {
    final random = math.Random(8);

    final positions = <Offset>[
      const Offset(.10, .17),
      const Offset(.20, .12),
      const Offset(.31, .13),
      const Offset(.43, .17),
      const Offset(.57, .13),
      const Offset(.69, .16),
      const Offset(.81, .20),
      const Offset(.90, .29),
      const Offset(.84, .42),
      const Offset(.73, .51),
      const Offset(.62, .57),
      const Offset(.49, .59),
      const Offset(.36, .58),
      const Offset(.23, .56),
      const Offset(.13, .49),
      const Offset(.08, .37),
      const Offset(.18, .32),
      const Offset(.30, .28),
      const Offset(.43, .30),
      const Offset(.56, .30),
      const Offset(.69, .32),
      const Offset(.79, .36),
      const Offset(.72, .43),
      const Offset(.60, .42),
      const Offset(.48, .42),
      const Offset(.35, .40),
      const Offset(.24, .39),
      const Offset(.16, .44),
      const Offset(.32, .49),
      const Offset(.46, .51),
    ];

    for (int i = 0; i < positions.length; i++) {
      CameraStatus status = CameraStatus.online;

      if (i == 13 || i == 27) {
        status = CameraStatus.offline;
      }

      if (i == 20 || i == 24) {
        status = CameraStatus.degraded;
      }

      if (i == 6) {
        status = CameraStatus.blackScreen;
      }

      cameras.add(
        CameraData(
          id: 'CAM-${(i + 1).toString().padLeft(3, '0')}',
          x: positions[i].dx,
          y: positions[i].dy,
          angle: random.nextDouble() * math.pi * 2,
          status: status,
          coverage: status == CameraStatus.online
              ? 85 + random.nextDouble() * 13
              : status == CameraStatus.degraded
                  ? 50 + random.nextDouble() * 20
                  : 0,
          signal: status == CameraStatus.online
              ? 80 + random.nextDouble() * 20
              : 20 + random.nextDouble() * 40,
        ),
      );
    }
  }

  void _simulateTelemetry() {
    if (!mounted) return;

    setState(() {
      for (final camera in cameras) {
        if (camera.status == CameraStatus.online) {
          camera.signal =
              (camera.signal + math.Random().nextDouble() * 8 - 4)
                  .clamp(70, 100);

          camera.coverage =
              (camera.coverage + math.Random().nextDouble() * 4 - 2)
                  .clamp(80, 100);
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  int get onlineCount =>
      cameras.where((c) => c.status == CameraStatus.online).length + 17;

  int get degradedCount =>
      cameras.where((c) => c.status == CameraStatus.degraded).length;

  int get offlineCount =>
      cameras.where((c) => c.status == CameraStatus.offline).length;

  int get blackCount =>
      cameras.where((c) => c.status == CameraStatus.blackScreen).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ====================================================
          // TOP BAR - PRESERVED
          // ====================================================

          const TopNavBar(),

          Expanded(
            child: Row(
              children: [
                // ==================================================
                // LEFT NAVIGATION - PRESERVED
                // ==================================================

                const navigation.AppSideNavigationBar(),

                // ==================================================
                // MAIN CONTENT
                // ==================================================

                Expanded(
                  child: Column(
                    children: [
                      // CAMERA STATISTICS
                      _buildStatisticsBar(),

                      Expanded(
                        child: Row(
                          children: [
                            // MAP
                            Expanded(
                              flex: 7,
                              child: TacticalCoverageMap(
                                cameras: cameras,
                                selectedCamera: selectedCamera,
                                zoom: zoom,
                                showCoverage: showCoverage,
                                showHeatmap: showHeatmap,
                                onCameraSelected: (camera) {
                                  setState(() {
                                    selectedCamera = camera;
                                  });
                                },
                              ),
                            ),

                            // RIGHT PANEL
                            SizedBox(
                              width: 350,
                              child: RightIntelPanel(
                                cameras: cameras,
                                selectedCamera: selectedCamera,
                                onCameraSelected: (camera) {
                                  setState(() {
                                    selectedCamera = camera;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // BOTTOM ANALYTICS
                      SizedBox(
                        height: 180,
                        child: _buildBottomAnalytics(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP STATISTICS
  // ============================================================

  Widget _buildStatisticsBar() {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(10),
      color: AppColors.background,
      child: Row(
        children: [
          _statCard(
            icon: Icons.videocam,
            title: 'Total Cameras',
            value: '52',
            color: AppColors.cyan,
          ),
          _statCard(
            icon: Icons.circle,
            title: 'Online',
            value: onlineCount.toString(),
            color: AppColors.green,
          ),
          _statCard(
            icon: Icons.circle,
            title: 'Degraded',
            value: degradedCount.toString(),
            color: AppColors.yellow,
          ),
          _statCard(
            icon: Icons.circle,
            title: 'Offline',
            value: offlineCount.toString(),
            color: AppColors.red,
          ),
          _statCard(
            icon: Icons.circle,
            title: 'Black Screen',
            value: blackCount.toString(),
            color: Colors.grey,
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: _boxDecoration(),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CustomPaint(
                      painter: CoverageRingPainter(
                        coverage: 0.87,
                      ),
                      child: const Center(
                        child: Text(
                          '87%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coverage Area',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '87%',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: .87,
                        minHeight: 7,
                        backgroundColor: AppColors.panel3,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          Icon(
            icon,
            size: 25,
            color: color,
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM ANALYTICS
  // ============================================================

  Widget _buildBottomAnalytics() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(
            child: _bottomCard(
              title: 'Coverage Heatmap',
              child: Row(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: HeatmapPainter(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LegendDot(
                        color: Colors.green,
                        text: 'High Coverage',
                      ),
                      LegendDot(
                        color: Colors.yellow,
                        text: 'Medium Coverage',
                      ),
                      LegendDot(
                        color: Colors.orange,
                        text: 'Low Coverage',
                      ),
                      LegendDot(
                        color: Colors.red,
                        text: 'No Coverage',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _bottomCard(
              title: 'Coverage Zones',
              child: Column(
                children: [
                  _zoneRow('North Sector', '92%', AppColors.green),
                  _zoneRow('East Sector', '78%', AppColors.green),
                  _zoneRow('South Sector', '65%', AppColors.yellow),
                  _zoneRow('West Sector', '58%', AppColors.yellow),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _bottomCard(
              title: 'Camera Performance',
              child: Row(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: PerformanceGraphPainter(),
                    ),
                  ),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '47',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ONLINE',
                        style: TextStyle(
                          fontSize: 8,
                          color: AppColors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2',
                        style: TextStyle(
                          color: AppColors.yellow,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'DEGRADED',
                        style: TextStyle(
                          fontSize: 8,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _bottomCard(
              title: 'Quick Actions',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionButton(
                    Icons.map,
                    'View Full Map',
                    () {
                      setState(() {
                        zoom = 1.5;
                      });
                    },
                  ),
                  const SizedBox(height: 7),
                  _actionButton(
                    Icons.description,
                    'Generate Report',
                    () {
                      _showMessage('Coverage report generated');
                    },
                  ),
                  const SizedBox(height: 7),
                  _actionButton(
                    Icons.settings,
                    'Camera Settings',
                    () {
                      _showMessage('Camera settings opened');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _zoneRow(
    String title,
    String percentage,
    Color color,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.white,
              ),
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String text,
    VoidCallback callback,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 30,
      child: ElevatedButton.icon(
        onPressed: callback,
        icon: Icon(
          icon,
          size: 13,
        ),
        label: Text(
          text,
          style: const TextStyle(fontSize: 10),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: AppColors.border,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ============================================================
// TOP NAVIGATION
// ============================================================

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),

          // Notification
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('3 active camera alerts'),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.cyan,
            ),
          ),

          // Clock
          IconButton(
            tooltip: 'Telemetry time',
            onPressed: () {},
            icon: const Icon(
              Icons.schedule,
              color: AppColors.cyan,
            ),
          ),

          const SizedBox(width: 10),

          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),
          ),

          const SizedBox(width: 5),

          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TACTICAL MAP
// ============================================================

class TacticalCoverageMap extends StatelessWidget {
  final List<CameraData> cameras;
  final CameraData? selectedCamera;
  final double zoom;
  final bool showCoverage;
  final bool showHeatmap;
  final Function(CameraData) onCameraSelected;

  const TacticalCoverageMap({
    super.key,
    required this.cameras,
    required this.selectedCamera,
    required this.zoom,
    required this.showCoverage,
    required this.showHeatmap,
    required this.onCameraSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.black,
          child: Stack(
            children: [
              // MAP
              Positioned.fill(
                child: ClipRect(
                  child: Transform.scale(
                    scale: zoom,
                    child: CustomPaint(
                      painter: TacticalMapPainter(
                        showHeatmap: showHeatmap,
                      ),
                    ),
                  ),
                ),
              ),

              // BORDER
              Positioned.fill(
                child: CustomPaint(
                  painter: BorderLinePainter(),
                ),
              ),

              // COVERAGE CAMERAS
              if (showCoverage)
                ...cameras.map(
                  (camera) {
                    return Positioned(
                      left: constraints.maxWidth * camera.x - 32,
                      top: constraints.maxHeight * camera.y - 32,
                      child: CameraMarkerWidget(
                        camera: camera,
                        selected:
                            selectedCamera?.id == camera.id,
                        onTap: () {
                          onCameraSelected(camera);
                        },
                      ),
                    );
                  },
                ),

              // MAP HEADER
              Positioned(
                left: 15,
                top: 15,
                child: _mapHeader(),
              ),

              // MAP LEGEND
              Positioned(
                left: 15,
                bottom: 15,
                child: _legend(),
              ),

              // MAP CONTROLS
              Positioned(
                right: 15,
                bottom: 15,
                child: _controls(context),
              ),

              // COORDINATES
              Positioned(
                left: 210,
                bottom: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.75),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: const Text(
                    'Lat: 28.61°N | Lng: 77.23°E | Zoom: 14',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mapHeader() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.72),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'SECTOR 7 ALPHA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.circle,
                size: 8,
                color: AppColors.green,
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'LIVE COVERAGE INTELLIGENCE',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1,
              color: AppColors.cyan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.78),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LegendDot(
            color: AppColors.green,
            text: 'Online Camera',
          ),
          LegendDot(
            color: AppColors.yellow,
            text: 'Degraded Camera',
          ),
          LegendDot(
            color: AppColors.red,
            text: 'Offline Camera',
          ),
          LegendDot(
            color: Colors.grey,
            text: 'Black Screen',
          ),
          SizedBox(height: 5),
          LegendTriangle(
            color: AppColors.cyan,
            text: 'Coverage Area',
          ),
        ],
      ),
    );
  }

  Widget _controls(BuildContext context) {
    return Column(
      children: [
        _mapButton(
          Icons.add,
          () {},
        ),
        _mapButton(
          Icons.remove,
          () {},
        ),
        _mapButton(
          Icons.my_location,
          () {},
        ),
        _mapButton(
          Icons.layers,
          () {},
        ),
      ],
    );
  }

  Widget _mapButton(
    IconData icon,
    VoidCallback callback,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: IconButton(
        onPressed: callback,
        icon: Icon(
          icon,
          size: 18,
          color: AppColors.cyan,
        ),
      ),
    );
  }
}

// ============================================================
// CAMERA MARKER
// ============================================================

class CameraMarkerWidget extends StatelessWidget {
  final CameraData camera;
  final bool selected;
  final VoidCallback onTap;

  const CameraMarkerWidget({
    super.key,
    required this.camera,
    required this.selected,
    required this.onTap,
  });

  Color get statusColor {
    switch (camera.status) {
      case CameraStatus.online:
        return AppColors.green;
      case CameraStatus.degraded:
        return AppColors.yellow;
      case CameraStatus.offline:
        return AppColors.red;
      case CameraStatus.blackScreen:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        height: 100,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // COVERAGE CONE
            CustomPaint(
              size: const Size(70, 70),
              painter: CoverageConePainter(
                color: statusColor,
                angle: camera.angle,
              ),
            ),

            // CAMERA
            Positioned(
              top: 27,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? Colors.white
                        : statusColor,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.videocam,
                  size: 15,
                  color: statusColor,
                ),
              ),
            ),

            // LABEL
            Positioned(
              top: 62,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.9),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: statusColor.withOpacity(.7),
                  ),
                ),
                child: Text(
                  camera.id,
                  style: TextStyle(
                    fontSize: 8,
                    color: statusColor,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RIGHT INTELLIGENCE PANEL
// ============================================================

class RightIntelPanel extends StatelessWidget {
  final List<CameraData> cameras;
  final CameraData? selectedCamera;
  final Function(CameraData) onCameraSelected;

  const RightIntelPanel({
    super.key,
    required this.cameras,
    required this.selectedCamera,
    required this.onCameraSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.panel,
      child: Column(
        children: [
          // HEADER
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: AppColors.cyan,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Camera Alerts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '3 ACTIVE',
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                // ALERTS
                _alertCard(
                  camera: cameras[13],
                  title: 'CAM-014 Offline',
                  description:
                      'North-East perimeter camera is currently unavailable.',
                  color: AppColors.red,
                ),

                _alertCard(
                  camera: cameras[20],
                  title: 'CAM-021 Degraded',
                  description:
                      'Feed quality reduced. Signal strength below threshold.',
                  color: AppColors.yellow,
                ),

                _alertCard(
                  camera: cameras[6],
                  title: 'CAM-007 Black Screen',
                  description:
                      'Camera connected but video stream contains no image.',
                  color: Colors.grey,
                ),

                const SizedBox(height: 12),

                _sectionTitle('Camera Status Overview'),

                const SizedBox(height: 8),

                _statusOverview(),

                const SizedBox(height: 12),

                _sectionTitle('Recent Events'),

                const SizedBox(height: 8),

                _event(
                  Icons.error,
                  AppColors.red,
                  'CAM-014 went offline',
                  '2 min ago',
                ),

                _event(
                  Icons.tv_off,
                  Colors.grey,
                  'CAM-007 black screen detected',
                  '5 min ago',
                ),

                _event(
                  Icons.warning,
                  AppColors.yellow,
                  'CAM-021 feed quality reduced',
                  '12 min ago',
                ),

                _event(
                  Icons.check_circle,
                  AppColors.green,
                  'CAM-003 back online',
                  '23 min ago',
                ),

                _event(
                  Icons.check_circle,
                  AppColors.green,
                  'CAM-017 back online',
                  '36 min ago',
                ),

                const SizedBox(height: 12),

                if (selectedCamera != null)
                  _selectedCameraCard(selectedCamera!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const Spacer(),
        const Text(
          'VIEW ALL',
          style: TextStyle(
            fontSize: 8,
            color: AppColors.cyan,
          ),
        ),
      ],
    );
  }

  Widget _alertCard({
    required CameraData camera,
    required String title,
    required String description,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        onCameraSelected(camera);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.panel2,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withOpacity(.45),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.videocam_off,
              size: 19,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.4,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusOverview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panel2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: CustomPaint(
                    painter: StatusDonutPainter(
                      online: 47,
                      degraded: 2,
                      offline: 2,
                      black: 1,
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '52',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 7,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusRow(
                        color: AppColors.green,
                        title: 'Online',
                        value: '47',
                      ),
                      StatusRow(
                        color: AppColors.yellow,
                        title: 'Degraded',
                        value: '2',
                      ),
                      StatusRow(
                        color: AppColors.red,
                        title: 'Offline',
                        value: '2',
                      ),
                      StatusRow(
                        color: Colors.grey,
                        title: 'Black Screen',
                        value: '1',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _event(
    IconData icon,
    Color color,
    String title,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
        horizontal: 4,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.white,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 8,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedCameraCard(CameraData camera) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panel2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.cyan,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELECTED CAMERA',
            style: TextStyle(
              fontSize: 8,
              color: AppColors.cyan,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            camera.id,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Coverage: ${camera.coverage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Signal: ${camera.signal.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SMALL WIDGETS
// ============================================================

class LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const LegendDot({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              fontSize: 8,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class LegendTriangle extends StatelessWidget {
  final Color color;
  final String text;

  const LegendTriangle({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.change_history,
          size: 10,
          color: color,
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 8,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class StatusRow extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const StatusRow({
    super.key,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: color,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 8,
                color: AppColors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAINTERS
// ============================================================

class TacticalMapPainter extends CustomPainter {
  final bool showHeatmap;

  TacticalMapPainter({
    required this.showHeatmap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final background = Paint()
      ..color = const Color(0xFF0A1720);

    canvas.drawRect(
      Offset.zero & size,
      background,
    );

    // Terrain patches
    final terrain = Paint()
      ..color = const Color(0xFF10251E)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 14; i++) {
      final x = (i * 173.0) % size.width;
      final y = (i * 97.0) % size.height;

      canvas.drawCircle(
        Offset(x, y),
        60 + (i % 3) * 20,
        terrain,
      );
    }

    // Grid
    final gridPaint = Paint()
      ..color = const Color(0xFF24404A).withOpacity(.35)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 45) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (double y = 0; y < size.height; y += 45) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Roads / patrol paths
    final roadPaint = Paint()
      ..color = const Color(0xFF34505A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();

    path.moveTo(size.width * .05, size.height * .35);
    path.lineTo(size.width * .25, size.height * .28);
    path.lineTo(size.width * .45, size.height * .32);
    path.lineTo(size.width * .68, size.height * .24);
    path.lineTo(size.width * .94, size.height * .35);

    canvas.drawPath(path, roadPaint);

    final path2 = Path();

    path2.moveTo(size.width * .05, size.height * .67);
    path2.lineTo(size.width * .28, size.height * .72);
    path2.lineTo(size.width * .52, size.height * .63);
    path2.lineTo(size.width * .76, size.height * .70);
    path2.lineTo(size.width * .95, size.height * .62);

    canvas.drawPath(path2, roadPaint);

    // Buildings
    final buildingPaint = Paint()
      ..color = const Color(0xFF26383B)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = size.width * .18 + (i % 6) * 50;
      final y = size.height * .35 + (i ~/ 6) * 35;

      canvas.drawRect(
        Rect.fromLTWH(
          x,
          y,
          30,
          18,
        ),
        buildingPaint,
      );
    }

    // Heatmap
    if (showHeatmap) {
      final heatPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.green.withOpacity(.15),
            Colors.yellow.withOpacity(.08),
            Colors.red.withOpacity(.02),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(
              size.width * .45,
              size.height * .48,
            ),
            radius: 230,
          ),
        );

      canvas.drawCircle(
        Offset(
          size.width * .45,
          size.height * .48,
        ),
        230,
        heatPaint,
      );
    }

    // Border line
    final borderPaint = Paint()
      ..color = AppColors.red.withOpacity(.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final border = Path();

    border.moveTo(
      size.width * .86,
      0,
    );

    border.lineTo(
      size.width * .90,
      size.height * .18,
    );

    border.lineTo(
      size.width * .87,
      size.height * .35,
    );

    border.lineTo(
      size.width * .92,
      size.height * .52,
    );

    border.lineTo(
      size.width * .88,
      size.height,
    );

    canvas.drawPath(border, borderPaint);

    // Border text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'BORDER LINE',
        style: TextStyle(
          color: AppColors.red,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        size.width * .86,
        size.height * .43,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant TacticalMapPainter oldDelegate) {
    return oldDelegate.showHeatmap != showHeatmap;
  }
}

// ============================================================
// COVERAGE CONE
// ============================================================

class CoverageConePainter extends CustomPainter {
  final Color color;
  final double angle;

  CoverageConePainter({
    required this.color,
    required this.angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.translate(
      size.width / 2,
      size.height / 2,
    );

    canvas.rotate(angle);

    final paint = Paint()
      ..color = color.withOpacity(.15)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(-28, 55);
    path.lineTo(28, 55);
    path.close();

    canvas.drawPath(
      path,
      paint,
    );

    final linePaint = Paint()
      ..color = color.withOpacity(.35)
      ..strokeWidth = 1;

    canvas.drawLine(
      const Offset(0, 0),
      const Offset(-28, 55),
      linePaint,
    );

    canvas.drawLine(
      const Offset(0, 0),
      const Offset(28, 55),
      linePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CoverageConePainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.color != color;
  }
}

// ============================================================
// BORDER LINE
// ============================================================

class BorderLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.red.withOpacity(.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();

    path.moveTo(
      size.width * .87,
      0,
    );

    path.lineTo(
      size.width * .89,
      size.height * .20,
    );

    path.lineTo(
      size.width * .86,
      size.height * .40,
    );

    path.lineTo(
      size.width * .91,
      size.height * .62,
    );

    path.lineTo(
      size.width * .88,
      size.height,
    );

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant BorderLinePainter oldDelegate) {
    return false;
  }
}

// ============================================================
// HEATMAP
// ============================================================

class HeatmapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: const [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
        const Radius.circular(5),
      ),
      paint,
    );

    final grid = Paint()
      ..color = Colors.white.withOpacity(.12)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 15) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        grid,
      );
    }

    for (double y = 0; y < size.height; y += 15) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        grid,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// PERFORMANCE GRAPH
// ============================================================

class PerformanceGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    final points = <Offset>[
      Offset(0, size.height * .6),
      Offset(size.width * .08, size.height * .4),
      Offset(size.width * .15, size.height * .55),
      Offset(size.width * .23, size.height * .3),
      Offset(size.width * .32, size.height * .45),
      Offset(size.width * .40, size.height * .25),
      Offset(size.width * .52, size.height * .4),
      Offset(size.width * .63, size.height * .2),
      Offset(size.width * .73, size.height * .35),
      Offset(size.width * .84, size.height * .15),
      Offset(size.width, size.height * .25),
    ];

    path.moveTo(
      points.first.dx,
      points.first.dy,
    );

    for (final point in points.skip(1)) {
      path.lineTo(
        point.dx,
        point.dy,
      );
    }

    canvas.drawPath(
      path,
      linePaint,
    );

    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = .5;

    for (double y = 0; y < size.height; y += 15) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        grid,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PerformanceGraphPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// STATUS DONUT
// ============================================================

class StatusDonutPainter extends CustomPainter {
  final int online;
  final int degraded;
  final int offline;
  final int black;

  StatusDonutPainter({
    required this.online,
    required this.degraded,
    required this.offline,
    required this.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total =
        online + degraded + offline + black;

    double startAngle = -math.pi / 2;

    final data = [
      (online, AppColors.green),
      (degraded, AppColors.yellow),
      (offline, AppColors.red),
      (black, Colors.grey),
    ];

    for (final item in data) {
      final sweep =
          (item.$1 / total) * math.pi * 2;

      final paint = Paint()
        ..color = item.$2
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10;

      canvas.drawArc(
        Rect.fromLTWH(
          8,
          8,
          size.width - 16,
          size.height - 16,
        ),
        startAngle,
        sweep,
        false,
        paint,
      );

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant StatusDonutPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// COVERAGE RING
// ============================================================

class CoverageRingPainter extends CustomPainter {
  final double coverage;

  CoverageRingPainter({
    required this.coverage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..color = AppColors.panel3
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawCircle(
      Offset(
        size.width / 2,
        size.height / 2,
      ),
      size.width / 2 - 4,
      background,
    );

    final foreground = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(
        4,
        4,
        size.width - 8,
        size.height - 8,
      ),
      -math.pi / 2,
      math.pi * 2 * coverage,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant CoverageRingPainter oldDelegate) {
    return oldDelegate.coverage != coverage;
  }
}