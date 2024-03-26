import 'package:collevo/enums/status_enum.dart';
import 'package:collevo/models/request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collevo/services/preferences/preferences_service.dart';

class RequestsFetchService {
  Future<List<Request>> fetchMyRequestsByStatus(Status status) async {
    try {
      final String? currentUserUID = await PreferencesService().getUid();
      final String? batch = await PreferencesService().getBatch();

      final querySnapshot = await FirebaseFirestore.instance
          .collection("students")
          .doc(batch)
          .collection('requests')
          .where('created_by', isEqualTo: currentUserUID)
          .where('status', isEqualTo: status.index)
          .get();

      final List<Request> myRequests = querySnapshot.docs.map((doc) {
        // Safely accessing each field with fallback values for potentially missing fields
        final data = doc.data();
        final Timestamp createdAtTimestamp = data['created_at'];
        final DateTime createdAtDate = createdAtTimestamp.toDate();

        return Request(
          requestId: data['request_id'],
          activityId: data['activity_id'],
          createdBy: data['created_by'],
          createdAt: createdAtDate,
          imageUrl: data['image_url'],
          status: Status.values[data['status']],
          activityType: data['activity_type'],
          activity: data['activity'],
          activityLevel: data['activity_level'],
          batch: data['batch'],
          yearActivityDoneIn: data['year_activity_done_in'],
          optionalMessage: data.containsKey('optional_message')
              ? data['optional_message']
              : '',
          awardedPoints:
              data.containsKey('awarded_points') ? data['awarded_points'] : -1,
          optionalRemark: data.containsKey('optional_remark')
              ? data['optional_remark']
              : '',
        );
      }).toList();

      return myRequests;
    } catch (e) {
      return [];
    }
  }

  Future<List<Request>> fetchApprovedRequests() async {
    return fetchMyRequestsByStatus(Status.approved);
  }

  Future<List<Request>> fetchPendingRequests() async {
    return fetchMyRequestsByStatus(Status.pending);
  }

  Future<List<Request>> fetchRejectedRequests() async {
    return fetchMyRequestsByStatus(Status.rejected);
  }
}
