// TODO: enable once the auth feature (LoginModel, AuthRepository,
// RefreshTokenUsecase) exists in this app.
//
// import 'package:invoice/core/results/result.dart';
// import '../../../features/auth/data/model/login_model.dart';
// import '../../../features/auth/data/repository/auth_repository.dart';
// import '../../../features/auth/data/usecase/refresh_token_usecase.dart';
// import '../../classes/cashe_helper.dart';

Future<void> checkToken() async {
  // Result<LoginModel> response = await RefreshTokenUsecase(AuthRepository())
  //     .call(
  //       params: RefreshTokenParams(
  //         grantType: "refresh_token",
  //         clientId: "JasimERP_App",
  //         refreshToken: CacheHelper.refreshtoken ?? "",
  //       ),
  //     );
  // if (response.hasDataOnly) {
  //   CacheHelper.setToken(response.data!.accessToken);
  //   CacheHelper.setRefreshToken(response.data!.refreshToken);
  //   CacheHelper.setExpiresIn(response.data!.expiresIn);
  //   CacheHelper.setDateWithExpiry(response.data!.expiresIn ?? 3600);
  // }
}
