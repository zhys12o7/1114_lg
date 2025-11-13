import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoWidget extends StatefulWidget {
  const CustomVideoWidget({
    super.key,
    String? videoUrl,
    this.width,
    this.height,
    this.autoplay = true,
    this.looping = true,
    this.volume = 1.0,
  }) : videoUrl = videoUrl ?? defaultVideoUrl;

  final String videoUrl;
  final double? width;
  final double? height;
  final bool autoplay;
  final bool looping;
  final double volume;

  static const String defaultVideoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  @override
  State<CustomVideoWidget> createState() => _CustomVideoWidgetState();
}

class _CustomVideoWidgetState extends State<CustomVideoWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(CustomVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initializeVideo(replace: true);
    } else {
      _controller
        ..setLooping(widget.looping)
        ..setVolume(_clampVolume(widget.volume));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeVideo({bool replace = false}) {
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    controller
      ..setLooping(widget.looping)
      ..setVolume(_clampVolume(widget.volume));

    final future = controller.initialize().then((_) {
      if (widget.autoplay) {
        controller.play();
      }
    });

    if (replace) {
      _controller.dispose();
    }

    _controller = controller;
    _initializeFuture = future;
    setState(() {});
  }

  double _clampVolume(double volume) => volume.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final double width = widget.width ?? MediaQuery.of(context).size.width;
    final double height = widget.height ?? width / (16 / 9);

    return SizedBox(
      width: width,
      height: height,
      child: FutureBuilder<void>(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller.value.isInitialized) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: VideoPlayer(_controller),
              ),
            );
          }

          if (snapshot.hasError) {
            return _VideoError(message: snapshot.error.toString());
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class _VideoError extends StatelessWidget {
  const _VideoError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.errorContainer,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '동영상을 불러오지 못했어요\n$message',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onErrorContainer),
          ),
        ),
      ),
    );
  }
}

