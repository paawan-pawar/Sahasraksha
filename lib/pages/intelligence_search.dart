import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../routes/side_navigation_bar.dart' as navigation;
import '../widgets/kavach_logo.dart';
import '../widgets/asset_video_player.dart';
import '../services/api_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IBVAP - Scene Search',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: const Color(0xFF0F131C),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const IntelligenceSearchView(),
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
  static const Color surfaceContainerHighest = Color(0xFF31353F);
  static const Color surfaceVariant = Color(0xFF31353F);
  static const Color onSurface = Color(0xFFDFE2EF);
  static const Color onSurfaceVariant = Color(0xFFBAC9CC);
  static const Color primary = Color(0xFF00DAF3);
  static const Color primaryContainer = Color(0xFF00E5FF);
  static const Color primaryFixedDim = Color(0xFF00DAF3);
  static const Color onPrimary = Color(0xFF00363D);
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color outline = Color(0xFF849396);
  static const Color outlineVariant = Color(0xFF3B494C);
  static const Color surfaceTint = Color(0xFF00DAF3);
  static const Color secondary = Color(0xFFC1C6D9);
  static const Color secondaryContainer = Color(0xFF434959);
}

class IntelligenceSearchView extends StatefulWidget {
  const IntelligenceSearchView({super.key});

  @override
  State<IntelligenceSearchView> createState() => _IntelligenceSearchViewState();
}

class _IntelligenceSearchViewState extends State<IntelligenceSearchView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchStatus = 'INDEX READY';
  String _lastQuery = '';
  List<Map<String, dynamic>> _searchHistory = const [];
  List<Map<String, dynamic>> _searchResults = const [];
  bool _hasSearched = false;
  bool _isSearching = false;
  bool _camerasScanned = false;

  static const Map<String, String> cameraVideoAssets = {
    'CAM01': 'assets/videos/cam01_people_detection.mp4',
    'CAM02': 'assets/videos/cam02_person_bicycle_car.mp4',
    'CAM03': 'assets/videos/cam03_car_detection.mp4',
    'CAM04': 'assets/videos/cam04_worker_zone.mp4',
    'CAM05': 'assets/videos/cam05_store_aisle.mp4',
    'CAM06': 'assets/videos/cam06_face_demographics_walking.mp4',
  };

  @override
  void initState() {
    super.initState();
    _checkIndexAndHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkIndexAndHistory() async {
    await _loadSearchHistory();
    try {
      final stats = await http.get(Uri.parse('${ApiConfig.sceneSearchBaseUrl}/statistics'));
      if (stats.statusCode == 200) {
        final data = jsonDecode(stats.body) as Map<String, dynamic>;
        final count = (data['events'] as num?) ?? 0;
        if (count > 0 && mounted) {
          _camerasScanned = true;
          setState(() {
            _searchStatus = 'INDEX READY ($count EVENTS)';
          });
        }
      }
    } catch (_) {
      // Backend status will update on search
    }
  }

  Future<void> _loadSearchHistory() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.sceneSearchBaseUrl}/search/history'));
      if (!mounted || response.statusCode != 200) return;
      setState(() {
        _searchHistory = (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
      });
    } catch (_) {
      // The history panel remains available when the search service is offline.
    }
  }

  void _resetToLiveFeeds() {
    setState(() {
      _searchController.clear();
      _hasSearched = false;
      _lastQuery = '';
      _searchResults = const [];
      _searchStatus = 'LIVE CAMERA FEEDS';
    });
  }

  Future<void> _runSearch(String value) async {
    final query = value.trim();
    if (query.isEmpty) {
      _resetToLiveFeeds();
      return;
    }
    setState(() {
      _hasSearched = true;
      _isSearching = true;
      _lastQuery = query;
      _searchStatus = 'SEARCHING...';
    });
    try {
      // If we haven't confirmed cameras are scanned, check if events already exist in db
      if (!_camerasScanned) {
        try {
          final stats = await http.get(Uri.parse('${ApiConfig.sceneSearchBaseUrl}/statistics'));
          if (stats.statusCode == 200) {
            final statsData = jsonDecode(stats.body) as Map<String, dynamic>;
            if (((statsData['events'] as num?) ?? 0) > 0) {
              _camerasScanned = true;
            }
          }
        } catch (_) {}

        // Only scan if database genuinely has 0 indexed events
        if (!_camerasScanned) {
          setState(() => _searchStatus = 'SCANNING CAMERAS...');
          final scan = await http.post(
            Uri.parse('${ApiConfig.sceneSearchBaseUrl}/process/cameras'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'config_path': 'config/cameras.yaml', 'model_name': 'yolo11n.pt', 'sample_fps': 2.0}),
          );
          _camerasScanned = scan.statusCode == 200;
          if (scan.statusCode != 200 && mounted) {
            setState(() => _searchStatus = 'DETECTOR UNAVAILABLE');
          }
        }
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.sceneSearchBaseUrl}/search'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final payload = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (payload['results'] as List).cast<Map<String, dynamic>>();
        setState(() {
          _isSearching = false;
          _searchResults = results;
          _searchStatus = '${results.length} MATCHES FOUND';
        });
      } else {
        setState(() {
          _isSearching = false;
          _searchStatus = 'API ERROR ${response.statusCode}';
          _searchResults = const [];
        });
      }
      await _loadSearchHistory();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _searchStatus = 'BACKEND OFFLINE';
        _searchResults = const [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Navigation Bar
          const TopNavBar(),
          // Main Content
          Expanded(
            child: Row(
              children: [
                // Side Navigation Bar
                const navigation.AppSideNavigationBar(),
                // Main Viewport
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.background,
                    child: Column(
                      children: [
                        // Search Header Area
                        _buildSearchHeader(),
                        const SizedBox(height: 16),
                        // Main Content (Results + Side Panel)
                        Expanded(
                          child: Row(
                            children: [
                              // Results Gallery
                              Expanded(
                                child: _buildResultsGallery(),
                              ),
                              const SizedBox(width: 24),
                              // Side Panel (Search History) - only on large screens
                              if (MediaQuery.of(context).size.width > 1200)
                                _buildSearchHistory(),
                            ],
                          ),
                        ),
                        // AI Suggested Searches (Bottom pinned)
                        _buildAISuggestions(),
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

  Widget _buildSearchHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Stack(
            children: [
              TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1),
                  ),
                  hintText: 'Describe what you need... e.g., "Find all red vehicles near Gate 2 between 6-8 AM"',
                  hintStyle: const TextStyle(
                    color: AppColors.outlineVariant,
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.manage_search,
                    color: AppColors.primaryFixedDim,
                    size: 28,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 56),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.surfaceContainerLowest,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                          _runSearch(_searchController.text);
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'INITIATE',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 120),
                ),
                onSubmitted: (value) {
                  _runSearch(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text(
                'Filters:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.5,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterChip('All', !_hasSearched),
              _buildFilterChip('People', _hasSearched && _lastQuery == 'person'),
              _buildFilterChip('Vehicles', _hasSearched && _lastQuery == 'car'),
              _buildFilterChip('Faces', false),
              _buildFilterChip('Plates', false),
              Container(
                width: 1,
                height: 16,
                color: AppColors.outlineVariant,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              _buildFilterChipWithIcon(Icons.calendar_today, 'Yesterday', false),
              _buildFilterChipWithIcon(Icons.calendar_month, 'This Week', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: isActive ? AppColors.surfaceContainerHigh : AppColors.surfaceContainer,
          foregroundColor: isActive ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
          side: BorderSide(
            color: isActive ? AppColors.primaryContainer : AppColors.outlineVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: () {
          if (label == 'All') {
            _resetToLiveFeeds();
          } else if (label == 'People' || label == 'Faces') {
            _searchController.text = 'person';
            _runSearch('person');
          } else if (label == 'Vehicles' || label == 'Plates') {
            _searchController.text = 'car';
            _runSearch('car');
          }
        },
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChipWithIcon(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: AppColors.surfaceContainer,
          foregroundColor: AppColors.onSurfaceVariant,
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: () {
          if (label == 'Yesterday') {
            _searchController.text = 'CAM02';
            _runSearch('CAM02');
          } else {
            _searchController.text = 'CAM01';
            _runSearch('CAM01');
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsGallery() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      _hasSearched ? 'Search Results' : 'Active Camera Feeds',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (_hasSearched) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.close, size: 14),
                        label: const Text('Clear', style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryFixedDim,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _resetToLiveFeeds,
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: AppColors.outlineVariant),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _searchStatus,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryFixedDim,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content: Loading / Empty / Grid
          Expanded(
            child: _isSearching
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryContainer, strokeWidth: 2.5),
                        SizedBox(height: 16),
                        Text(
                          'Searching indexed detections across cameras...',
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : _hasSearched && _searchResults.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off, size: 48, color: AppColors.outline),
                              const SizedBox(height: 16),
                              Text(
                                'No events matched "$_lastQuery"',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Try searching: "car", "person", "bicycle", "CAM01", "CAM02", "inspection_lane", "gate 3", "truck"',
                                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.videocam, size: 16),
                                label: const Text('Return to Live Camera Feeds'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  foregroundColor: AppColors.primaryFixedDim,
                                ),
                                onPressed: _resetToLiveFeeds,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 1;
                            if (constraints.maxWidth > 500) crossAxisCount = 2;
                            if (constraints.maxWidth > 800) crossAxisCount = 3;
                            if (constraints.maxWidth > 1100) crossAxisCount = 4;

                            return GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.8,
                              children: _hasSearched && _searchResults.isNotEmpty
                                  ? [for (final result in _searchResults) _buildSearchResultCard(result)]
                                  : const [
                                      ResultCard(
                                        imageUrl: '',
                                        title: 'CAM01: Perimeter Fence',
                                        time: 'LIVE MONITORING',
                                        location: 'CAM01 / outer_fence',
                                        match: 'LIVE FEED',
                                        tag: 'Outer Fence',
                                        tagColor: AppColors.primaryContainer,
                                        height: 160,
                                        videoAsset: 'assets/videos/cam01_people_detection.mp4',
                                      ),
                                      ResultCard(
                                        imageUrl: '',
                                        title: 'CAM02: Inspection Lane',
                                        time: 'LIVE MONITORING',
                                        location: 'CAM02 / inspection_lane',
                                        match: 'LIVE FEED',
                                        tag: 'Inspection Lane',
                                        tagColor: AppColors.secondary,
                                        height: 160,
                                        videoAsset: 'assets/videos/cam02_person_bicycle_car.mp4',
                                      ),
                                      ResultCard(
                                        imageUrl: '',
                                        title: 'CAM03: Gate 3 Entry',
                                        time: 'LIVE MONITORING',
                                        location: 'CAM03 / gate_3',
                                        match: 'LIVE FEED',
                                        tag: 'Gate 3',
                                        tagColor: AppColors.primaryContainer,
                                        height: 160,
                                        videoAsset: 'assets/videos/cam03_car_detection.mp4',
                                      ),
                                      ResultCard(
                                        imageUrl: '',
                                        title: 'CAM04: Service Road',
                                        time: 'LIVE MONITORING',
                                        location: 'CAM04 / service_road',
                                        match: 'LIVE FEED',
                                        tag: 'Service Road',
                                        tagColor: AppColors.primaryContainer,
                                        height: 160,
                                        videoAsset: 'assets/videos/cam04_worker_zone.mp4',
                                      ),
                                      ResultCard(
                                        imageUrl: '',
                                        title: 'CAM05: Store Aisle',
                                        time: 'LIVE MONITORING',
                                        location: 'CAM05 / gate_5',
                                        match: 'LIVE FEED',
                                        tag: 'Store Aisle',
                                        tagColor: AppColors.secondary,
                                        height: 160,
                                        videoAsset: 'assets/videos/cam05_store_aisle.mp4',
                                      ),
                                      ResultCard(
                                        imageUrl: '',
                                        title: 'CAM06: Border Walkway',
                                        time: 'LIVE MONITORING',
                                        location: 'CAM06 / border_road',
                                        match: 'LIVE FEED',
                                        tag: 'Border Road',
                                        tagColor: AppColors.secondary,
                                        height: 160,
                                        videoAsset: 'assets/videos/cam06_face_demographics_walking.mp4',
                                      ),
                                    ],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> result) {
    final thumbnail = _resolveMediaUrl(result['thumbnail_url'] as String?);
    final timestamp = DateTime.tryParse(result['timestamp'] as String? ?? '');
    final attributes = (result['attributes'] as Map?)?.cast<String, dynamic>() ?? const {};
    final objectType = (result['object_type'] as String? ?? 'object').toUpperCase();
    final cameraId = (result['camera_id'] as String? ?? 'CAM01').toUpperCase();
    final zone = result['zone'] as String? ?? 'Active Zone';
    final similarity = ((result['similarity'] as num?) ?? 1.0) * 100;
    final videoAsset = cameraVideoAssets[cameraId] ?? 'assets/videos/cam01_people_detection.mp4';
    final tagText = (attributes['vehicle_type'] as String?)?.toUpperCase() ??
        (attributes['shirt_color'] as String?)?.toUpperCase() ??
        objectType;

    return ResultCard(
      imageUrl: thumbnail ?? '',
      title: '$objectType DETECTED',
      time: timestamp != null
          ? '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')} - Today'
          : 'Indexed Event',
      location: '$cameraId / $zone',
      match: '${similarity.round()}% Match',
      tag: tagText,
      tagColor: AppColors.primaryContainer,
      height: 160,
      videoAsset: videoAsset,
    );
  }

  String? _resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return path.startsWith('http') ? path : '${ApiConfig.sceneSearchBaseUrl}$path';
  }

  Widget _buildSearchHistory() {
    return Container(
      width: 288,
      decoration: BoxDecoration(
        color: const Color(0xFF121826),
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.outlineVariant),
              ),
              color: AppColors.surfaceContainerHigh,
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: AppColors.onSurfaceVariant, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Search History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: _searchHistory.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('No searches yet. Submit a query to create history.', style: TextStyle(color: AppColors.outline, fontSize: 11)),
                      ),
                    ]
                  : [for (final item in _searchHistory) _buildHistoryItem(item)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final evidence = (item['evidence'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final searchedAt = DateTime.tryParse(item['searched_at'] as String? ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(color: Colors.transparent, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['query'] as String? ?? 'Unknown query',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
              fontFamily: 'JetBrains Mono',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item['result_count'] ?? 0} match${item['result_count'] == 1 ? '' : 'es'}  ${searchedAt == null ? '' : _formatHistoryTime(searchedAt)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.outline,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                size: 14,
                color: AppColors.outline,
              ),
            ],
          ),
          if (evidence.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 54,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [for (final result in evidence) _historyEvidence(result)],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _historyEvidence(Map<String, dynamic> result) {
    final thumbnail = result['thumbnail_url'] as String?;
    final imageUrl = thumbnail == null || thumbnail.isEmpty
      ? null
      : thumbnail.startsWith('http')
        ? thumbnail
        : '${ApiConfig.sceneSearchBaseUrl}$thumbnail';
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: AppColors.outlineVariant)),
        child: imageUrl == null
          ? const Icon(Icons.photo_camera_back_outlined, color: AppColors.primaryFixedDim, size: 20)
          : Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: AppColors.outline)),
    );
  }

  String _formatHistoryTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildAISuggestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        border: const Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppColors.primaryContainer,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Text(
            'AI Suggestions:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSuggestionChip('Vehicles: "car"', 'car'),
                  const SizedBox(width: 8),
                  _buildSuggestionChip('People: "person"', 'person'),
                  const SizedBox(width: 8),
                  _buildSuggestionChip('Bicycles: "bicycle"', 'bicycle'),
                  const SizedBox(width: 8),
                  _buildSuggestionChip('Trucks: "truck"', 'truck'),
                  const SizedBox(width: 8),
                  _buildSuggestionChip('Camera 2: "CAM02"', 'CAM02'),
                  const SizedBox(width: 8),
                  _buildSuggestionChip('Gate 3: "gate 3"', 'gate 3'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label, String query) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        _searchController.text = query;
        _runSearch(query);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF121826),
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface,
            fontFamily: 'Inter',
          ),
        ),
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
          const SizedBox.shrink(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: AppColors.outlineVariant),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monitor_heart,
                      color: AppColors.primaryFixedDim,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'SYS: NOMINAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryFixedDim,
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.onSurfaceVariant),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
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

class SideNavBar extends StatelessWidget {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      color: AppColors.surfaceContainerLowest,
      child: Column(
        children: [
          // Brand Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.onSurface),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                const KavachLogo(size: 40, padding: EdgeInsets.zero),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'IBVAP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const Text(
                      'Border Security',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.outlineVariant, height: 1),
          // Navigation Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildNavItem(Icons.dashboard, 'Command Center', false),
                  _buildNavItem(Icons.analytics, 'Detection Engine', false),
                  _buildNavItem(Icons.query_stats, 'AI Shadow & Trails', false),
                  _buildNavItem(Icons.search, 'Scene Search', true),
                  _buildNavItem(Icons.warning, 'Alerts & Risk', false),
                  _buildNavItem(Icons.radar, 'Coverage Intel', false),
                  _buildNavItem(Icons.map, 'Terrain Models', false),
                  _buildNavItem(Icons.settings, 'Admin', false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Container(
        decoration: BoxDecoration(
          color: active ? AppColors.surfaceContainerHigh : Colors.transparent,
          border: active
              ? const Border(left: BorderSide(color: AppColors.primaryFixedDim, width: 2))
              : null,
          borderRadius: BorderRadius.circular(0),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: active ? AppColors.primaryFixedDim : AppColors.onSurfaceVariant,
            size: 20,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: active ? AppColors.onSurface : AppColors.onSurfaceVariant,
            ),
          ),
          dense: true,
          visualDensity: const VisualDensity(vertical: -2),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          onTap: () {},
        ),
      ),
    );
  }
}

class ResultCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String time;
  final String location;
  final String match;
  final String tag;
  final Color tagColor;
  final double height;
  final String? videoAsset;

  const ResultCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.time,
    required this.location,
    required this.match,
    required this.tag,
    required this.tagColor,
    required this.height,
    this.videoAsset,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  // Always true by default so every video runs in a loop continuously!
  bool _playingVideo = true;

  @override
  Widget build(BuildContext context) {
    final isLive = widget.match.contains('LIVE');
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121826),
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Video area
          Container(
            height: widget.height,
            width: double.infinity,
            color: Colors.black,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.95,
                    child: _playingVideo && widget.videoAsset != null
                        ? AssetVideoPlayer(
                            key: ValueKey(widget.videoAsset),
                            assetPath: widget.videoAsset!,
                            label: widget.tag.toUpperCase(),
                          )
                        : widget.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[900],
                                  child: const Center(
                                    child: Icon(Icons.videocam_outlined, color: AppColors.outlineVariant, size: 32),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.black,
                                child: const Center(
                                  child: Icon(Icons.videocam_outlined, color: AppColors.outlineVariant, size: 32),
                                ),
                              ),
                  ),
                ),
                // Match or Live Feed badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLive ? const Color(0xE60A2A20) : AppColors.surfaceContainer.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isLive ? const Color(0xFF00FF9D) : AppColors.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLive ? Icons.fiber_manual_record : Icons.radar,
                          color: isLive ? const Color(0xFF00FF9D) : AppColors.primaryContainer,
                          size: isLive ? 10 : 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.match,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isLive ? FontWeight.bold : FontWeight.w500,
                            color: isLive ? const Color(0xFF00FF9D) : AppColors.primaryContainer,
                            fontFamily: 'JetBrains Mono',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Location badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.location,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.time,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.tagColor.withOpacity(0.1),
                    border: Border(left: BorderSide(color: widget.tagColor, width: 2)),
                  ),
                  child: Text(
                    widget.tag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: widget.tagColor,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: const BorderSide(color: AppColors.primaryFixedDim),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      if (widget.videoAsset != null) {
                        setState(() => _playingVideo = !_playingVideo);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _playingVideo ? Icons.loop : Icons.play_arrow,
                          color: AppColors.primaryFixedDim,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _playingVideo ? 'Continuous Loop' : 'Play Video',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryFixedDim,
                          ),
                        ),
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