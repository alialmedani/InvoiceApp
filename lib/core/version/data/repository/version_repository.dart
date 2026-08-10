import '../../../../../core/data_source/remote_data_source.dart';
import '../../../../../core/http/http_method.dart';
import '../../../../../core/repository/core_repository.dart';
import '../../../../../core/results/result.dart';
import '../model/app_version_model.dart';
import '../usecase/get_app_version_usecase.dart';

// Define API URL
const String getAppVersionUrl =
    'https://api.updater.jasim-erp.com/api/app/app-info/by-name';

class VersionRepository extends CoreRepository {
  // GET app version - GET request
  Future<Result<AppVersionModel>> getAppVersionRequest({
    required GetAppVersionParams params,
  }) async {
    final result = await RemoteDataSource.request<AppVersionModel>(
      withAuthentication: false, 
      url: getAppVersionUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(), 
      converter: (json) => AppVersionModel.fromJson(json),
      responseStr: '',
    );

    return call(result: result);
  }
}
