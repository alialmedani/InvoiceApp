  import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

Future<bool> checkTimeManipulation() async {
    try {
      final dio = Dio();
      final response = await dio
          .get('https://api.updater.jasim-erp.com/api/app/app-info')
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (kDebugMode) {
                print("Time check request timed out");
              }
              return Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 408,
              );
            },
          );

      if (response.statusCode == 200) {
        // Get server time from response headers
        final serverDateStr = response.headers.value('date');
        if (serverDateStr != null) {
          final serverTime = HttpDate.parse(serverDateStr);
          final deviceTime = DateTime.now().toUtc();
          final timeDifference = deviceTime.difference(serverTime).abs();

          if (kDebugMode) {
            print("Server time: $serverTime");
            print("Device time: $deviceTime");
            print("Time difference: ${timeDifference.inMinutes} minutes");
          }

          // If time difference is more than 5 minutes, consider it manipulated
          return timeDifference.inMinutes > 5;
        }
      }

      // If we can't check, allow the user through
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("Error checking time manipulation: $e");
      }
      // If there's an error (like no internet), allow the user through
      return false;
    }
  }