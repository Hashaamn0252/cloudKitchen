import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/viewobject/search_history.dart';

class SearchHistoryListItem extends StatelessWidget {
  const SearchHistoryListItem({
    Key? key,
    required this.searchHistory,
    this.onTap,
    this.onDeleteTap
  }) : super(key: key);

  final SearchHistory searchHistory;
  final Function? onTap;
  final Function? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap as void Function()?,
        child: Container(
            width: PsDimens.space140,
            padding: const EdgeInsets.only(
              left: PsDimens.space4,
              right: PsDimens.space4,
              top: PsDimens.space8),
            child: MaterialButton(
                color: PsColors.baseColor,
                height: 28,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: PsColors.mainDividerColor),
                    borderRadius:
                        const BorderRadius.all(Radius.circular(15.0))),
                  child: Align(
                   alignment: Alignment.center,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              searchHistory.searchTeam!,
                              textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(color: PsColors.iconColor),
                              ),
                            ),
                            InkWell(
                              child: Icon(
                                  Icons.clear,
                                  color: PsColors.iconColor,
                                  size: 16, 
                                  ),
                                onTap: onDeleteTap as void Function()?, 
                            ),
                          ]),
                       ),
                    onPressed: onTap as void Function()?),
              ),
    );
  }
}
