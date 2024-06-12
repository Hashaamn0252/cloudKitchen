import 'package:flutter/material.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/basket/basket_provider.dart';
import 'package:flutterrestaurant/provider/coupon_discount/coupon_discount_provider.dart';
import 'package:flutterrestaurant/provider/delivery_cost/delivery_cost_provider.dart';
import 'package:flutterrestaurant/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/repository/basket_repository.dart';
import 'package:flutterrestaurant/repository/coupon_discount_repository.dart';
import 'package:flutterrestaurant/repository/transaction_header_repository.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/error_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/success_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_button_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_textfield_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/coupon_discount.dart';
import 'package:flutterrestaurant/viewobject/holder/coupon_discount_holder.dart';
import 'package:provider/provider.dart';

class Checkout2View extends StatefulWidget {
  const Checkout2View({
    Key? key,
    required this.basketList,
    required this.shopInfoProvider,
    required this.publishKey,
  }) : super(key: key);

  final List<Basket> basketList;
  final ShopInfoProvider shopInfoProvider;
  final String publishKey;
  @override
  _Checkout2ViewState createState() => _Checkout2ViewState();
}

class _Checkout2ViewState extends State<Checkout2View> {
  final TextEditingController couponController = TextEditingController();
  CouponDiscountRepository? couponDiscountRepo;
  TransactionHeaderRepository? transactionHeaderRepo;
  BasketRepository ?basketRepository;
  UserRepository? userRepository;
  PsValueHolder? valueHolder;
  CouponDiscountProvider? couponDiscountProvider;
  UserProvider? userProvider;
  DeliveryCostProvider? provider;
  ShopInfoProvider? shopInfoProvider;

  @override
  Widget build(BuildContext context) {
    couponDiscountRepo = Provider.of<CouponDiscountRepository>(context);
    transactionHeaderRepo = Provider.of<TransactionHeaderRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);

    valueHolder = Provider.of<PsValueHolder>(context);
    userRepository = Provider.of<UserRepository>(context);
    shopInfoProvider = Provider.of<ShopInfoProvider>(context, listen: false);

    return Consumer<UserProvider>(builder:
        (BuildContext context, UserProvider userProvider, Widget? child) {
      couponDiscountProvider = Provider.of<CouponDiscountProvider>(context,
          listen: false); // Listen : False is important.
      userProvider = Provider.of<UserProvider>(context,
          listen: false);// Listen : False is important.
      provider = Provider.of<DeliveryCostProvider>(context, listen: false); 

      final BasketProvider basketProvider =
          Provider.of<BasketProvider>(context);

      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: PsColors.backgroundColor,
              margin: const EdgeInsets.only(top: PsDimens.space8),
              padding: const EdgeInsets.only(
                left: PsDimens.space12,
                right: PsDimens.space12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: PsDimens.space16,
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: PsDimens.space16, right: PsDimens.space16),
                    child: Text(
                      Utils.getString(
                          context, 'transaction_detail__coupon_discount'),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(),
                    ),
                  ),
                  const SizedBox(
                    height: PsDimens.space16,
                  ),
                  const Divider(
                    height: 2,
                  ),
                  const SizedBox(
                    height: PsDimens.space16,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: PsTextFieldWidget(
                        hintText:
                            Utils.getString(context, 'checkout__coupon_code'),
                        textEditingController: couponController,
                        showTitle: false,
                      )),
                      Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: PsDimens.space8),
                        child: PSButtonWidget(
                          titleText: Utils.getString(
                              context, 'checkout__claim_button_name'),
                          onPressed: () async {
                            if (couponController.text.isNotEmpty) {
                              final CouponDiscountParameterHolder
                                  couponDiscountParameterHolder =
                                  CouponDiscountParameterHolder(
                                couponCode: couponController.text,
                              );

                              final PsResource<CouponDiscount> _apiStatus =
                                  await couponDiscountProvider!
                                      .postCouponDiscount(
                                          couponDiscountParameterHolder
                                              .toMap());

                              if (_apiStatus.data != null &&
                                  couponController.text ==
                                      _apiStatus.data!.couponCode) {
                                final BasketProvider basketProvider =
                                    Provider.of<BasketProvider>(context,
                                        listen: false);

                                if (shopInfoProvider!.shopInfo.data!
                                        .isArea == PsConst.ONE) {
                                  basketProvider.checkoutCalculationHelper
                                      .calculate(
                                          basketList: widget.basketList,
                                          couponDiscountString:
                                              _apiStatus.data!.couponAmount!,
                                          psValueHolder: valueHolder!,
                                          shippingPriceStringFormatting:
                                              userProvider.selectedArea!.price!);
                                } else if (shopInfoProvider!.shopInfo.data!
                                        .isArea == PsConst.ZERO && 
                                      shopInfoProvider!.shopInfo.data!
                                        .deliFeeByDistance == PsConst.ONE) {
                                  basketProvider.checkoutCalculationHelper
                                      .calculate(
                                      basketList: widget.basketList,
                                      couponDiscountString:
                                          _apiStatus.data!.couponAmount!,
                                      psValueHolder: valueHolder!,
                                      shippingPriceStringFormatting:
                                          provider!.deliveryCost.data!.totalCost!);
                                } else if (shopInfoProvider!.shopInfo.data!
                                        .isArea == PsConst.ZERO && 
                                      shopInfoProvider!.shopInfo.data!
                                        .fixedDelivery == PsConst.ONE) {
                                  basketProvider.checkoutCalculationHelper
                                      .calculate(
                                      basketList: widget.basketList,
                                      couponDiscountString:
                                          _apiStatus.data!.couponAmount!,
                                      psValueHolder: valueHolder!,
                                      shippingPriceStringFormatting:
                                          provider!.deliveryCost.data!.totalCost!);
                                } else if (shopInfoProvider!.shopInfo.data!
                                        .isArea == PsConst.ZERO && 
                                      shopInfoProvider!.shopInfo.data!
                                        .freeDelivery == PsConst.ONE) {
                                  basketProvider.checkoutCalculationHelper
                                      .calculate(
                                      basketList: widget.basketList,
                                      couponDiscountString:
                                          _apiStatus.data!.couponAmount!,
                                      psValueHolder: valueHolder!,
                                      shippingPriceStringFormatting:
                                          '0.0');
                                  }
                                showDialog<dynamic>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SuccessDialog(
                                        message: Utils.getString(context,
                                            'checkout__couponcode_add_dialog_message'),
                                      );
                                    });

                                couponController.clear();
                                print(_apiStatus.data!.couponAmount);
                                setState(() {
                                  couponDiscountProvider!.couponDiscount =
                                      _apiStatus.data!.couponAmount!;
                                });
                              } else {
                                showDialog<dynamic>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ErrorDialog(
                                        message: _apiStatus.message,
                                      );
                                    });
                              }
                            } else {
                              showDialog<dynamic>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WarningDialog(
                                      message: Utils.getString(context,
                                          'checkout__warning_dialog_message'),
                                      onPressed: () {},
                                    );
                                  });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: PsDimens.space16,
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: PsDimens.space16, right: PsDimens.space16),
                    child: Text(
                        Utils.getString(context, 'checkout__description'),
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  const SizedBox(
                    height: PsDimens.space16,
                  ),
                ],
              ),
            ),
            _OrderSummaryWidget(
              psValueHolder: valueHolder!,
              basketList: widget.basketList,
              couponDiscount: couponDiscountProvider!.couponDiscount ,
              basketProvider: basketProvider,
              userProvider: userProvider,
              shopInfoProvider: widget.shopInfoProvider,
            ),
          ],
        ),
      );
    });
  }
}

class _OrderSummaryWidget extends StatelessWidget {
  const _OrderSummaryWidget({
    Key? key,
    required this.basketList,
    required this.couponDiscount,
    required this.psValueHolder,
    required this.basketProvider,
    required this.userProvider,
    required this.shopInfoProvider,
  }) : super(key: key);

  final List<Basket> basketList;
  final String couponDiscount;
  final PsValueHolder psValueHolder;
  final BasketProvider basketProvider;
  final UserProvider userProvider;
  final ShopInfoProvider shopInfoProvider;
  @override
  Widget build(BuildContext context) {
     final DeliveryCostProvider provider = Provider.of<DeliveryCostProvider>(
            context, listen: false);
    String? currencySymbol;

    if (basketList.isNotEmpty) {
      currencySymbol = basketList[0].product!.currencySymbol!;
    }
    if (shopInfoProvider.shopInfo.data!
          .isArea == PsConst.ONE) {
       basketProvider.checkoutCalculationHelper.calculate(
        basketList: basketList,
        couponDiscountString: couponDiscount,
        psValueHolder: psValueHolder,
        shippingPriceStringFormatting: userProvider.selectedArea!.price == ''
            ? '0.0'
            : userProvider.selectedArea!.price!);
    } else if (shopInfoProvider.shopInfo.data!
          .isArea == PsConst.ZERO &&
        shopInfoProvider.shopInfo.data!
          .deliFeeByDistance == PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
        basketList: basketList,
        couponDiscountString: couponDiscount,
        psValueHolder: psValueHolder,
        shippingPriceStringFormatting: provider.deliveryCost.data!.totalCost!);
    } else if (shopInfoProvider.shopInfo.data!
          .isArea == PsConst.ZERO &&
        shopInfoProvider.shopInfo.data!
          .fixedDelivery == PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
        basketList: basketList,
        couponDiscountString: couponDiscount,
        psValueHolder: psValueHolder,
        shippingPriceStringFormatting: provider.deliveryCost.data!.totalCost!);

    } else if (shopInfoProvider.shopInfo.data!
          .isArea == PsConst.ZERO &&
        shopInfoProvider.shopInfo.data!
          .freeDelivery == PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
        basketList: basketList,
        couponDiscountString: couponDiscount,
        psValueHolder: psValueHolder,
        shippingPriceStringFormatting: '0.0');
    }

    const Widget _dividerWidget = Divider(
      height: PsDimens.space2,
    );

    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space12,
    );

    return Container(
        color: PsColors.backgroundColor,
        margin: const EdgeInsets.only(top: PsDimens.space8),
        padding: const EdgeInsets.only(
          left: PsDimens.space12,
          right: PsDimens.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                Utils.getString(context, 'checkout__order_summary'),
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _dividerWidget,
            _OrderSummeryTextWidget(
              transationInfoText: basketProvider
                  .checkoutCalculationHelper.totalItemCount
                  .toString(),
              title:
                  '${Utils.getString(context, 'checkout__total_item_count')} :',
            ),
            _OrderSummeryTextWidget(
              transationInfoText:
                  '${basketList[0].product!.currencySymbol} ${basketProvider.checkoutCalculationHelper.totalOriginalPriceFormattedString}',
              title:
                  '${Utils.getString(context, 'checkout__total_item_price')} :',
            ),
            _OrderSummeryTextWidget(
              transationInfoText:
                  '$currencySymbol ${basketProvider.checkoutCalculationHelper.totalDiscountFormattedString}',
              title: '${Utils.getString(context, 'checkout__discount')} :',
            ),
            _OrderSummeryTextWidget(
              transationInfoText: couponDiscount == '-'
                  ? '-'
                  : '$currencySymbol ${basketProvider.checkoutCalculationHelper.couponDiscountFormattedString}',
              title:
                  '${Utils.getString(context, 'checkout__coupon_discount')} :',
            ),
            _spacingWidget,
            _dividerWidget,
            _OrderSummeryTextWidget(
              transationInfoText: basketProvider
                  .checkoutCalculationHelper.subTotalPriceFormattedString
                  .toString(),
              title: '${Utils.getString(context, 'checkout__sub_total')} :',
            ),
            _OrderSummeryTextWidget(
              transationInfoText:
                  '$currencySymbol ${basketProvider.checkoutCalculationHelper.taxFormattedString}',
              title:
                  '${Utils.getString(context, 'checkout__tax')} (${psValueHolder.overAllTaxLabel} %) :',
            ),
            if (provider.deliveryCost.data == null || 
                provider.deliveryCost.data!.totalCost == '0.0' || 
                shopInfoProvider.shopInfo.data!.isArea == PsConst.ONE)
              _OrderSummeryTextWidget(
                transationInfoText:
                    '$currencySymbol ${double.parse(userProvider.selectedArea!.price! == '' ? '0.0' : userProvider.selectedArea!.price!)}',
                title: '${Utils.getString(context, 'checkout__shipping_cost')} :',
              )
            else 
              _OrderSummeryTextWidget(
                transationInfoText:
                    '$currencySymbol ${double.parse(provider.deliveryCost.data!.totalCost!)}',
                title: '${Utils.getString(context, 'checkout__shipping_cost')} :',
              ),
            _OrderSummeryTextWidget(
            transationInfoText:
                '$currencySymbol ${basketProvider.checkoutCalculationHelper.shippingTaxFormattedString}',
            title:
                '${Utils.getString(context, 'checkout__shipping_tax')} (${psValueHolder.shippingTaxLabel} %) :',
            ),
            _spacingWidget,
            _dividerWidget,
            _OrderSummeryTextWidget(
              transationInfoText:
                  '$currencySymbol ${basketProvider.checkoutCalculationHelper.totalPriceFormattedString}',
              title:
                  '${Utils.getString(context, 'transaction_detail__total')} :',
            ),
            _spacingWidget,
          ],
        ));
  }
}

class _OrderSummeryTextWidget extends StatelessWidget {
  const _OrderSummeryTextWidget({
    Key? key,
    required this.transationInfoText,
    this.title,
  }) : super(key: key);

  final String transationInfoText;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: PsDimens.space16,
          right: PsDimens.space16,
          top: PsDimens.space12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.normal),
          ),
          Text(
            transationInfoText,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.normal),
          )
        ],
      ),
    );
  }
}
