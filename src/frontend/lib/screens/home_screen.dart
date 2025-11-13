import 'package:flutter/material.dart';
import 'package:frontend/services/media_service.dart';
import 'package:frontend/widgets/custom_video_widget.dart';
import 'package:frontend/weather_clock_display/presentation/info_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 30),
          child: Column(
            children: [
              const _TopHeader(),
              const SizedBox(height: 32),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          Expanded(
                            flex: 7,
                            child: _HeroSpotlight(
                              videoUrl:
                                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                            ),
                          ),
                          SizedBox(width: 32),
                          Expanded(
                            flex: 5,
                            child: _MemoBoardWithBadge(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    const _AppDock(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Expanded(
          flex: 4,
          child: ResponsiveInfoSection(cityName: 'Seoul'),
        ),
        SizedBox(width: 32),
        Expanded(
          flex: 5,
          child: _SearchField(),
        ),
        SizedBox(width: 32),
        _ProfileSummary(),
      ],
    );
  }
}

class _HeroSpotlight extends StatefulWidget {
  const _HeroSpotlight({required this.videoUrl});

  final String videoUrl;

  @override
  State<_HeroSpotlight> createState() => _HeroSpotlightState();
}

class _HeroSpotlightState extends State<_HeroSpotlight> {
  bool _openingMedia = false;
  String? _mediaSessionId;
  bool _autoLaunched = false;

  final MediaService _mediaService = mediaService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_autoLaunched) {
        _autoLaunched = true;
        _launchNativePlayback(auto: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double videoWidth = MediaQuery.of(context).size.width;
    final double videoHeight = videoWidth / (16 / 9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 34,
            offset: const Offset(0, 28),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: CustomVideoWidget(
              width: videoWidth,
              height: videoHeight,
              onPlay: null,
              caption: _openingMedia ? '재생 준비 중...' : 'TV에서 자동 재생 중...',
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'THE GENTLEMEN',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF181A21),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'An American expat tries to sell off his highly profitable marijuana '
                              'empire in London, triggering plots, schemes, bribery and blackmail in '
                              'an attempt to steal his domain out from under him.',
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Color(0xFF4C505C),
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(height: 22),
                              Wrap(
                                spacing: 14,
                                runSpacing: 12,
                                children: [
                                  _TagChip(label: '액션'),
                                  _TagChip(label: '코미디'),
                                  _TagChip(label: '영국'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _launchNativePlayback({bool auto = false}) async {
    final timestamp = DateTime.now().toString();
    debugPrint('[HomeScreen] [$timestamp] _launchNativePlayback called (auto: $auto)');
    debugPrint('[HomeScreen] [$timestamp] videoUrl: ${widget.videoUrl}');

    if (_openingMedia) {
      debugPrint('[HomeScreen] [$timestamp] Already opening media, skipping');
      return;
    }
    setState(() => _openingMedia = true);
    try {
      debugPrint('[HomeScreen] [$timestamp] Calling mediaService.open()...');
      final sessionId = await _mediaService.open(widget.videoUrl);
      final afterOpenTimestamp = DateTime.now().toString();
      debugPrint('[HomeScreen] [$afterOpenTimestamp] mediaService.open() returned: $sessionId');

      if (!mounted) {
        debugPrint('[HomeScreen] [$afterOpenTimestamp] Widget not mounted, returning');
        return;
      }
      if (sessionId == null) {
        debugPrint('[HomeScreen] [$afterOpenTimestamp] sessionId is null - open failed');
        if (!auto) {
          _showMessage('영상 재생을 시작하지 못했어요.');
        }
      } else {
        _mediaSessionId = sessionId;
        debugPrint('[HomeScreen] [$afterOpenTimestamp] Calling mediaService.play()...');
        await _mediaService.play(sessionId);
        final afterPlayTimestamp = DateTime.now().toString();
        debugPrint('[HomeScreen] [$afterPlayTimestamp] mediaService.play() completed');
        if (mounted && !auto) {
          _showMessage('TV에서 영상 재생을 시작했어요.');
        }
      }
    } catch (error) {
      final errorTimestamp = DateTime.now().toString();
      debugPrint('[HomeScreen] [$errorTimestamp] ERROR: $error');
      debugPrint('[HomeScreen] [$errorTimestamp] Error type: ${error.runtimeType}');
      if (mounted && !auto) {
        _showMessage('영상 재생 중 오류가 발생했어요.');
      }
    } finally {
      if (mounted) {
        setState(() => _openingMedia = false);
        final finalTimestamp = DateTime.now().toString();
        debugPrint('[HomeScreen] [$finalTimestamp] _launchNativePlayback completed');
      }
    }
  }

  @override
  void dispose() {
    if (_mediaSessionId != null) {
      _mediaService.close(_mediaSessionId!);
      _mediaSessionId = null;
    }
    super.dispose();
  }
}

class _MemoBoardWithBadge extends StatelessWidget {
  const _MemoBoardWithBadge();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: const [
        _MemoBoard(),
        Positioned(
          top: 46,
          right: -30,
          child: _VerticalBadge(label: '빈버드'),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF5F6372),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MemoBoard extends StatelessWidget {
  const _MemoBoard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 28,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Text(
                '메모하기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1F25),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.edit_note_rounded, color: Color(0xFF9AA0AF)),
            ],
          ),
          SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _MemoSticky(
                    title: '할일 메모',
                    content: '할일 정기 어쩌구',
                    color: Color(0xFF6DE4A5),
                  ),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: _MemoSticky(
                    title: '아이디어',
                    content: '',
                    color: Color(0xFFFFE28B),
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

class _MemoSticky extends StatelessWidget {
  const _MemoSticky({
    required this.title,
    required this.content,
    required this.color,
  });

  final String title;
  final String content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF272B33),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF3B3F46),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalBadge extends StatelessWidget {
  const _VerticalBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF4C1E1E),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(12, 18),
          ),
        ],
      ),
      child: RotatedBox(
        quarterTurns: 3,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppDock extends StatelessWidget {
  const _AppDock();

  static final List<_DockItem> _items = [
    _DockItem(icon: Icons.movie_outlined, label: 'Disney+', color: const Color(0xFF0E7FE1)),
    _DockItem(icon: Icons.movie_outlined, label: 'Disney+', color: const Color(0xFF0E7FE1)),
    _DockItem(icon: Icons.ondemand_video_rounded, label: 'Netflix', color: Colors.red),
    _DockItem(icon: Icons.movie_outlined, label: 'Disney+', color: const Color(0xFF0E7FE1)),
    _DockItem(icon: Icons.video_library_rounded, label: 'YouTube', color: Colors.redAccent),
    _DockItem(icon: Icons.play_circle_fill_rounded, label: 'Play', color: const Color(0xFF6F9CFF)),
    _DockItem(icon: Icons.web_rounded, label: 'Wavve', color: const Color(0xFFBF3EFF)),
    _DockItem(icon: Icons.grid_view_rounded, label: 'Apps', color: const Color(0xFF4A90E2)),
    _DockItem(icon: Icons.photo_rounded, label: 'Gallery', color: const Color(0xFFFF6F91)),
    _DockItem(icon: Icons.photo_rounded, label: 'Gallery', color: const Color(0xFFFF6F91)),
    _DockItem(icon: Icons.add_rounded, label: '추가', color: const Color(0xFFE0E3EC)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final _DockItem item in _items) _DockIcon(item: item),
        ],
      ),
    );
  }
}

class _DockItem {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}

class _DockIcon extends StatelessWidget {
  const _DockIcon({required this.item});

  final _DockItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color.withOpacity(0.18),
                item.color.withOpacity(0.32),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(item.icon, size: 32, color: item.color),
        ),
        const SizedBox(height: 8),
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6E7281),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: '무엇을 도와드릴까요?',
            hintStyle: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 16,
            ),
            border: InputBorder.none,
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Icon(Icons.search_rounded, size: 26),
            ),
            suffixIcon: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.mic_none_rounded, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.surfaceVariant,
            child: Icon(
              Icons.person_outline_rounded,
              color: colors.onSurfaceVariant,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '홍길동',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '다른 계정으로 전환하기',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7B7F8E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

