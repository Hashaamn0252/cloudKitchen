import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/basket/basket_provider.dart';
import 'package:flutterrestaurant/provider/transaction/transaction_header_provider.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/ui/common/base/ps_widget_with_appbar_with_no_provider.dart';
import 'package:flutterrestaurant/ui/common/dialog/error_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_button_widget.dart';
import 'package:flutterrestaurant/utils/ps_progress_dialog.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/checkout_status_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/transaction_header.dart';
import 'package:provider/provider.dart';
import 'package:theme_manager/theme_manager.dart';

import '../../config/ps_config.dart';

class PayStackView extends StatefulWidget {
  const PayStackView(
      {Key? key,
      required this.basketList,
      required this.couponDiscount,
      required this.psValueHolder,
      required this.transactionSubmitProvider,
      required this.userLoginProvider,
      required this.basketProvider,
      required this.memoText,
      required this.paystackKey,
      required this.isClickPickUpButton,
      required this.deliveryPickUpDate,
      required this.deliveryPickUpTime})
      : super(key: key);

  final List<Basket> basketList;
  final String couponDiscount;
  final PsValueHolder psValueHolder;
  final TransactionHeaderProvider transactionSubmitProvider;
  final UserProvider userLoginProvider;
  final BasketProvider basketProvider;
  final String memoText;
  final String paystackKey;
  final bool isClickPickUpButton;
  final String deliveryPickUpDate;
  final String deliveryPickUpTime;

  @override
  State<StatefulWidget> createState() {
    return PayStackViewState();
  }
}

dynamic callTransactionSubmitApi(
  BuildContext context,
  BasketProvider basketProvider,
  UserProvider userLoginProvider,
  TransactionHeaderProvider transactionSubmitProvider,
  List<Basket> basketList,
  String token,
  String couponDiscount,
  String memoText,
  bool isClickPickUpButton,
  String deliveryPickUpDate,
  String deliveryPickUpTime,
) async {
  if (await Utils.checkInternetConnectivity()) {
    if (userLoginProvider.user.data != null) {
      final PsValueHolder valueHolder =
          Provider.of<PsValueHolder>(context, listen: false);
      final PsResource<TransactionHeader> _apiStatus =
          await transactionSubmitProvider.postTransactionSubmit(
              userLoginProvider.user.data!,
              basketList,
              Platform.isIOS ? token : token,
              couponDiscount.toString(),
              basketProvider.checkoutCalculationHelper.tax.toString(),
              basketProvider.checkoutCalculationHelper.totalDiscount.toString(),
              basketProvider.checkoutCalculationHelper.subTotalPrice.toString(),
              basketProvider.checkoutCalculationHelper.shippingCost.toString(),
              basketProvider.checkoutCalculationHelper.totalPrice.toString(),
              basketProvider.checkoutCalculationHelper.totalOriginalPrice
                  .toString(),
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ONE,
              '',
              '',
              PsConst.ONE,
              isClickPickUpButton == true ? PsConst.ONE : PsConst.ZERO,
              deliveryPickUpDate,
              deliveryPickUpTime,
              basketProvider.checkoutCalculationHelper.shippingCost.toString(),
              userLoginProvider.user.data!.area!.areaName!,
              memoText,
              valueHolder);

      PsProgressDialog.dismissDialog();

      if (_apiStatus.data != null) {
        await basketProvider.deleteWholeBasketList();

        await Navigator.pushNamed(context, RoutePaths.checkoutSuccess,
            arguments: CheckoutStatusIntentHolder(
              transactionHeader: _apiStatus.data!,
            ));
        //Navigator.pop(context, true);
      } else {
        PsProgressDialog.dismissDialog();

        return showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: _apiStatus.message,
              );
            });
      }
    }
  } else {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, 'error_dialog__no_internet'),
          );
        });
  }
}

// PaymentCard callCard(
//   String cardNumber,
//   String expiryDate,
//   String cardHolderName,
//   String cvvCode,
// ) {
//   final List<String> monthAndYear = expiryDate.split('/');
//   return PaymentCard(
//       number: cardNumber,
//       expiryMonth: int.parse(monthAndYear[0]),
//       expiryYear: int.parse(monthAndYear[1]),
//       name: cardHolderName,
//       cvc: cvvCode);
// }

class PayStackViewState extends State<PayStackView> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  FocusNode cvvFocusNode = FocusNode();
  var plugin;
  // = PaystackPlugin();

  @override
  void initState() {
    plugin.initialize(publicKey: widget.paystackKey);
    super.initState();
  }

  void setError(dynamic error) {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, error.toString()),
          );
        });
  }

  dynamic callWarningDialog(BuildContext context, String text) {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return WarningDialog(
            message: Utils.getString(context, text),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    dynamic payStackNow(String token) async {
      widget.basketProvider.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: widget.couponDiscount,
          psValueHolder: widget.psValueHolder,
          shippingPriceStringFormatting:
              widget.userLoginProvider.user.data!.area!.price!);

      await PsProgressDialog.showDialog(context);
      callTransactionSubmitApi(
          context,
          widget.basketProvider,
          widget.userLoginProvider,
          widget.transactionSubmitProvider,
          widget.basketList,
          token,
          widget.couponDiscount,
          widget.memoText,
          widget.isClickPickUpButton,
          widget.deliveryPickUpDate,
          widget.deliveryPickUpTime);
    }

    return PsWidgetWithAppBarWithNoProvider(
      appBarTitle: Utils.getString(context, 'checkout3__paystack'),
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              children: <Widget>[
                CreditCardWidget(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                  height: 175,
                  width: MediaQuery.of(context).size.width,
                  animationDuration: PsConfig.animation_duration,
                  onCreditCardWidgetChange: (dynamic data) {},
                ),
                const SizedBox(
                  height: 40,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: TextFormField(
                        decoration:
                            const InputDecoration(hintText: 'Card Number'),
                        maxLength: 19,
                        onChanged: (String value) {
                          setState(() {
                            cardNumber = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: TextFormField(
                        decoration:
                            const InputDecoration(hintText: 'Card Expiry'),
                        maxLength: 5,
                        onChanged: (String value) {
                          setState(() {
                            expiryDate = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: TextFormField(
                        decoration:
                            const InputDecoration(hintText: 'Card Holder Name'),
                        onChanged: (String value) {
                          setState(() {
                            cardHolderName = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 25),
                      child: TextFormField(
                        decoration: const InputDecoration(hintText: 'CVV'),
                        maxLength: 3,
                        onChanged: (String value) {
                          setState(() {
                            cvvCode = value;
                          });
                        },
                        focusNode: cvvFocusNode,
                      ),
                    ),
                  ],
                ),
                Container(
                    margin: const EdgeInsets.only(
                        left: PsDimens.space12, right: PsDimens.space12),
                    child: PSButtonWidget(
                        hasShadow: true,
                        width: double.infinity,
                        titleText: Utils.getString(context, 'credit_card__pay'),
                        onPressed: () async {
                          if (cardNumber.isEmpty) {
                            callWarningDialog(
                                context,
                                Utils.getString(
                                    context, 'warning_dialog__input_number'));
                          } else if (expiryDate.isEmpty) {
                            callWarningDialog(
                                context,
                                Utils.getString(
                                    context, 'warning_dialog__input_date'));
                          } else if (cardHolderName.isEmpty) {
                            callWarningDialog(
                                context,
                                Utils.getString(context,
                                    'warning_dialog__input_holder_name'));
                          } else if (cvvCode.isEmpty) {
                            callWarningDialog(
                                context,
                                Utils.getString(
                                    context, 'warning_dialog__input_cvv'));
                          } else {
                            bool isLight = Utils.isLightMode(context);

                            // if (!isLight) {
                            //   await ThemeManager.of(context)
                            //       .setBrightnessPreference(
                            //           BrightnessPreference.light);
                            // }
                            // final Charge charge = Charge()
                            //   ..amount = (double.parse(Utils.getPriceTwoDecimal(
                            //               widget
                            //                   .basketProvider
                            //                   .checkoutCalculationHelper
                            //                   .totalPrice
                            //                   .toString())) *
                            //           100)
                            //       .round()
                            //   ..email =
                            //       widget.userLoginProvider.user.data!.userEmail
                            //   ..reference = _getReference()
                            //   ..card = callCard(cardNumber, expiryDate,
                            //       cardHolderName, cvvCode);
                            // try {
                            //   final CheckoutResponse response =
                            //       await plugin.checkout(
                            //     context,
                            //     method: CheckoutMethod.card,
                            //     charge: charge,
                            //     fullscreen: false,
                            //     // logo: MyLogo(),
                            //   );
                            //   if (!isLight) {
                            //     await ThemeManager.of(context)
                            //         .setBrightnessPreference(
                            //             BrightnessPreference.dark);
                            //     isLight = true;
                            //   }
                            //   if (response.status) {
                            //     payStackNow(response.reference!);
                            //   }
                            // } catch (e) {
                            //   print('Check console for error');
                            //   rethrow;
                            // }
                            // if (!isLight) {
                            //   await ThemeManager.of(context)
                            //       .setBrightnessPreference(
                            //           BrightnessPreference.dark);
                            // }
                          }
                        })),
                const SizedBox(height: PsDimens.space40)
              ],
            )),
          ),
        ],
      ),
    );
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // void onCreditCardModelChange(CreditCardModel creditCardModel) {
  //   setState(() {
  //     cardNumber = creditCardModel.cardNumber;
  //     expiryDate = creditCardModel.expiryDate;
  //     cardHolderName = creditCardModel.cardHolderName;
  //     cvvCode = creditCardModel.cvvCode;
  //     isCvvFocused = creditCardModel.isCvvFocused;
  //   });
  // }
}
