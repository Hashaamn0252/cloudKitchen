import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/ui/common/ps_hero.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/colors.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/product.dart';

class ProductVeticalListItem extends StatelessWidget {
  ProductVeticalListItem(
      {Key? key,
      required this.product,
      required this.valueHolder,
      this.onTap,
      this.onButtonTap,
      this.animationController,
      this.animation,
      this.coreTagKey})
      : super(key: key);

  final Product product;
  final Function? onTap;
  final Function? onButtonTap;
  final String? coreTagKey;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final PsValueHolder valueHolder;
  var width, height;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    animationController!.forward();
    return AnimatedBuilder(
        animation: animationController!,
        child: GestureDetector(
            onTap: onTap as void Function()?,
            child: GridTile(
              child: Container(
                // margin:
                decoration: BoxDecoration(
                  color: purpleColor,
                  // PsColors.backgroundColor,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(PsDimens.space8)),
                ),
                width: width,
                child: Column(
                  // mainAxisSize: MainAxisSize.max,
                  // mainAxisAlignment: MainAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Expanded(
                    //   child: Container(
                    //     decoration: const BoxDecoration(
                    //       borderRadius: BorderRadius.all(
                    //           Radius.circular(PsDimens.space8)),
                    //     ),
                    //     child: ClipPath(

                    //       child: PsNetworkImage(
                    //         photoKey: '$coreTagKey${PsConst.HERO_TAG__IMAGE}',
                    //         defaultPhoto: product.defaultPhoto!,
                    //         width: PsDimens.space180,
                    //         height: PsDimens.space160,
                    //         boxfit: BoxFit.cover,
                    // onTap: () {
                    //   Utils.psPrint(product.defaultPhoto!.imgParentId!);
                    //   onTap!();
                    // },
                    //       ),
                    //       clipper: const ShapeBorderClipper(
                    //           shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.only(
                    //                   topLeft: Radius.circular(PsDimens.space8),
                    //                   topRight:
                    //                       Radius.circular(PsDimens.space8)))),
                    //     ),
                    //   ),
                    // ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Utils.psPrint(product.defaultPhoto!.imgParentId!);
                            onTap!();
                          },
                          child: Container(
                            margin: EdgeInsets.all(width * .02),
                            width: width * .3,
                            height: height * .15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width * .03),
                              image: product == null
                                  ? DecorationImage(
                                      image:
                                          AssetImage("myImages/homeImage.jpeg"),
                                      fit: BoxFit.fill)
                                  : DecorationImage(
                                      image: NetworkImage(
                                          "${PsConfig.ps_app_image_url}${product.defaultPhoto!.imgPath}"),
                                      fit: BoxFit.fill),
                            ),
                          ),
                        ),
                        Container(
                            // margin: EdgeInsets.only(left: width * .03),
                            width: width * .58,
                            // height: height * .2,
                            padding: EdgeInsets.all(width * .02),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        product.name!,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(color: PsColors.white),
                                        maxLines: 1,
                                      ),
                                    ),
                                    IconButton(
                                        iconSize: PsDimens.space32,
                                        icon: Icon(Icons.add_circle,
                                            color: PsColors.white),
                                        onPressed: () {
                                          onButtonTap!();
                                        })
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                        '${product.currencySymbol}${Utils.getPriceFormat(product.unitPrice!, valueHolder)}',
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              color: PsColors.mainColor,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1),
                                    if (product.isDiscount == PsConst.ONE)
                                      Expanded(
                                        child: Text(
                                            '  ${product.discountPercent}% ' +
                                                Utils.getString(context,
                                                    'product_detail__discount_off'),
                                            textAlign: TextAlign.start,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: PsColors.mainColor),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1),
                                      )
                                    else
                                      Container()
                                  ],
                                ),
                              ],
                            ))
                      ],
                    ),
                  ],
                ),
              ),
            )),
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
              opacity: animation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 100 * (1.0 - animation!.value), 0.0),
                child: child,
              ));
        });
  }
}
