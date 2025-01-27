import 'dart:async';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/db/basket_dao.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';

import 'Common/ps_repository.dart';

class BasketRepository extends PsRepository {
  BasketRepository({required BasketDao basketDao}) {
    _basketDao = basketDao;
  }

  String primaryKey = 'id';
late  BasketDao _basketDao;

  Future<dynamic> insert(Basket basket) async {
    return _basketDao.insert(primaryKey, basket);
  }

  Future<dynamic> update(Basket basket) async {
    return _basketDao.update(basket);
  }

  Future<dynamic> delete(Basket basket) async {
    return _basketDao.delete(basket);
  }

  Future<dynamic> getAllBasketList(
      StreamController<PsResource<List<Basket>>> basketListStream,
      PsStatus status) async {
    final dynamic subscription = _basketDao.getAllWithSubscription(
        status: PsStatus.SUCCESS,
        onDataUpdated: (List<Basket> productList) {
          if (status != PsStatus.NOACTION) {
            print(status);
            basketListStream.sink
                .add(PsResource<List<Basket>>(status, '', productList));
          } else {
            print('No Action');
          }
        });

    return subscription;
  }

  Future<dynamic> addAllBasket(
      StreamController<PsResource<List<Basket>>> basketListStream,
      PsStatus status,
      Basket basket) async {
    await _basketDao.insert(primaryKey, basket);
    basketListStream.sink.add(await _basketDao.getAll(status: status));
  }

  Future<dynamic> updateBasket(
      StreamController<PsResource<List<Basket>>> basketListStream,
      Basket product) async {
    await _basketDao.update(product);
    basketListStream.sink
        .add(await _basketDao.getAll(status: PsStatus.SUCCESS));
  }

  Future<dynamic> deleteBasketByProduct(
      StreamController<PsResource<List<Basket>>> basketListStream,
      Basket product) async {
    await _basketDao.delete(product);
    basketListStream.sink
        .add(await _basketDao.getAll(status: PsStatus.SUCCESS));
  }

  Future<dynamic> deleteWholeBasketList(
      StreamController<PsResource<List<Basket>>> basketListStream) async {
    await _basketDao.deleteAll();
  }
}
