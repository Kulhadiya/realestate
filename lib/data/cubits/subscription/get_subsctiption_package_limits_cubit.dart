import 'package:ebroker/data/Repositories/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/subscription_package_limit.dart';

abstract class GetSubsctiptionPackageLimitsState {}

class GetSubsctiptionPackageLimitsInitial
    extends GetSubsctiptionPackageLimitsState {}

class GetSubsctiptionPackageLimitsInProgress
    extends GetSubsctiptionPackageLimitsState {}

class GetSubsctiptionPackageLimitsSuccess
    extends GetSubsctiptionPackageLimitsState {
  final SubcriptionPackageLimit packageLimit;

  GetSubsctiptionPackageLimitsSuccess(this.packageLimit);
}

class GetSubsctiptionPackageLimitsFailure
    extends GetSubsctiptionPackageLimitsState {
  final String errorMessage;
  GetSubsctiptionPackageLimitsFailure(this.errorMessage);
}

class GetSubsctiptionPackageLimitsCubit
    extends Cubit<GetSubsctiptionPackageLimitsState> {
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();

  GetSubsctiptionPackageLimitsCubit()
      : super(GetSubsctiptionPackageLimitsInitial());

  Future<void> getLimits(SubscriptionLimitType type) async {
    try {
      emit(GetSubsctiptionPackageLimitsInProgress());
      SubcriptionPackageLimit subscriptionPackageLimit =
          await _subscriptionRepository.getPackageLimit(type);
      emit(GetSubsctiptionPackageLimitsSuccess(subscriptionPackageLimit));
    } catch (error) {
      emit(GetSubsctiptionPackageLimitsFailure(error.toString()));
    }
  }
}
