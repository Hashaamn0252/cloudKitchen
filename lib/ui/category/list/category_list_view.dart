import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/category/category_provider.dart';
import 'package:flutterrestaurant/repository/category_repository.dart';
import 'package:flutterrestaurant/ui/category/item/category_vertical_list_item.dart';
import 'package:flutterrestaurant/ui/common/ps_admob_banner_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/category_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/product_list_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/product_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/touch_count_parameter_holder.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class CategoryListView extends StatefulWidget {
  @override
  _CategoryListViewState createState() {
    return _CategoryListViewState();
  }
}

class _CategoryListViewState extends State<CategoryListView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  CategoryProvider? _categoryProvider;
  final CategoryParameterHolder categoryIconList = CategoryParameterHolder();

  AnimationController? animationController;
  Animation<double> ?animation;

  @override
  void dispose() {
    animationController!.dispose();
    animation = null;
    super.dispose();
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _categoryProvider!.nextCategoryList(categoryIconList.toMap());
      }
    });

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    super.initState();
  }

  CategoryRepository? repo1;
  PsValueHolder? psValueHolder;
  dynamic data;

  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;


  @override
  Widget build(BuildContext context) {
 
    Future<bool> _requestPop() {
      animationController!.reverse().then<dynamic>(
        (void data) {
          if (!mounted) {
            return Future<bool>.value(false);
          }
          Navigator.pop(context, true);
          return Future<bool>.value(true);
        },
      );
      return Future<bool>.value(false);
    }

    repo1 = Provider.of<CategoryRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);
    print(
        '............................Build UI Again ............................');
    return WillPopScope(
        onWillPop: _requestPop,
        child: ChangeNotifierProvider<CategoryProvider>(
            lazy: false,
            create: (BuildContext context) {
              final CategoryProvider provider =
                  CategoryProvider(repo: repo1!, psValueHolder: psValueHolder);
              provider.loadCategoryList(categoryIconList.toMap());
              _categoryProvider = provider;
              return _categoryProvider!;
            },
            child: Consumer<CategoryProvider>(builder: (BuildContext context,
                CategoryProvider provider, Widget? child) {
              return Stack(children: <Widget>[
                Column(children: <Widget>[
                  const PsAdMobBannerWidget(
                    admobSize: AdSize.banner
                  ),
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: PsDimens.space8,
                            right: PsDimens.space8,
                            top: PsDimens.space8,
                            bottom: PsDimens.space8),
                        child: RefreshIndicator(
                          child: CustomScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              slivers: <Widget>[
                                SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 200.0,
                                          childAspectRatio: 0.8),
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      if (provider.categoryList.data != null ||
                                          provider
                                              .categoryList.data!.isNotEmpty) {
                                        final int count =
                                            provider.categoryList.data!.length;
                                        return CategoryVerticalListItem(
                                          animationController:
                                              animationController,
                                          animation: Tween<double>(
                                                  begin: 0.0, end: 1.0)
                                              .animate(
                                            CurvedAnimation(
                                              parent: animationController!,
                                              curve: Interval(
                                                  (1 / count) * index, 1.0,
                                                  curve: Curves.fastOutSlowIn),
                                            ),
                                          ),
                                          category:
                                              provider.categoryList.data![index],
                                          onTap: () {
                                            if(PsConfig.isShowSubCategory){
                                                Navigator.pushNamed(
                                                  context, RoutePaths.subCategoryGrid,
                                                  arguments: provider
                                                      .categoryList
                                                      .data![index]);
                                              }else{
                                                final String loginUserId =
                                                        Utils.checkUserLoginId(
                                                            psValueHolder!);
                                                    final TouchCountParameterHolder
                                                        touchCountParameterHolder =
                                                        TouchCountParameterHolder(
                                                            typeId: provider
                                                                .categoryList
                                                                .data![index]
                                                                .id!,
                                                            typeName: PsConst
                                                                .FILTERING_TYPE_NAME_CATEGORY,
                                                            userId: loginUserId,
                                                            );

                                                    provider.postTouchCount(
                                                        touchCountParameterHolder
                                                            .toMap());
                                                            
                                          
                                            final ProductParameterHolder
                                                productParameterHolder =
                                                ProductParameterHolder()
                                                    .getLatestParameterHolder();
                                            productParameterHolder.catId =
                                                provider.categoryList
                                                    .data![index].id;
                                            Navigator.pushNamed(context,
                                                RoutePaths.filterProductList,
                                                arguments:
                                                    ProductListIntentHolder(
                                                  appBarTitle: provider
                                                      .categoryList
                                                      .data![index]
                                                      .name!,
                                                  productParameterHolder:
                                                      productParameterHolder,
                                                ));
                                              }
                                          },
                                        );
                                      } else {
                                        return null;
                                      }
                                    },
                                    childCount:
                                        provider.categoryList.data!.length,
                                  ),
                                ),
                              ]),
                          onRefresh: () {
                            return provider
                                .resetCategoryList(categoryIconList.toMap());
                          },
                        )),
                  ),
                ]),
                PSProgressIndicator(provider.categoryList.status)
              ]);
            })));
  }
}
