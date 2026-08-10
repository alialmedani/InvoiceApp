part of 'version_cubit.dart';

@immutable
abstract class VersionState {}

class VersionInitial extends VersionState {}

class VersionLoading extends VersionState {}

class VersionSuccess extends VersionState {}

class VersionError extends VersionState {
  final String message;
  VersionError(this.message);
}
