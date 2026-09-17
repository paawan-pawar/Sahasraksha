import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AssetVideoPlayer extends StatefulWidget {
  const AssetVideoPlayer({required this.assetPath, this.label, super.key});

  final String assetPath;
  final String? label;

  @override
  State<AssetVideoPlayer> createState() => _AssetVideoPlayerState();
}

class _AssetVideoPlayerState extends State<AssetVideoPlayer> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController(widget.assetPath);
  }

  @override
  void didUpdateWidget(covariant AssetVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _disposeController();
      _initController(widget.assetPath);
    }
  }

  void _initController(String assetPath) {
    _hasError = false;
    final controller = VideoPlayerController.asset(assetPath)
      ..setLooping(true)
      ..setVolume(0);

    _controller = controller;

    controller
        .initialize()
        .timeout(const Duration(seconds: 15))
        .then((_) {
      if (!mounted || _controller != controller) {
        // Widget was disposed or path changed during init — discard.
        controller.dispose();
        return;
      }
      setState(() {});
      controller.play();
    }).catchError((Object error) {
      if (!mounted || _controller != controller) {
        controller.dispose();
        return;
      }
      setState(() => _hasError = true);
    });
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (_hasError) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off, color: Color(0xFF8FA9AE), size: 28),
              const SizedBox(height: 6),
              const Text(
                'Video unavailable',
                style: TextStyle(color: Color(0xFF8FA9AE), fontSize: 11),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() => _hasError = false);
                  _disposeController();
                  _initController(widget.assetPath);
                },
                child: const Text('Retry', style: TextStyle(color: Color(0xFF00DAF3), fontSize: 11)),
              ),
            ],
          ),
        ),
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
        Positioned(
          left: 8,
          right: 8,
          bottom: 8,
          child: Row(
            children: [
              IconButton(
                tooltip: controller.value.isPlaying ? 'Pause video' : 'Play video',
                onPressed: () {
                  setState(() {
                    controller.value.isPlaying ? controller.pause() : controller.play();
                  });
                },
                icon: Icon(
                  controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Color(0xFF00DAF3),
                    bufferedColor: Color(0x665E7980),
                    backgroundColor: Color(0xAA101820),
                  ),
                ),
              ),
              if (widget.label != null) ...[
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(color: const Color(0xCC101820), borderRadius: BorderRadius.circular(3)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Text(widget.label!, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
