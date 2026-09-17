import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../routes/side_navigation_bar.dart';
import '../services/api_config.dart';
import '../widgets/asset_video_player.dart';

class AITrailingView extends StatefulWidget {
  const AITrailingView({super.key});

  @override
  State<AITrailingView> createState() => _AITrailingViewState();
}

class _AITrailingViewState extends State<AITrailingView> {
  late Future<List<Map<String, dynamic>>> _entities;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _entities = _loadEntities();
  }

  Future<List<Map<String, dynamic>>> _loadEntities() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.aiTrailingBaseUrl}/entities'));
      if (response.statusCode != 200) throw Exception('API returned ${response.statusCode}');
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Row(
        children: [
          const AppSideNavigationBar(),
          Expanded(
            child: Column(
              children: [
                _Header(onRefresh: () => setState(() => _entities = _loadEntities())),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _entities,
                    builder: (context, snapshot) {
                      final entities = snapshot.data ?? const [];
                      return Row(
                        children: [
                          Expanded(flex: 7, child: _TrackingCanvas(entities: entities, selectedId: _selectedId)),
                          SizedBox(width: 320, child: _EntityPanel(entities: entities, selectedId: _selectedId, onSelect: (id) => setState(() => _selectedId = id))),
                        ],
                      );
                    },
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

class _Header extends StatelessWidget {
  const _Header({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) => Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF26323B)))),
        child: Row(children: [
          const Icon(Icons.route, color: Color(0xFF00DAF3)),
          const SizedBox(width: 12),
          const Text('AI TRAILING', style: TextStyle(color: Color(0xFFE2F0F2), fontWeight: FontWeight.w700, letterSpacing: 1.4)),
          const SizedBox(width: 10),
          const Text('CROSS-CAMERA ENTITY TRACKING', style: TextStyle(color: Color(0xFF7E979C), fontSize: 11, letterSpacing: 1)),
          const Spacer(),
          IconButton(onPressed: onRefresh, tooltip: 'Refresh tracking data', icon: const Icon(Icons.refresh, color: Color(0xFF8FA9AE))),
        ]),
      );
}

class _TrackingCanvas extends StatefulWidget {
  const _TrackingCanvas({required this.entities, required this.selectedId});
  final List<Map<String, dynamic>> entities;
  final String? selectedId;

  @override
  State<_TrackingCanvas> createState() => _TrackingCanvasState();
}

class _TrackingCanvasState extends State<_TrackingCanvas> {
  static const _trailClips = [
    'assets/trail_vid/pom_cam1_segment1.mp4',
    'assets/trail_vid/pom_cam1_segment2.mp4',
    'assets/trail_vid/pom_cam1_segment3.mp4',
    'assets/trail_vid/pom_cam2_segment1.mp4',
    'assets/trail_vid/pom_cam2_segment2.mp4',
    'assets/trail_vid/pom_cam2_segment3.mp4',
  ];

  int _selectedCamera = 0;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFF101820), border: Border.all(color: const Color(0xFF26323B))),
        child: Column(children: [
          Expanded(
            child: Stack(children: [
              Positioned.fill(child: AssetVideoPlayer(key: ValueKey(_trailClips[_selectedCamera]), assetPath: _trailClips[_selectedCamera], label: 'CAM0${_selectedCamera < 3 ? 1 : 2}')),
              Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _GridPainter()))),
              if (widget.entities.isEmpty)
            const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.sensors_off, size: 42, color: Color(0xFFB5C5C7)),
                SizedBox(height: 12),
                Text('VIDEO TEST MODE', style: TextStyle(color: Color(0xFFB5C5C7), letterSpacing: 1.3, fontWeight: FontWeight.w600)),
                SizedBox(height: 6),
                Text('No indexed entities. Trail clips are playing for UI validation.', style: TextStyle(color: Color(0xFFE2F0F2), fontSize: 12)),
              ]))
          else
                Padding(padding: const EdgeInsets.all(18), child: Text('${widget.entities.length} entities received from /entities', style: const TextStyle(color: Color(0xFF8FA9AE)))),
              const Positioned(left: 18, bottom: 18, child: _Legend()),
            ]),
          ),
          SizedBox(
            height: 72,
            child: Row(children: [
              for (var index = 0; index < _trailClips.length; index++)
                Expanded(child: InkWell(onTap: () => setState(() => _selectedCamera = index), child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: index == _selectedCamera ? const Color(0xFF16323A) : const Color(0xFF111B22), border: Border.all(color: index == _selectedCamera ? const Color(0xFF00DAF3) : const Color(0xFF26323B))),
                  child: Center(child: Text('CAM0${index < 3 ? 1 : 2}\nSEGMENT ${(index % 3) + 1}', textAlign: TextAlign.center, style: TextStyle(color: index == _selectedCamera ? const Color(0xFF00DAF3) : const Color(0xFF8FA9AE), fontSize: 9))),
                )))
            ]),
          ),
        ]),
      );
}

class _EntityPanel extends StatelessWidget {
  const _EntityPanel({required this.entities, required this.selectedId, required this.onSelect});
  final List<Map<String, dynamic>> entities;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(0, 18, 18, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ENTITY REGISTER', style: TextStyle(color: Color(0xFF8FA9AE), fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Expanded(child: entities.isEmpty ? const _EmptyPanel() : ListView(children: [for (final entity in entities) _EntityTile(entity: entity, selected: entity['global_id'] == selectedId, onTap: () => onSelect(entity['global_id'] as String))])),
        ]),
      );
}

class _EntityTile extends StatelessWidget {
  const _EntityTile({required this.entity, required this.selected, required this.onTap});
  final Map<String, dynamic> entity;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        selected: selected,
        selectedTileColor: const Color(0xFF16323A),
        leading: Icon(entity['entity_type'] == 'person' ? Icons.person_outline : Icons.directions_car_outlined, color: selected ? const Color(0xFF00DAF3) : const Color(0xFF83999D)),
        title: Text(entity['global_id'] as String? ?? 'Unknown', style: const TextStyle(color: Color(0xFFD7E5E6), fontSize: 13)),
        subtitle: Text('${entity['current_camera'] ?? 'unknown'}  |  ${(entity['confidence'] as num?)?.toStringAsFixed(2) ?? '--'}', style: const TextStyle(color: Color(0xFF7E979C), fontSize: 11)),
      );
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();
  @override
  Widget build(BuildContext context) => const Text('Awaiting observations.\n\nThe panel will show global IDs, current camera, confidence, history, and predictions when the backend receives real video detections.', style: TextStyle(color: Color(0xFF71888C), height: 1.5, fontSize: 12));
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) => const Row(children: [
        _LegendItem(color: Color(0xFF00DAF3), label: 'CURRENT'),
        SizedBox(width: 14),
        _LegendItem(color: Color(0xFF6586FF), label: 'HISTORY'),
        SizedBox(width: 14),
        _LegendItem(color: Color(0xFFE8A65B), label: 'PREDICTED'),
      ]);
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 18, height: 2, color: color), const SizedBox(width: 5), Text(label, style: const TextStyle(color: Color(0xFF8FA9AE), fontSize: 9, letterSpacing: .8))]);
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x142C5661)..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
