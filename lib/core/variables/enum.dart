import 'package:flutter/material.dart';
import '../constant/app_colors/app_colors.dart';

enum Gender { male, female }

enum AttendanceRecordType {
  checkIn,
  checkOut,
  onCall,
  onBreak,
  duty,
  remoteWorkIn,
  remoteWorkOut,
}

enum MaritalStatus { single, married, divorced, widow }

enum NationalityType { iraqi, arab, foreigner }

enum AffiliateRequestStatusEnum { pending, inProgress, approved, rejected }

// ============ ATTENDANCE TYPE METADATA ============
class AttendanceTypeMeta {
  final String titleKey; // localization key
  final IconData icon;
  final Color color;

  AttendanceTypeMeta({
    required this.titleKey,
    required this.icon,
    required this.color,
  });
}

// Centralized mapping for all attendance types
AttendanceTypeMeta metaForAttendanceType(BuildContext context, int type) {
  switch (type) {
    case 0: // Check In
      return AttendanceTypeMeta(
        titleKey: 'check_in_successful',
        icon: Icons.check_circle,
        color: AppColors.cardGreen,
      );
    case 1: // Check Out
      return AttendanceTypeMeta(
        titleKey: 'check_out_successful',
        icon: Icons.exit_to_app,
        color: AppColors.cardBlue,
      );
    case 2: // On Call
      return AttendanceTypeMeta(
        titleKey: 'on_call_successful',
        icon: Icons.emoji_events,
        color: AppColors.warning,
      );
    case 4: // Break
      return AttendanceTypeMeta(
        titleKey: 'break_successful',
        icon: Icons.coffee,
        color: AppColors.cardOrange,
      );
    case 5: // Duty
      return AttendanceTypeMeta(
        titleKey: 'duty_successful',
        icon: Icons.verified_user,
        color: AppColors.info,
      );
    case 7: // Remote Work In
      return AttendanceTypeMeta(
        titleKey: 'remote_work_in_successful',
        icon: Icons.home_work,
        color: AppColors.success,
      );
    case 8: // Remote Work Out
      return AttendanceTypeMeta(
        titleKey: 'remote_work_out_successful',
        icon: Icons.home,
        color: AppColors.primary,
      );
    default:
      return AttendanceTypeMeta(
        titleKey: 'attendance_successful',
        icon: Icons.check_circle_outline,
        color: AppColors.cardPurple,
      );
  }
}

extension GenderExtension on Gender {
  int get value {
    switch (this) {
      case Gender.male:
        return 1;
      case Gender.female:
        return 2;
    }
  }

  String get displayName {
    switch (this) {
      case Gender.male:
        return "Male";
      case Gender.female:
        return "Female";
    }
  }
}

extension AttendanceRecordTypeExtension on AttendanceRecordType {
  int get value {
    switch (this) {
      case AttendanceRecordType.checkIn:
        return 0;
      case AttendanceRecordType.checkOut:
        return 1;
      case AttendanceRecordType.onCall:
        return 2;
      case AttendanceRecordType.onBreak:
        return 4;
      case AttendanceRecordType.duty:
        return 5;
      case AttendanceRecordType.remoteWorkIn:
        return 7;
      case AttendanceRecordType.remoteWorkOut:
        return 8;
    }
  }

  String get displayName {
    switch (this) {
      case AttendanceRecordType.checkIn:
        return "Check In";
      case AttendanceRecordType.checkOut:
        return "Check Out";
      case AttendanceRecordType.onCall:
        return "On Call";
      case AttendanceRecordType.onBreak:
        return "Break";
      case AttendanceRecordType.duty:
        return "Duty";
      case AttendanceRecordType.remoteWorkIn:
        return "Remote Work In";
      case AttendanceRecordType.remoteWorkOut:
        return "Remote Work Out";
    }
  }
}

extension MaritalStatusExtension on MaritalStatus {
  int get value {
    switch (this) {
      case MaritalStatus.single:
        return 1;
      case MaritalStatus.married:
        return 2;
      case MaritalStatus.divorced:
        return 3;
      case MaritalStatus.widow:
        return 4;
    }
  }

  String get displayName {
    switch (this) {
      case MaritalStatus.single:
        return "Single";
      case MaritalStatus.married:
        return "Married";
      case MaritalStatus.divorced:
        return "Divorced";
      case MaritalStatus.widow:
        return "Widow";
    }
  }
}

extension NationalityTypeExtension on NationalityType {
  int get value {
    switch (this) {
      case NationalityType.iraqi:
        return 1;
      case NationalityType.arab:
        return 2;
      case NationalityType.foreigner:
        return 3;
    }
  }

  String get displayName {
    switch (this) {
      case NationalityType.iraqi:
        return "عراقي";
      case NationalityType.arab:
        return "عربي";
      case NationalityType.foreigner:
        return "اجنبي";
    }
  }
}

extension AffiliateRequestStatusEnumExt on AffiliateRequestStatusEnum {
  static AffiliateRequestStatusEnum fromInt(int? value) {
    switch (value) {
      case 1:
        return AffiliateRequestStatusEnum.pending;
      case 2:
        return AffiliateRequestStatusEnum.inProgress;
      case 3:
        return AffiliateRequestStatusEnum.approved;
      case 4:
        return AffiliateRequestStatusEnum.rejected;
      default:
        return AffiliateRequestStatusEnum.pending;
    }
  }

  String get label {
    switch (this) {
      case AffiliateRequestStatusEnum.pending:
        return "قيد الانتظار";
      case AffiliateRequestStatusEnum.inProgress:
        return "قيد المعالجة";
      case AffiliateRequestStatusEnum.approved:
        return "تمت الموافقة";
      case AffiliateRequestStatusEnum.rejected:
        return "مرفوض";
    }
  }

  Color get color {
    switch (this) {
      case AffiliateRequestStatusEnum.pending:
        return AppColors.neutral400;
      case AffiliateRequestStatusEnum.inProgress:
        return AppColors.primary;
      case AffiliateRequestStatusEnum.approved:
        return AppColors.success;
      case AffiliateRequestStatusEnum.rejected:
        return AppColors.danger;
    }
  }
}
