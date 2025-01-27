import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/common/ps_button_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/transaction_header.dart';
import 'package:provider/provider.dart';

class CheckoutStatusView extends StatefulWidget {
  const CheckoutStatusView({
    Key? key,
    required this.transactionHeader,
  }) : super(key: key);

  final TransactionHeader transactionHeader;

  @override
  _CheckoutStatusViewState createState() => _CheckoutStatusViewState();
}

class _CheckoutStatusViewState extends State<CheckoutStatusView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  UserProvider? _userProvider;
  UserRepository? repo1;
  PsValueHolder? valueHolder;
  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<UserRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);

    const Widget _dividerWidget = Divider(
      height: PsDimens.space2,
    );
    final Widget _contentCopyIconWidget = IconButton(
      iconSize: PsDimens.space20,
      icon: Icon(
        Icons.content_copy,
        color: Theme.of(context).iconTheme.color,
      ),
      onPressed: () {
        // Clipboard.setData(
        //     ClipboardData(text: widget.transactionHeader.transCode));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Tooltip(
            message: Utils.getString(context, 'transaction_detail__copy'),
            child: Text(
              Utils.getString(context, 'transaction_detail__copied_data'),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: PsColors.mainColor,
                  ),
            ),
            showDuration: const Duration(seconds: 5),
          ),
        ));
      },
    );

    final Widget _keepingButtonWidget = Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () {
          // Navigator.pop(context);
          Navigator.of(context).popUntil(ModalRoute.withName(RoutePaths.home));
        },
        child: Container(
          height: 60,
          color: PsColors.mainColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: PsDimens.space16,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  Utils.getString(context, 'checkout_status__keep_shopping'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: PsColors.white),
                ),
              ),
              const SizedBox(
                height: PsDimens.space16,
              ),
            ],
          ),
        ),
      ),
    );
    return ChangeNotifierProvider<UserProvider>(
      lazy: false,
      create: (BuildContext context) {
        final UserProvider provider =
            UserProvider(repo: repo1!, psValueHolder: valueHolder!);
        provider.getUser(provider.psValueHolder.loginUserId!);
        _userProvider = provider;
        return _userProvider!;
      },
      child: Consumer<UserProvider>(builder:
          (BuildContext context, UserProvider provider, Widget? child) {
        if (provider.user.data != null) {
          return Scaffold(
              key: scaffoldKey,
              body: Container(
                color: PsColors.coreBackgroundColor,
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                        child: Column(children: <Widget>[
                      const SizedBox(
                        height: PsDimens.space52,
                      ),
                      Text(
                        Utils.getString(
                            context, 'checkout_status__order_success'),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: PsColors.mainColor),
                      ),
                      const SizedBox(
                        height: PsDimens.space12,
                      ),
                      Text(
                        Utils.getString(context, 'checkout_status__thank') +
                            ' ' +
                            provider.user.data!.userName!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: PsDimens.space52,
                      ),
                      Image.asset('assets/images/delivery_car_img.png'),
                      const SizedBox(
                        height: PsDimens.space20,
                      ),
                      Container(
                          color: PsColors.backgroundColor,
                          margin: const EdgeInsets.only(top: PsDimens.space8),
                          padding: const EdgeInsets.only(
                            left: PsDimens.space12,
                            right: PsDimens.space12,
                          ),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(PsDimens.space8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          const SizedBox(
                                            width: PsDimens.space8,
                                          ),
                                          Icon(
                                            Icons.offline_pin,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                          ),
                                          const SizedBox(
                                            width: PsDimens.space8,
                                          ),
                                          Expanded(
                                            child: Text(
                                                '${Utils.getString(context, 'transaction_detail__trans_no')} : ${widget.transactionHeader.transCode}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _contentCopyIconWidget,
                                  ],
                                ),
                              ),
                              _dividerWidget,
                              _TransactionNoTextWidget(
                                transationInfoText:
                                    widget.transactionHeader.totalItemCount!,
                                title:
                                    '${Utils.getString(context, 'transaction_detail__total_item_count')} :',
                              ),
                              _TransactionNoTextWidget(
                                transationInfoText:
                                    '${widget.transactionHeader.currencySymbol} ${Utils.getPriceFormat(widget.transactionHeader.totalItemAmount!, valueHolder!)}',
                                title:
                                    '${Utils.getString(context, 'transaction_detail__total_item_price')} :',
                              ),
                              _TransactionNoTextWidget(
                                transationInfoText:
                                    '${widget.transactionHeader.currencySymbol} ${Utils.getPriceFormat(widget.transactionHeader.discountAmount!, valueHolder!)}',
                                title:
                                    '${Utils.getString(context, 'transaction_detail__discount')} :',
                              ),
                              _TransactionNoTextWidget(
                                transationInfoText:
                                    '${widget.transactionHeader.currencySymbol} ${Utils.getPriceFormat(widget.transactionHeader.cuponDiscountAmount!, valueHolder!)}',
                                title:
                                    '${Utils.getString(context, 'transaction_detail__coupon_discount')} :',
                              ),
                              const SizedBox(
                                height: PsDimens.space12,
                              ),
                              _dividerWidget,
                              _TransactionNoTextWidget(
                                transationInfoText:
                                    '${widget.transactionHeader.currencySymbol} ${Utils.getPriceFormat(widget.transactionHeader.subTotalAmount!, valueHolder!)}',
                                title:
                                    '${Utils.getString(context, 'transaction_detail__sub_total')} :',
                              ),
                              _TransactionNoTextWidget(
                                transationInfoText:
                                    '${widget.transactionHeader.currencySymbol} ${Utils.getPriceFormat(widget.transactionHeader.taxAmount!, valueHolder!)}',
                                title:
                                    '${Utils.getString(context, 'transaction_detail__tax')}(${provider.psValueHolder.overAllTaxLabel} %) :',
                              ),
                              _TransactionNoTextWidget(
                                transationInfoText:
                                    '${widget.transactionHeader.currencySymbol} ${Utils.getPriceFormat(widget.transactionHeader.shippingAmount!, valueHolder!)}',
                                title:
                                    '${Utils.getString(context, 'transaction_detail__shipping_cost')} :',
                              ),
                              _TransactionNoTextWidget(
                                transationInfoText:
                                    '${widget.transactionHeader.currencySymbol} ${Utils.calculateShippingTax(widget.transactionHeader.shippingAmount!, provider.psValueHolder.shippingTaxValue!, valueHolder!)}',
                                title:
                                    '${Utils.getString(context, 'transaction_detail__shipping_tax')}(${provider.psValueHolder.shippingTaxLabel} %) :',
                              ),
                              const SizedBox(
                                height: PsDimens.space12,
                              ),
                              _dividerWidget,
                              _TransactionNoTextWidget(
                                transationInfoText:
                                    '${widget.transactionHeader.currencySymbol} ${Utils.getPriceFormat(widget.transactionHeader.balanceAmount!, valueHolder!)}',
                                title:
                                    '${Utils.getString(context, 'transaction_detail__total')} :',
                              ),
                              const SizedBox(
                                height: PsDimens.space12,
                              ),
                            ],
                          )),
                      const SizedBox(
                        height: PsDimens.space16,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(PsDimens.space16),
                        child: PSButtonWidget(
                          hasShadow: true,
                          width: double.infinity,
                          titleText: Utils.getString(
                              context, 'transaction_detail__view_details'),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, RoutePaths.transactionDetail,
                                arguments: widget.transactionHeader);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: PsDimens.space100,
                      ),
                    ])),
                    _keepingButtonWidget,
                  ],
                ),
              ));
        } else {
          return Container();
        }
      }),
    );
  }
}

class _TransactionNoTextWidget extends StatelessWidget {
  const _TransactionNoTextWidget({
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
          left: PsDimens.space12,
          right: PsDimens.space12,
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
