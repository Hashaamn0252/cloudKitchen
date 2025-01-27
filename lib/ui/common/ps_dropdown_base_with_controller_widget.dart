import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/utils/utils.dart';

class PsDropdownBaseWithControllerWidget extends StatelessWidget {
  const PsDropdownBaseWithControllerWidget(
      {Key? key,
      required this.title,
      required this.onTap,
      this.textEditingController,
      this.isMandatory = false})
      : super(key: key);

  final String title;
  final TextEditingController? textEditingController;
  final Function onTap;
  final bool isMandatory;

  @override
  Widget build(BuildContext context) {
    final Widget _productTextWidget =
        Text(title, style: Theme.of(context).textTheme.bodyLarge);
    final Widget _productTextWithStarWidget = Row(
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.bodyLarge),
        Text(' *',
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: PsColors.mainColor))
      ],
    );

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(
              left: PsDimens.space12,
              top: PsDimens.space4,
              right: PsDimens.space12),
          child: Row(
            children: <Widget>[
              if (isMandatory) _productTextWithStarWidget,
              if (!isMandatory) _productTextWidget,
            ],
          ),
        ),
        GestureDetector(
          onTap: onTap as void Function()?,
          child: Container(
            width: double.infinity,
            height: PsDimens.space44,
            margin: const EdgeInsets.all(PsDimens.space12),
            decoration: BoxDecoration(
              color: PsColors.backgroundColor,
              borderRadius: BorderRadius.circular(PsDimens.space4),
              border: Border.all(color: PsColors.mainDividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: TextField(
                      controller: textEditingController,
                      enabled: false,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                          left: PsDimens.space12,
                          bottom: PsDimens.space8,
                        ),
                        border: InputBorder.none,
                        hintText:
                            Utils.getString(context, 'home_search__not_set'),
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: PsColors.textPrimaryLightColor),
                      )),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
