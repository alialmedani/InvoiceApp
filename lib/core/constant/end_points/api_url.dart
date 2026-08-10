import '../../classes/cashe_helper.dart';

// Get base URL from cache (user can set it dynamically)
String get baseUrl => CacheHelper.apiBaseUrl;
// String get baseUrl => 'https://localhost:44358/';
// String get baseUrl => 'https://api.uat.jasim-erp.com/';
// String get baseUrl => 'https://api.enjazist.enki-erp.com/';

/////auth_url////////////
String get loginUrl => '${baseUrl}connect/token';
String get registerRequestUrl => '${baseUrl}api/app/users/mobile-register';

///// profile page
String get getAllAttendanceUrl => '${baseUrl}api/hr/attendance/current_user';
String get createAttendanceUrl => '${baseUrl}api/hr/attendance';
String get getCurrentUserUrl => '${baseUrl}api/app/users/current';
String get setFaceEmbeddingUrl =>
    '${baseUrl}api/core/user/set-face-embedding-from-image';
String get setFaceEmbeddingsUrl =>
    '${baseUrl}api/core/user/set-face-embeddings-from-images';
String get createAttendanceWithFaceUrl =>
    '${baseUrl}api/hr/attendance/with-face-verification';
String get updateAttendanceNoteUrl => '${baseUrl}api/hr/attendance/{id}/note';
String get appConfigUrl => '${baseUrl}api/abp/application-configuration';
String get getEmployeesUrl => '${baseUrl}api/hr/employee';
String get serverTimeEndpoint => '${baseUrl}api/time';

///// face reset request
String get faceResetRequestUrl => '${baseUrl}api/hr/face-reset-request';
String get myFaceResetRequestsUrl =>
    '${baseUrl}api/hr/face-reset-request/my-requests';
String get completeMyFaceResetUrl =>
    '${baseUrl}api/hr/face-reset-request/complete-my-reenrollment';
