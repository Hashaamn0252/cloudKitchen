import 'package:flutter/material.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/history/history_provider.dart';
import 'package:flutterrestaurant/repository/history_repsitory.dart';
import 'package:flutterrestaurant/ui/common/ps_admob_banner_widget.dart';
import 'package:flutterrestaurant/ui/history/item/history_list_item.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/product.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key, required this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  _HistoryListViewState createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView>
    with SingleTickerProviderStateMixin {
  HistoryRepository? historyRepo;
  dynamic data;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }


  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;


  @override
  Widget build(BuildContext context) {
    // data = EasyLocalizationProvider.of(context).data;
    historyRepo = Provider.of<HistoryRepository>(context);
    return ChangeNotifierProvider<HistoryProvider>(
        lazy: false,
        create: (BuildContext context) {
          final HistoryProvider provider = HistoryProvider(
            repo: historyRepo!,
          );
          provider.loadHistoryList();
          return provider;
        },
        child: Consumer<HistoryProvider>(
          builder:
              (BuildContext context, HistoryProvider provider, Widget? child) {
            if (
              //provider.historyList != null &&
                provider.historyList.data != null) {
              return Column(
                children: <Widget>[
                  const PsAdMobBannerWidget(
                    admobSize: AdSize.banner
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: PsDimens.space10),
                      child: RefreshIndicator(
                        child: CustomScrollView(
                            controller: _scrollController,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: <Widget>[
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    final int count =
                                        provider.historyList.data!.length;
                                    return HistoryListItem(
                                      animationController:
                                          widget.animationController,
                                      animation:
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(
                                        CurvedAnimation(
                                          parent: widget.animationController,
                                          curve: Interval(
                                              (1 / count) * index, 1.0,
                                              curve: Curves.fastOutSlowIn),
                                        ),
                                      ),
                                      history: provider
                                          .historyList.data!.reversed
                                          .toList()[index],
                                      onTap: () {
                                        final Product product = provider
                                            .historyList.data!.reversed
                                            .toList()[index];
                                        final ProductDetailIntentHolder holder =
                                            ProductDetailIntentHolder(
                                          productId: product.id,
                                          heroTagImage:
                                              provider.hashCode.toString() +
                                                  product.id! +
                                                  PsConst.HERO_TAG__IMAGE,
                                          heroTagTitle:
                                              provider.hashCode.toString() +
                                                  product.id! +
                                                  PsConst.HERO_TAG__TITLE,
                                          heroTagOriginalPrice: provider
                                                  .hashCode
                                                  .toString() +
                                              product.id! +
                                              PsConst.HERO_TAG__ORIGINAL_PRICE,
                                          heroTagUnitPrice:
                                              provider.hashCode.toString() +
                                                  product.id! +
                                                  PsConst.HERO_TAG__UNIT_PRICE,
                                        );

                                        Navigator.pushNamed(
                                            context, RoutePaths.productDetail,
                                            arguments: holder);
                                      },
                                    );
                                  },
                                  childCount: provider.historyList.data!.length,
                                ),
                              )
                            ]),
                        onRefresh: () {
                          return provider.resetHistoryList();
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          },
        ));
  }
}
