import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../logic/weather_controller.dart';

/// 날씨 위젯 (디자인 명세서 버전)
///
/// 디자인 명세:
/// - 레이아웃: Horizontal Flexbox, items-center, justify-end
/// - 간격: gap 19px
/// - 패딩: bottom 6px
/// - 날씨 아이콘: 50×50px, 그라디언트 (#EFC977 → #E07256)
/// - 온도: Inter Regular 72px, #6B6B6B
/// - 섭씨 기호: 65×65px
class WeatherWidget extends StatefulWidget {
  final String? cityName;
  final Color? textColor;
  final bool showLoading;

  const WeatherWidget({
    super.key,
    this.cityName,
    this.textColor,
    this.showLoading = false,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  late WeatherController _weatherController;

  @override
  void initState() {
    super.initState();
    _weatherController = WeatherController();
    _weatherController.loadWeather(cityName: widget.cityName);
    if (widget.showLoading) {
      _weatherController.startAutoRefresh();
    }
  }

  @override
  void dispose() {
    _weatherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _weatherController,
      child: Consumer<WeatherController>(
        builder: (context, controller, child) {
          // 로딩 중이거나 에러 시 기본값 표시
          final weather = controller.weather;
          final temperature = weather?.temperature.toInt() ?? 17;
          final condition = weather?.condition ?? 'Clear';

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildWeatherIcon(controller),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          temperature.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 48,
                            fontWeight: FontWeight.w500,
                            color: widget.textColor ?? const Color(0xFF6B6B6B),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '°C',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: widget.textColor ?? const Color(0xFF6B6B6B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      condition,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: widget.textColor ?? const Color(0xFF6B6B6B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 날씨 아이콘 생성 (그라디언트 태양)
  Widget _buildWeatherIcon(WeatherController controller) {
    // 날씨 상태에 따라 아이콘 변경 가능
    final condition = controller.weather?.condition ?? '맑음';
    final isLoading = controller.isLoading;

    if (isLoading) {
      return SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(
            widget.textColor ?? const Color(0xFF6B6B6B),
          ),
        ),
      );
    }

    // 날씨에 따른 아이콘 선택
    IconData icon;
    if (condition.contains('비') || condition.contains('Rain')) {
      icon = Icons.water_drop;
    } else if (condition.contains('구름') ||
        condition.contains('흐림') ||
        condition.contains('Cloud')) {
      icon = Icons.cloud;
    } else {
      icon = Icons.wb_sunny; // 맑음 (기본)
    }

    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEFC977), // 밝은 주황
            Color(0xFFE07256), // 진한 주황
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 30, // 아이콘 크기 (50px 컨테이너의 6.25% inset 고려)
      ),
    );
  }
}

