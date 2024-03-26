import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collevo/models/request.dart';
import 'package:collevo/services/preferences/preferences_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class RequestUploadService {
  Future<void> uploadRequest(Request request) async {
    PreferencesService preferencesService = PreferencesService();
    String? batch = await preferencesService.getBatch();
    CollectionReference requestsRef = FirebaseFirestore.instance
        .collection('students')
        .doc(batch)
        .collection('requests');

    try {
      await requestsRef.doc(request.requestId).set(request.toMap());
      // print('Request uploaded successfully with ID: ${request.requestId}');
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'RequestUploadService failed to upload request',
        information: [
          'requestId: ${request.requestId}',
          'batch: $batch',
        ],
      );
      // print('Error uploading request: $e');
    }
  }
}
