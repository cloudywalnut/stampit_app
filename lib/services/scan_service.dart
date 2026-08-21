import 'package:stampit_app/models/scan_result.dart';
import 'package:stampit_app/services/api_client.dart';

/// Wraps POST /api/scan — same endpoint and payload shape ScanClient.tsx
/// posts to on the web dashboard.
class ScanService {
  Future<ScanResult> stamp({
    required String token,
    String? objectId,
    String? code,
    required int multiplier,
  }) async {
    final json = await ApiClient.post(
      '/api/scan',
      token: token,
      body: {if (objectId != null) 'objectId': objectId, if (code != null) 'code': code, 'multiplier': multiplier},
    );
    return ScanResult.fromJson(json);
  }
}
