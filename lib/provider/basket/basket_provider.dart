import 'dart:async';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/provider/common/ps_provider.dart';
import 'package:flutterrestaurant/repository/basket_repository.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';

import 'helper/checkout_calculation_helper.dart';

class BasketProvider extends PsProvider {
  BasketProvider(
      {required BasketRepository repo, this.psValueHolder, int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    print('Basket Provider: $hashCode');
    basketListStream = StreamController<PsResource<List<Basket>>>.broadcast();
    subscription =
        basketListStream.stream.listen((PsResource<List<Basket>> resource) {
      updateOffset(resource.data!.length);

      _basketList = resource;

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }
late  StreamController<PsResource<List<Basket>>> basketListStream;
  BasketRepository? _repo;
  PsValueHolder? psValueHolder;
  dynamic daoSubscription;

  PsResource<List<Basket>> _basketList =
      PsResource<List<Basket>>(PsStatus.NOACTION, '', <Basket>[]);

  PsResource<List<Basket>> get basketList => _basketList;
 late StreamSubscription<PsResource<List<Basket>>> subscription;

  final CheckoutCalculationHelper checkoutCalculationHelper =
      CheckoutCalculationHelper();

  @override
  void dispose() {
    subscription.cancel();
    if (daoSubscription != null) {
      daoSubscription.cancel();
    }
    isDispose = true;
    print('Basket Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> loadBasketList() async {
    isLoading = true;
    daoSubscription = await _repo!.getAllBasketList(
        basketListStream, PsStatus.PROGRESS_LOADING);
  }

  Future<dynamic> addBasket(Basket basket) async {
    isLoading = true;
    await _repo!.addAllBasket(
      basketListStream,
      PsStatus.PROGRESS_LOADING,
      basket,
    );
  }

  Future<dynamic> updateBasket(Basket product) async {
    isLoading = true;
    await _repo!.updateBasket(
      basketListStream,
      product,
    );
  }

  Future<dynamic> deleteBasketByProduct(Basket product) async {
    isLoading = true;
    await _repo!.deleteBasketByProduct(basketListStream, product);
  }

  Future<dynamic> deleteWholeBasketList() async {
    isLoading = true;
    await _repo!.deleteWholeBasketList(basketListStream);
  }

  Future<void> resetBasketList() async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;

    updateOffset(0);

    _repo!.getAllBasketList(
      basketListStream,
      PsStatus.PROGRESS_LOADING,
    );

    isLoading = false;
  }
}
