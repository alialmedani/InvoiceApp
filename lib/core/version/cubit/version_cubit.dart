import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../results/result.dart';
import '../data/repository/version_repository.dart';
import '../data/usecase/get_app_version_usecase.dart';

part 'version_state.dart';

class VersionCubit extends Cubit<VersionState> {
  VersionCubit() : super(VersionInitial());

  // Get app version
  Future<Result> getAppVersion({required String appName}) async {
    return await GetAppVersionUsecase(
      VersionRepository(),
    ).call(params: GetAppVersionParams(appName: appName));
  }
}
