import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'media_service_interface.dart';

MediaService getMediaService() {
  debugPrint('[media] Using Native webOS MediaService (MethodChannel)');
  return const _NativeWebOSMediaService();
}

class _NativeWebOSMediaService extends MediaService {
  const _NativeWebOSMediaService();

  static const platform = MethodChannel('com.lg.homescreen/luna');

  @override
  Future<String?> open(String uri, {Map<String, dynamic>? options}) async {
    final timestamp = DateTime.now().toString();
    debugPrint('[media] [$timestamp] open() called via MethodChannel');
    debugPrint('[media] [$timestamp] uri: $uri');

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

      debugPrint('[media] [$timestamp] Calling Luna Service: luna://com.webos.media');
      debugPrint('[media] [$timestamp] Method: open');
      debugPrint('[media] [$timestamp] Parameters: $parameters');

      final result = await platform.invokeMethod('callLunaService', {
        'service': 'luna://com.webos.media',
        'method': 'open',
        'parameters': parameters,
      });

      debugPrint('[media] [$timestamp] Luna Service response: $result');

      if (result != null && result is Map) {
        final sessionId = result['sessionId'] as String?;
        debugPrint('[media] [$timestamp] sessionId: $sessionId');
        return sessionId;
      }

      debugPrint('[media] [$timestamp] No sessionId in response');
      return null;
    } catch (e) {
      debugPrint('[media] [$timestamp] open FAILED: $e');
      return null;
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
    final timestamp = DateTime.now().toString();
    debugPrint('[media] [$timestamp] $method() called with sessionId: $sessionId');

    try {
      await platform.invokeMethod('callLunaService', {
        'service': 'luna://com.webos.media',
        'method': method,
        'parameters': {'sessionId': sessionId},
      });

      debugPrint('[media] [$timestamp] $method SUCCESS');
    } catch (e) {
      debugPrint('[media] [$timestamp] $method FAILED: $e');
    }
  }
}
