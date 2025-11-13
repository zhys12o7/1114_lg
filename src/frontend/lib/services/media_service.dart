import 'package:flutter/foundation.dart';
import 'media_service_interface.dart';
import 'media_service_web.dart' as web;
import 'media_service_stub.dart' as stub;

export 'media_service_interface.dart';

// 런타임에 환경을 확인하여 적절한 서비스 선택
MediaService get mediaService {
  debugPrint('[media] Selecting MediaService...');
  debugPrint('[media] kIsWeb: $kIsWeb');

  // 웹 환경이면 무조건 web service 사용
  if (kIsWeb) {
    debugPrint('[media] Using web.getMediaService()');
    return web.getMediaService();
  } else {
    debugPrint('[media] Using stub.getMediaService()');
    return stub.getMediaService();
  }
}
