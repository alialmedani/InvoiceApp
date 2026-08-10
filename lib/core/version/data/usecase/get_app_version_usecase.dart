import '../../../../../core/params/base_params.dart';
import '../../../../../core/results/result.dart';
import '../../../../../core/usecase/usecase.dart';
import '../model/app_version_model.dart';
import '../repository/version_repository.dart';

class GetAppVersionParams extends BaseParams {
  final String appName;

  GetAppVersionParams({required this.appName});

  Map<String, dynamic> toJson() {
    return {'appName': appName};
  }
}

class GetAppVersionUsecase
    extends UseCase<AppVersionModel, GetAppVersionParams> {
  final VersionRepository repository;

  GetAppVersionUsecase(this.repository);

  @override
  Future<Result<AppVersionModel>> call({required GetAppVersionParams params}) {
    return repository.getAppVersionRequest(params: params);
  }
}
