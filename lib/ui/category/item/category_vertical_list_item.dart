import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/viewobject/category.dart';

class CategoryVerticalListItem extends StatelessWidget {
  const CategoryVerticalListItem(
      {Key? key,
      required this.category,
      this.onTap,
      this.animationController,
      this.animation})
      : super(key: key);

  final Category category;

  final Function? onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    animationController!.forward();
    return AnimatedBuilder(
        animation: animationController!,
        child: GestureDetector(
            onTap: onTap as void Function()?,
            child: Card(
                elevation: 0.3,
                child: Container(
                    child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              child: PsNetworkImage(
                                photoKey: '',
                                defaultPhoto: category.defaultPhoto!,
                                width: PsDimens.space200,
                                height: PsDimens.space220,
                                boxfit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              width: 200,
                              height: double.infinity,
                              color: PsColors.black.withAlpha(110),
                            )
                          ],
                        )),
                    Text(
                      category.name!,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: PsColors.white, fontWeight: FontWeight.bold),
                    ),
                    Container(
                        child: Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        width: PsDimens.space40,
                        height: PsDimens.space40,
                        child: PsNetworkCircleIconImage(
                          photoKey: '',
                          defaultIcon: category.defaultIcon!,
                          boxfit: BoxFit.cover,
                          onTap: onTap!,
                        ),
                      ),
                    )),
                  ],
                )))),
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
