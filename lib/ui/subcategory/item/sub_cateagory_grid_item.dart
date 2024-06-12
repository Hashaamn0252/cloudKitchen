import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/colors.dart';
import 'package:flutterrestaurant/viewobject/sub_category.dart';

class SubCategoryGridItem extends StatelessWidget {
  SubCategoryGridItem(
      {Key? key,
      required this.subCategory,
      this.onTap,
      this.animationController,
      this.animation})
      : super(key: key);

  final SubCategory subCategory;
  final Function? onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;
  var width, height;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    animationController!.forward();
    return AnimatedBuilder(
        animation: animationController!,
        child: InkWell(
            onTap: onTap as void Function()?,
            child: Card(
                color: purpleColor,
                elevation: 0.3,
                child: Container(
                  color: purpleColor,
                  child: Row(
                    children: [
                      // ClipRRect(
                      //     borderRadius: BorderRadius.circular(4),
                      //     child: Stack(
                      //       children: <Widget>[
                      //         PsNetworkImage(
                      //           photoKey: '',
                      //           defaultPhoto: subCategory.defaultPhoto!,
                      //           width: PsDimens.space200,
                      //           height: PsDimens.space200,
                      //           boxfit: BoxFit.cover,
                      //         ),
                      //       ],
                      //     )),
                      Container(
                        margin: EdgeInsets.all(width * .02),
                        width: width * .38,
                        height: height * .23,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width * .03),
                          image: subCategory == null
                              ? DecorationImage(
                                  image: AssetImage("myImages/homeImage.jpeg"),
                                  fit: BoxFit.fill)
                              : DecorationImage(
                                  image: NetworkImage(
                                      "${PsConfig.ps_app_image_url}${subCategory.defaultPhoto!.imgPath}"),
                                  fit: BoxFit.fill),
                        ),
                      ),
                      SizedBox(
                        width: width * .06,
                      ),
                      Flexible(
                        child: Text(
                          subCategory.name!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: PsColors.white,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ))),
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
            opacity: animation!,
            child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 100 * (1.0 - animation!.value), 0.0),
                child: child),
          );
        });
  }
}
