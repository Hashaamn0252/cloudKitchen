import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';

class PsTextFieldWidget extends StatelessWidget {
  const PsTextFieldWidget(
      {this.textEditingController,
      this.titleText = '',
      this.hintText,
      this.textAboutMe = false,
      this.height = PsDimens.space44,
      this.showTitle = true,
      this.keyboardType = TextInputType.text,
      this.phoneInputType = false,
      this.isMandatory = false});

  final TextEditingController? textEditingController;
  final String titleText;
  final String? hintText;
  final double height;
  final bool textAboutMe;
  final TextInputType keyboardType;
  final bool showTitle;
  final bool phoneInputType;
  final bool isMandatory;

  @override
  Widget build(BuildContext context) {
    final Widget _productTextWidget =
        Text(titleText, style: Theme.of(context).textTheme.bodyLarge);

    return Column(
      children: <Widget>[
        if (showTitle)
          Container(
            margin: const EdgeInsets.only(
                left: PsDimens.space12,
                top: PsDimens.space12,
                right: PsDimens.space12),
            child: Row(
              children: <Widget>[
                if (isMandatory)
                  Row(
                    children: <Widget>[
                      Text(titleText,
                          style: Theme.of(context).textTheme.bodyLarge),
                      Text(' *',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: PsColors.mainColor))
                    ],
                  )
                else
                  _productTextWidget
              ],
            ),
          )
        else
          Container(
            height: 0,
          ),
        Container(
            width: double.infinity,
            height: height,
            margin: const EdgeInsets.all(PsDimens.space12),
            decoration: BoxDecoration(
              color: PsColors.backgroundColor,
              borderRadius: BorderRadius.circular(PsDimens.space4),
              border: Border.all(color: PsColors.mainDividerColor),
            ),
            child: TextField(
                keyboardType:
                    phoneInputType ? TextInputType.phone : TextInputType.text,
                maxLines: null,
                controller: textEditingController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: textAboutMe
                    ? InputDecoration(
                        contentPadding: const EdgeInsets.only(
                          left: PsDimens.space12,
                          bottom: PsDimens.space8,
                          top: PsDimens.space10,
                        ),
                        border: InputBorder.none,
                        hintText: hintText,
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: PsColors.textPrimaryLightColor),
                      )
                    : InputDecoration(
                        contentPadding: const EdgeInsets.only(
                          left: PsDimens.space12,
                          bottom: PsDimens.space8,
                        ),
                        border: InputBorder.none,
                        hintText: hintText,
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: PsColors.textPrimaryLightColor),
                      ))),
      ],
    );
  }
}
