import 'dart:async';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/provider/common/ps_provider.dart';
import 'package:flutterrestaurant/repository/coupon_discount_repository.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/coupon_discount.dart';

import '../../viewobject/common/ps_value_holder.dart';

class CouponDiscountProvider extends PsProvider {
  CouponDiscountProvider(
      {required CouponDiscountRepository repo,required this.psValueHolder, int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    print('CouponDiscount Provider: $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });
  }

  CouponDiscountRepository? _repo;
  PsValueHolder psValueHolder;
  String couponDiscount = '0.0';

  PsResource<CouponDiscount> _couponDiscount =
      PsResource<CouponDiscount>(PsStatus.NOACTION, '', null);
  PsResource<CouponDiscount> get user => _couponDiscount;
  @override
  void dispose() {
    isDispose = true;
    print('CouponDiscount Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> postCouponDiscount(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _couponDiscount = await _repo!.postCouponDiscount(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _couponDiscount;
  }
}
