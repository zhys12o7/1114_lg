import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frontend/webos_service_helper/utils.dart' as webos_utils;

import 'media_service_interface.dart';

MediaService getMediaService() {
  debugPrint('[MediaService] WebOSServiceBridge 사용');
  return const _NativeWebOSMediaService();
}

class _NativeWebOSMediaService extends MediaService {
  const _NativeWebOSMediaService();

  @override
  Future<String?> open(String uri, {Map<String, dynamic>? options}) async {
    try {
      final parameters = <String, dynamic>{
        'uri': uri,
        'type': 'media',
        'mediaFormat': 'video',
        'option': {
          'mediaTransportType': uri.startsWith('http') ? 'STREAMING' : 'FILE',
        },
      };
      if (options != null) {
        parameters.addAll(options);
      }

      debugPrint('[Luna API] 호출: luna://com.webos.media/load');

      final result = await webos_utils.callOneReply(
        uri: 'luna://com.webos.media',
        method: 'load',
        payload: parameters,
      );

      debugPrint('[Luna API] 전체 응답: $result');

      if (result != null && result['returnValue'] == true) {
        final mediaId = result['mediaId'] as String?;
        debugPrint('[Luna API] ✅ 성공 - mediaId: $mediaId');
        return mediaId;
      }

      // 실패 시 에러 메시지 출력
      final errorText = result?['errorText'] ?? 'Unknown error';
      final errorCode = result?['errorCode'] ?? 'N/A';
      debugPrint('[Luna API] ❌ 실패 - returnValue: ${result?['returnValue']}');
      debugPrint('[Luna API] ❌ 에러 코드: $errorCode');
      debugPrint('[Luna API] ❌ 에러 메시지: $errorText');
      return null;
    } catch (e) {
      debugPrint('[Luna API] ❌ 에러: $e');
      return null;
    }
  }

  @override
  Future<void> setDisplayWindow(String sessionId, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    try {
      debugPrint('[Luna API] 호출: luna://com.webos.media/setDisplayWindow');

      final result = await webos_utils.callOneReply(
        uri: 'luna://com.webos.media',
        method: 'setDisplayWindow',
        payload: {
          'mediaId': sessionId,
          'sink': 'MAIN',
          'fullScreen': true,
          'source': {
            'x': x,
            'y': y,
            'width': width,
            'height': height,
          },
          'destination': {
            'x': 0,
            'y': 0,
            'width': 1920,
            'height': 1080,
          },
        },
      );

      if (result != null && result['returnValue'] == true) {
        debugPrint('[Luna API] ✅ setDisplayWindow 성공');
      } else {
        debugPrint('[Luna API] ❌ setDisplayWindow 실패');
      }
    } catch (e) {
      debugPrint('[Luna API] ❌ setDisplayWindow 에러: $e');
    }
  }

  @override
  Future<void> play(String sessionId) => _invokeSimple('play', sessionId);

  @override
  Future<void> pause(String sessionId) => _invokeSimple('pause', sessionId);

  @override
  Future<void> stop(String sessionId) => _invokeSimple('stop', sessionId);

  @override
  Future<void> close(String sessionId) => _invokeSimple('close', sessionId);

  Future<void> _invokeSimple(String method, String sessionId) async {
    try {
      debugPrint('[Luna API] 호출: luna://com.webos.media/$method');

      final result = await webos_utils.callOneReply(
        uri: 'luna://com.webos.media',
        method: method,
        payload: {'mediaId': sessionId}, // sessionId는 실제로 mediaId
      );

      if (result != null && result['returnValue'] == true) {
        debugPrint('[Luna API] ✅ $method 성공');
      } else {
        debugPrint('[Luna API] ❌ $method 실패');
      }
    } catch (e) {
      debugPrint('[Luna API] ❌ $method 에러: $e');
    }
  }
}
