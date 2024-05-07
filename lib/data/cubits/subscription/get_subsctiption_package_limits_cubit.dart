import 'package:ebroker/data/repositories/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/subscription_package_limit.dart';

abstract class GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsInitial
    extends GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsInProgress
    extends GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsSuccess
    extends GetSubscriptionPackageLimitsState {
  final SubcriptionPackageLimit packageLimit;

  GetSubscriptionPackageLimitsSuccess(this.packageLimit);
}

class GetSubsctiptionPackageLimitsFailure
    extends GetSubscriptionPackageLimitsState {
  final String errorMessage;
  GetSubsctiptionPackageLimitsFailure(this.errorMessage);
}

class GetSubsctiptionPackageLimitsCubit
    extends Cubit<GetSubscriptionPackageLimitsState> {
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();

  GetSubsctiptionPackageLimitsCubit()
      : super(GetSubscriptionPackageLimitsInitial());

  Future<void> getLimits(SubscriptionLimitType type) async {
    try {
      emit(GetSubscriptionPackageLimitsInProgress());
      SubcriptionPackageLimit subscriptionPackageLimit =
          await _subscriptionRepository.getPackageLimit(type);
      emit(GetSubscriptionPackageLimitsSuccess(subscriptionPackageLimit));
    } catch (error) {
      emit(GetSubsctiptionPackageLimitsFailure(error.toString()));
    }
  }
}
