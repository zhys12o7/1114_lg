import 'package:flutter/foundation.dart';
import 'package:frontend/webos_service_helper/utils.dart' as webos_utils;
import '../data/repository_factory.dart';

/// 통합 위치 서비스
///
/// 역할: 환경에 따라 자동으로 적절한 위치(도시) 정보 제공
/// - webOS 환경: 시스템 설정의 도시 정보 사용 (WebOSServiceBridge)
/// - 일반 환경: 기본 도시 반환 (서울)
class LocationService {
  static const String _defaultCity = 'Seoul';

  /// 현재 도시 가져오기
  ///
  /// webOS: 시스템 설정에서 도시 정보 가져오기
  /// 로컬: 기본 도시 반환
  Future<String> getCurrentCity() async {
    if (RepositoryFactory.isWebOS) {
      return await _getCityWebOS();
    } else {
      return _getCityLocal();
    }
  }

  /// webOS 환경에서 도시 가져오기
  ///
  /// luna://com.webos.service.systemservice/getPreferences 호출
  /// 시스템 설정의 도시 정보 반환
  Future<String> _getCityWebOS() async {
    debugPrint('webOS 환경: 시스템 설정에서 도시 정보 가져오기 (WebOSServiceBridge)');

    try {
      final result = await webos_utils.callOneReply(
        uri: 'luna://com.webos.service.systemservice',
        method: 'getPreferences',
        payload: {
          'keys': ['city']
        },
      );

      if (result == null) {
        debugPrint('시스템 설정 응답 없음 - 기본 도시 사용');
        return _defaultCity;
      }

      if (result['returnValue'] == true) {
        // 도시 정보 추출
        final settings = result['settings'] as Map<dynamic, dynamic>?;
        if (settings != null) {
          final city = settings['city'] as String?;
          if (city != null && city.isNotEmpty) {
            debugPrint('시스템 도시: $city');
            return city;
          }
        }
      }

      debugPrint('도시 정보 없음 - 기본 도시 사용');
      return _defaultCity;
    } catch (e) {
      debugPrint('시스템 설정 가져오기 실패: $e - 기본 도시 사용');
      return _defaultCity;
    }
  }

  /// 로컬 환경에서 도시 가져오기
  ///
  /// 기본 도시 반환
  String _getCityLocal() {
    debugPrint('로컬 환경: 기본 도시 사용 ($_defaultCity)');
    return _defaultCity;
  }
}
