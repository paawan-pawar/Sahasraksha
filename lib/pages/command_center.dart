import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../routes/side_navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IBVAP Master Dashboard',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: const Color(0xFF0F131C),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const CommandCenter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Color palette from the HTML
class AppColors {
  static const Color background = Color(0xFF0F131C);
  static const Color surface = Color(0xFF0F131C);
  static const Color surfaceContainer = Color(0xFF1C1F29);
  static const Color surfaceContainerLow = Color(0xFF181B25);
  static const Color surfaceContainerLowest = Color(0xFF0A0E17);
  static const Color surfaceContainerHigh = Color(0xFF262A34);
  static const Color surfaceVariant = Color(0xFF31353F);
  static const Color onSurface = Color(0xFFDFE2EF);
  static const Color onSurfaceVariant = Color(0xFFBAC9CC);
  static const Color primary = Color(0xFF00DAF3);
  static const Color primaryFixedDim = Color(0xFF00DAF3);
  static const Color onPrimary = Color(0xFF00363D);
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color outline = Color(0xFF849396);
  static const Color outlineVariant = Color(0xFF3B494C);
  static const Color surfaceTint = Color(0xFF00DAF3);
}

class CommandCenter extends StatefulWidget {
  const CommandCenter({super.key});

  @override
  State<CommandCenter> createState() => _CommandCenterState();
}

class _CommandCenterState extends State<CommandCenter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Side Navigation Bar
          const AppSideNavigationBar(),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                const TopNavBar(),
                // Main Content Area
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.surfaceContainerLowest,
                    child: const Column(
                      children: [
                        // Top Metrics Row
                        MetricsRow(),
                        SizedBox(height: 16),
                        // Middle Section: Camera Grid + Alert Feed
                        Expanded(
                          child: MiddleSection(),
                        ),
                        SizedBox(height: 16),
                        // Bottom Sparklines
                        BottomSparklines(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryFixedDim,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'System Nominal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.onSurfaceVariant),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.schedule, color: AppColors.onSurfaceVariant),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MetricsRow extends StatelessWidget {
  const MetricsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildMetricCard(
          label: 'Total Cameras',
          value: '50',
          subtitle: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFixedDim,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text('Online: 48', style: TextStyle(fontSize: 11, color: AppColors.primaryFixedDim)),
              const SizedBox(width: 12),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text('Offline: 2', style: TextStyle(fontSize: 11, color: AppColors.error)),
            ],
          ),
          icon: Icons.videocam,
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard(
          label: 'Active Alerts',
          value: '17',
          subtitle: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withOpacity(0.1),
              border: const Border(left: BorderSide(color: AppColors.error, width: 2)),
            ),
            child: const Text('Critical: 3', style: TextStyle(fontSize: 11, color: AppColors.error)),
          ),
          icon: Icons.warning,
          valueColor: AppColors.error,
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard(
          label: "Today's Detections",
          value: '1,247',
          subtitle: Row(
            children: [
              const Icon(Icons.trending_up, size: 14, color: AppColors.primaryFixedDim),
              const SizedBox(width: 4),
              const Text('+12% vs avg', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
            ],
          ),
          icon: Icons.person_search,
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard(
          label: 'Avg. Response Time',
          value: '8.4s',
          subtitle: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: 0.84,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryFixedDim,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          icon: Icons.timer,
        )),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Widget subtitle,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.onSurface,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
              subtitle,
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                icon,
                size: 64,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MiddleSection extends StatelessWidget {
  const MiddleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Camera Grid (9 columns)
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.grid_view, size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 8),
                        const Text(
                          'Tactical Overview',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: const BorderSide(color: AppColors.primaryFixedDim),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'FILTER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryFixedDim,
                          fontFamily: 'JetBrains Mono',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Camera Grid (3x3 with enlarged center)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = 8.0;
                      final cellWidth = (constraints.maxWidth - gap * 2) / 3;
                      final cellHeight = (constraints.maxHeight - gap * 2) / 3;

                      Widget cell(Widget child, int column, int row,
                          {int columnSpan = 1, int rowSpan = 1}) {
                        return Positioned(
                          left: column * (cellWidth + gap),
                          top: row * (cellHeight + gap),
                          width: cellWidth * columnSpan + gap * (columnSpan - 1),
                          height: cellHeight * rowSpan + gap * (rowSpan - 1),
                          child: child,
                        );
                      }

                      return Stack(
                        children: [
                          cell(_buildCameraThumbnail('BOP-01', true, 'assets/command_centre_vid/vid_3_human_alert.mp4', 'REC'), 0, 0),
                          cell(_buildCameraThumbnail('BOP-02', false, 'assets/command_centre_vid/vid_4_human_alert.mp4'), 1, 0),
                          cell(_buildCameraThumbnail('BOP-03', false, 'assets/command_centre_vid/vid1.mp4'), 2, 0),
                          cell(_buildCameraThumbnail('BOP-04', false, 'assets/command_centre_vid/vid_5_human_alert.mp4'), 0, 1),
                          cell(_buildEnlargedCamera(), 1, 1, columnSpan: 2, rowSpan: 2),
                          cell(_buildCameraThumbnail('BOP-08', false, 'assets/command_centre_vid/vid2.mp4'), 0, 2),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Alert Feed (3 columns)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.campaign, size: 16, color: AppColors.error),
                        const SizedBox(width: 4),
                        const Text(
                          'Live Alert Feed',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      color: AppColors.surfaceVariant,
                      child: const Text(
                        'SYS_LOG',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'JetBrains Mono',
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.outlineVariant, height: 8),
                // Alert list
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildAlertItem('14:23:05', 'BOP-12', 'Person crossed fence', 'Alpha Sector', true),
                      _buildAlertItem('14:18:22', 'BOP-04', 'Vehicle loitering', 'Gate Checkpoint', false),
                      _buildAlertItem('14:12:01', 'BOP-09', 'Motion detected (Wildlife)', 'Beta Sector', false),
                      _buildAlertItem('14:05:45', 'SYS-MON', 'Network latency spike', 'Node 4', false),
                      _buildAlertItem('13:58:10', 'BOP-15', 'Signal Lost (Camera Offline)', 'Delta Sector', true),
                      _buildAlertItem('13:42:00', 'BOP-02', 'Routine Scan Complete', 'HQ Perimeter', false, true),
                      _buildAlertItem('13:30:15', 'BOP-03', 'Thermal calibration', 'Gamma Sector', false, true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraThumbnail(String label, bool recording, String videoAsset, [String? badge]) {
    return _CameraFeedThumbnail(
      label: label,
      videoAsset: videoAsset,
      recording: recording,
      badge: badge,
    );
  }

  Widget _buildEnlargedCamera() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border.all(color: AppColors.error, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: AppColors.surfaceContainer,
              child: Opacity(
                opacity: 0.8,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCo8xuRDzT7oA-gOb2LT_EmnhNbRSDYce238KMpj-cHUcUx4_jhWfBZTgjZxbvstFVXAX9p2gSM7Qz8E_weHSe9iyT2zJE_OYaVuVvSj2hbPE0zTA5QBF1GJchZlk9C36TiREtL5okpaRswLzxHz0xuG25V9Oj7VeIrX3gDEfVJ2-wue96LWwzM9CGAjkkh-RE9BYaD1JUJraRfXdDWgQR6mllnz6Sj9Ai1VgEO7YTLe5JOCQF-_ohT',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildFeedFallback(),
                ),
              ),
            ),
          ),
          // AI Attention Queue overlay
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Attention Queue',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryFixedDim,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                  const Text(
                    'BOP-12 | Alpha Sector',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurface,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Targeting reticle
          Center(
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          // Bottom alert bar
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: AppColors.error, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HIGH RISK: INTRUSION DETECTED',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                                fontFamily: 'JetBrains Mono',
                              ),
                              children: [
                                TextSpan(text: 'Confidence: '),
                                TextSpan(text: '94%', style: TextStyle(color: AppColors.onSurface)),
                                TextSpan(text: ' | Vector: North-West'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'INITIATE RESPONSE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'JetBrains Mono',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFeedFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF263B3B), Color(0xFF101C24)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.videocam,
          size: 36,
          color: AppColors.primaryFixedDim.withOpacity(0.35),
        ),
      ),
    );
  }
  Widget _buildAlertItem(String time, String source, String message, String sector, bool isCritical, [bool dimmed = false]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: isCritical ? AppColors.error : AppColors.onSurfaceVariant,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
              Text(
                source,
                style: TextStyle(
                  fontSize: 11,
                  color: dimmed ? AppColors.onSurfaceVariant : AppColors.onSurfaceVariant,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
          ),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: dimmed ? AppColors.onSurfaceVariant : AppColors.onSurface,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          Text(
            sector,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.primaryFixedDim,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraFeedThumbnail extends StatefulWidget {
  const _CameraFeedThumbnail({
    required this.label,
    required this.videoAsset,
    this.recording = false,
    this.badge,
  });

  final String label;
  final String videoAsset;
  final bool recording;
  final String? badge;

  @override
  State<_CameraFeedThumbnail> createState() => _CameraFeedThumbnailState();
}

class _CameraFeedThumbnailState extends State<_CameraFeedThumbnail> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _hasError = false;
    final controller = VideoPlayerController.asset(widget.videoAsset)
      ..setLooping(true)
      ..setVolume(0);

    _controller = controller;

    controller.initialize().then((_) {
      if (!mounted || _controller != controller) {
        controller.dispose();
        return;
      }
      setState(() {});
      controller.play();
    }).catchError((_) {
      if (!mounted || _controller != controller) {
        controller.dispose();
        return;
      }
      setState(() => _hasError = true);
    });
  }

  @override
  void didUpdateWidget(covariant _CameraFeedThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoAsset != widget.videoAsset) {
      _controller?.dispose();
      _controller = null;
      _initController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isInitialized = controller != null && controller.value.isInitialized && !_hasError;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            )
          else
            _buildThumbnailFallback(),
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              color: Colors.black.withOpacity(0.6),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.onSurface,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ),
          ),
          if (widget.recording)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                color: Colors.black.withOpacity(0.6),
                child: const Text(
                  'REC',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primaryFixedDim,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ),
            ),
          if (widget.badge != null && !widget.recording)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                color: Colors.black.withOpacity(0.6),
                child: Text(
                  widget.badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primaryFixedDim,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnailFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF263B3B), Color(0xFF101C24)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.videocam,
          size: 36,
          color: AppColors.primaryFixedDim.withOpacity(0.35),
        ),
      ),
    );
  }
}

class BottomSparklines extends StatelessWidget {
  const BottomSparklines({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 96,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Alert Trend (24h)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      'Nominal',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryFixedDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      _buildSparklineBar(0.2),
                      _buildSparklineBar(0.3),
                      _buildSparklineBar(0.25),
                      _buildSparklineBar(0.15),
                      _buildSparklineBar(0.4),
                      _buildSparklineBar(0.8, isError: true),
                      _buildSparklineBar(0.6, isError: true),
                      _buildSparklineBar(0.3),
                      _buildSparklineBar(0.2),
                      _buildSparklineBar(0.35),
                      _buildSparklineBar(0.1),
                      _buildSparklineBar(0.45, showDot: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 96,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detection Confidence Distribution',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      'n=1,247',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      _buildHistogramBar(0.05),
                      _buildHistogramBar(0.1),
                      _buildHistogramBar(0.08),
                      _buildHistogramBar(0.15),
                      _buildHistogramBar(0.25),
                      _buildHistogramBar(0.4),
                      _buildHistogramBar(0.65),
                      _buildHistogramBar(0.85),
                      _buildHistogramBar(1.0),
                      _buildHistogramBar(0.7),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('0%', style: TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant, fontFamily: 'JetBrains Mono')),
                    Text('50%', style: TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant, fontFamily: 'JetBrains Mono')),
                    Text('100%', style: TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant, fontFamily: 'JetBrains Mono')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSparklineBar(double height, {bool isError = false, bool showDot = false}) {
    final color = isError ? AppColors.error : AppColors.primaryFixedDim;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: height * 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(isError ? 0.7 : 0.4),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ),
              if (showDot)
                const Positioned(
                  top: -4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 4,
                      height: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixedDim,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistogramBar(double height) {
    Color color;
    if (height < 0.2) {
      color = AppColors.surfaceVariant;
    } else if (height < 0.5) {
      color = AppColors.outlineVariant;
    } else if (height < 0.7) {
      color = AppColors.primaryFixedDim.withOpacity(0.4);
    } else if (height < 0.9) {
      color = AppColors.primaryFixedDim.withOpacity(0.6);
    } else {
      color = AppColors.primaryFixedDim;
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: height * 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            ),
          ),
        ),
      ),
    );
  }
}