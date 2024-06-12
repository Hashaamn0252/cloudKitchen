import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/product/search_product_provider.dart';
import 'package:flutterrestaurant/provider/search_history/search_history_provider.dart';
import 'package:flutterrestaurant/repository/product_repository.dart';
import 'package:flutterrestaurant/repository/search_history_repository.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/ui/search_item/search_item_list_item.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/product_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/search_result_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/product.dart';
import 'package:flutterrestaurant/viewobject/search_history.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/common/ps_status.dart';
import '../../provider/basket/basket_provider.dart';
import '../../provider/product/search_result_provider.dart';
import '../../repository/basket_repository.dart';
import '../../repository/search_result_repository.dart';
import '../../viewobject/basket.dart';
import '../../viewobject/basket_selected_add_on.dart';
import '../../viewobject/basket_selected_attribute.dart';
import '../../viewobject/category.dart';
import '../../viewobject/holder/intent_holder/product_list_intent_holder.dart';
import '../../viewobject/sub_category.dart';
import '../common/dialog/choose_attribute_dialog.dart';
import '../common/dialog/warning_dialog_view.dart';
import '../common/ps_frame_loading_widget.dart';
import '../product/item/product_vertical_list_item.dart';

class SearchItemListView extends StatefulWidget {
  const SearchItemListView({
    Key? key,
    required this.productParameterHolder,
  }) : super(key: key);

  final ProductParameterHolder productParameterHolder;

  @override
  _SearchHistoryListViewState createState() => _SearchHistoryListViewState();
}

class _SearchHistoryListViewState extends State<SearchItemListView>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  // final ScrollController _scrollController = ScrollController();
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animationController);
    super.initState();
  }

  final TextEditingController inputSearchController = TextEditingController();
  PsValueHolder? psValueHolder;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  SearchHistoryProvider? searchHistoryProvider;
  SearchHistoryRepository? searchHistoryRepository;
  SearchResultRepository? searchResultRepository;
  BasketRepository? basketRepository;
  ProductRepository? repo1;
  bool isCallFirstTime = true;
  SearchHistory? searchHistory;

  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<ProductRepository>(context);
    searchHistoryRepository = Provider.of<SearchHistoryRepository>(context);
    searchResultRepository = Provider.of<SearchResultRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    Future<bool> _requestPop() {
      animationController.reverse().then<dynamic>(
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

    inputSearchController.text = widget.productParameterHolder.searchTerm!;
    print(inputSearchController);
    final Widget _searchTextFieldWidget = InkWell(
      child: Container(
        height: 40,
        width: double.infinity,
        margin: const EdgeInsets.all(PsDimens.space12),
        decoration: BoxDecoration(
          color: PsColors.mainDividerColor,
          borderRadius: BorderRadius.circular(PsDimens.space4),
          border: Border.all(color: PsColors.mainDividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: PsDimens.space12, top: PsDimens.space10),
          child: Text(inputSearchController.text,
              style: Theme.of(context).textTheme.titleSmall),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        inputSearchController.clear();
      },
    );
    return Scaffold(
      backgroundColor: PsColors.baseColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Utils.getBrightnessForAppBar(context)),
        titleSpacing: 0,
        iconTheme: Theme.of(context)
            .iconTheme
            .copyWith(color: PsColors.mainColorWithWhite),
        title: _searchTextFieldWidget,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: PsDimens.space8),
            child: IconButton(
              icon: Icon(Icons.search, color: PsColors.mainColor, size: 26),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      body: WillPopScope(
          onWillPop: _requestPop,
          child: MultiProvider(
              providers: <SingleChildWidget>[
                ChangeNotifierProvider<SearchResultProvider>(
                  lazy: false,
                  create: (BuildContext context) {
                    final SearchResultProvider provider =
                        SearchResultProvider(searchResultRepository!);
                    final SearchResultParameterHolder holder =
                        SearchResultParameterHolder(
                            searchTerm: inputSearchController.text.trim());
                    provider.loadSearchResult(holder.toMap());
                    return provider;
                  },
                ),
                ChangeNotifierProvider<BasketProvider>(
                    lazy: false,
                    create: (BuildContext context) {
                      final BasketProvider basketProvider = BasketProvider(
                          repo: basketRepository!,
                          psValueHolder: psValueHolder);
                      basketProvider.loadBasketList();
                      return basketProvider;
                    }),
                ChangeNotifierProvider<SearchProductProvider>(
                  lazy: false,
                  create: (BuildContext context) {
                    final SearchProductProvider provider =
                        SearchProductProvider(
                            repo: repo1!, valueHolder: psValueHolder);
                    provider
                        .loadProductListByKey(widget.productParameterHolder);
                    return provider;
                  },
                ),
                ChangeNotifierProvider<SearchHistoryProvider>(
                  lazy: false,
                  create: (BuildContext context) {
                    searchHistoryProvider =
                        SearchHistoryProvider(repo: searchHistoryRepository!);
                    return searchHistoryProvider!;
                  },
                )
              ],
              child: Consumer<SearchResultProvider>(builder:
                  (BuildContext context, SearchResultProvider provider,
                      Widget? child) {
                if (
                    //provider != null &&
                    // provider.productList != null &&
                    provider.searchResult.data != null) {
                  final List<Category> categoriesList =
                      provider.searchResult.data!.categories!;
                  final List<SubCategory> subCategoriesList =
                      provider.searchResult.data!.subCategories!;

                  final List<Product> itemList =
                      provider.searchResult.data!.products!;
                  if (isCallFirstTime) {
                    ///
                    /// Add to Search History
                    ///
                    searchHistory =
                        SearchHistory(searchTeam: inputSearchController.text);
                    searchHistoryProvider!.addSearchHistoryList(searchHistory!);

                    isCallFirstTime = false;
                  }
                  return SingleChildScrollView(
                    child: Container(
                      color: PsColors.baseColor,
                      child: Column(
                        children: <Widget>[
                          CustomResultListTileView(
                            fadeAnimation: fadeAnimation,
                            animationController: animationController,
                            viewAllPressed: () {
                              Navigator.pushNamed(
                                  context, RoutePaths.searchCategoryViewAll,
                                  arguments: <String, String>{
                                    'title': Utils.getString(
                                        context, 'search__categories'),
                                    'keyword':
                                        inputSearchController.text.trim(),
                                  });
                            },
                            title:
                                Utils.getString(context, 'search__categories'),
                            dataList: categoriesList,
                          ),
                          CustomResultListTileView(
                            fadeAnimation: fadeAnimation,
                            animationController: animationController,
                            viewAllPressed: () {
                              Navigator.pushNamed(context,
                                  RoutePaths.searchSubCategoryViewAll,
                                  arguments: <String, String>{
                                    'title': Utils.getString(
                                        context, 'search__sub_categories'),
                                    'keyword':
                                        inputSearchController.text.trim(),
                                  });
                            },
                            title: Utils.getString(
                                context, 'search__sub_categories'),
                            dataList: subCategoriesList,
                          ),
                          CustomItemResultListView(
                            fadeAnimation: fadeAnimation,
                            animationController: animationController,
                            productList: itemList,
                            provider: provider,
                            keyword: inputSearchController.text.trim(),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return PSProgressIndicator(provider.searchResult.status);
                }
              }))),
    );
  }
}

class SearchItemListViewWidget extends StatefulWidget {
  const SearchItemListViewWidget({
    Key? key,
    required this.parameterHolder,
    required this.provider,
    required this.scrollController,
    required this.animationController,
    required this.animation,
  }) : super(key: key);

  final ProductParameterHolder parameterHolder;
  final SearchProductProvider provider;
  final ScrollController scrollController;
  final AnimationController animationController;
  final Animation<double> animation;

  @override
  _SearchItemListViewWidgetState createState() =>
      _SearchItemListViewWidgetState();
}

class _SearchItemListViewWidgetState extends State<SearchItemListViewWidget> {
  @override
  Widget build(BuildContext context) {
    // final PsValueHolder valueHolder;   valueHolder = Provider.of<PsValueHolder>(context);

    return Stack(children: <Widget>[
      Container(
          child: RefreshIndicator(
        child: ListView.builder(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: widget.provider.productList.data!.length,
            itemBuilder: (BuildContext context, int index) {
              final int count = widget.provider.productList.data!.length;
              final Product product = widget.provider.productList.data![index];
              widget.animationController.forward();
              return FadeTransition(
                  opacity: widget.animation,
                  child: SearchItemListItem(
                    animationController: widget.animationController,
                    animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval((1 / count) * index, 1.0,
                            curve: Curves.fastOutSlowIn),
                      ),
                    ),
                    product: widget.provider.productList.data![index],
                    parameterHolder: widget.parameterHolder,
                    onTap: () {
                      final ProductDetailIntentHolder holder =
                          ProductDetailIntentHolder(
                        productId: product.id,
                        heroTagImage: widget.provider.hashCode.toString() +
                            product.id! +
                            PsConst.HERO_TAG__IMAGE,
                        heroTagTitle: widget.provider.hashCode.toString() +
                            product.id! +
                            PsConst.HERO_TAG__TITLE,
                        heroTagOriginalPrice:
                            widget.provider.hashCode.toString() +
                                product.id! +
                                PsConst.HERO_TAG__ORIGINAL_PRICE,
                        heroTagUnitPrice: widget.provider.hashCode.toString() +
                            product.id! +
                            PsConst.HERO_TAG__UNIT_PRICE,
                      );

                      Navigator.pushNamed(context, RoutePaths.productDetail,
                          arguments: holder);
                    },
                  ));
            }),
        onRefresh: () {
          return widget.provider.resetLatestProductList(
            widget.parameterHolder,
          );
        },
      )),
      PSProgressIndicator(widget.provider.productList.status)
    ]);
  }
}

class CustomResultListTileView extends StatefulWidget {
  const CustomResultListTileView({
    Key? key,
    required this.title,
    required this.dataList,
    required this.viewAllPressed,
    required this.animationController,
    required this.fadeAnimation,
  }) : super(key: key);
  final String title;
  final List<dynamic> dataList;
  final Function() viewAllPressed;
  final AnimationController animationController;
  final Animation<double> fadeAnimation;

  @override
  State<CustomResultListTileView> createState() =>
      _CustomResultListTileViewState();
}

class _CustomResultListTileViewState extends State<CustomResultListTileView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    if (widget.dataList.isNotEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
          Widget>[
        AnimatedBuilder(
          animation: widget.fadeAnimation,
          child: Container(
            color: PsColors.backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Text(
                    widget.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontSize: 16,fontWeight: FontWeight.bold),
                  ),
                ),
                RawMaterialButton(
                    onPressed: widget.viewAllPressed,
                    child: Text(
                      Utils.getString(context, 'dashboard__view_all'),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontSize: 12.5, fontWeight: FontWeight.w600,color: PsColors.mainColor),
                    )),
              ],
            ),
          ),
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: widget.fadeAnimation,
              child: child,
            );
          },
        ),
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            shrinkWrap: true,
            itemCount: widget.dataList.length,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController.forward();
              return AnimatedBuilder(
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: widget.animationController,
                    curve: Interval((1 / widget.dataList.length) * index, 1.0,
                        curve: Curves.fastOutSlowIn),
                  ),
                ),
                builder: (BuildContext context, Widget? child) {
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval(
                            (1 / widget.dataList.length) * index, 1.0,
                            curve: Curves.fastOutSlowIn),
                      ),
                    ),
                    child: Transform(
                      transform: Matrix4.translationValues(
                          0.0,
                          100 *
                              (1.0 -
                                  Tween<double>(begin: 0.0, end: 1.0)
                                      .animate(
                                        CurvedAnimation(
                                          parent: widget.animationController,
                                          curve: Interval(
                                              (1 / widget.dataList.length) *
                                                  index,
                                              1.0,
                                              curve: Curves.fastOutSlowIn),
                                        ),
                                      )
                                      .value),
                          0.0),
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    if (widget.dataList[index] is Category) {
                      Navigator.pushNamed(context, RoutePaths.subCategoryGrid,
                          arguments: widget.dataList[index]);
                    }

                    if (widget.dataList[index] is SubCategory) {
                      final ProductParameterHolder parameterHolder =
                          ProductParameterHolder()
                              .getSubCategoryByCatIdParameterHolder();
                      parameterHolder.subCatId = widget.dataList[index].id;
                      parameterHolder.catId = widget.dataList[index].catId;
                      final ProductListIntentHolder holder =
                          ProductListIntentHolder(
                              productParameterHolder: parameterHolder,
                              appBarTitle: widget.dataList[index].name);
                      Navigator.pushNamed(context, RoutePaths.filterProductList,
                          arguments: holder);
                    }
                  },
                  child: Container(
                    height: 45,
                    color: PsColors.baseColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(widget.dataList[index].name),
                        ),
                         Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: PsColors.mainColor,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })
      ]);
    } else {
      return const SizedBox();
    }
  }
}

class CustomItemResultListView extends StatefulWidget {
  const CustomItemResultListView({
    Key? key,
    required this.productList,
    required this.provider,
    required this.keyword,
    required this.animationController,
    required this.fadeAnimation,
  }) : super(key: key);

  final List<Product> productList;
  final SearchResultProvider provider;
  final String keyword;
  final AnimationController animationController;
  final Animation<double> fadeAnimation;

  @override
  State<CustomItemResultListView> createState() =>
      _CustomItemResultListViewState();
}

class _CustomItemResultListViewState extends State<CustomItemResultListView>
    with SingleTickerProviderStateMixin {
  String? qty;
  String colorId = '';
  late String colorValue;
  late bool checkAttribute;
  late Basket basket;
  late String id;
  late double bottomSheetPrice;
  double totalOriginalPrice = 0.0;
  BasketSelectedAttribute basketSelectedAttribute = BasketSelectedAttribute();
  BasketSelectedAddOn basketSelectedAddOn = BasketSelectedAddOn();

  @override
  Widget build(BuildContext context) {
    final BasketProvider basketProvider = Provider.of<BasketProvider>(context);
    final PsValueHolder psValueHolder = Provider.of<PsValueHolder>(context);
    if (widget.productList.isNotEmpty) {
      return Column(
        children: <Widget>[
          AnimatedBuilder(
            animation: widget.fadeAnimation,
            child: Container(
              color: PsColors.backgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    child: Text(
                      Utils.getString(context, 'search__items'),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 16,fontWeight: FontWeight.bold),
                    ),
                  ),
                  RawMaterialButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, RoutePaths.searchItemViewAll,
                            arguments: <String, String>{
                              'title': 'Items',
                              'keyword': widget.keyword,
                            });
                      },
                      child: Text(
                        Utils.getString(context, 'dashboard__view_all'),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 12.5, fontWeight: FontWeight.w600,color: PsColors.mainColor),
                      )),
                ],
              ),
            ),
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                opacity: widget.fadeAnimation,
                child: child,
              );
            },
          ),
          GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  childAspectRatio: 0.6, maxCrossAxisExtent: 220),
              itemCount: widget.productList.length,
              itemBuilder: (BuildContext context, int index) {
                widget.animationController.forward();
                if (widget.provider.searchResult.status ==
                    PsStatus.BLOCK_LOADING) {
                  return Shimmer.fromColors(
                      baseColor: PsColors.grey,
                      highlightColor: PsColors.white,
                      child: Row(children: const <Widget>[
                        PsFrameUIForLoading(),
                      ]));
                } else {
                  final Product product =
                      widget.provider.searchResult.data!.products![index];
                  return AnimatedBuilder(
                      animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval(
                              (1 / widget.productList.length) * index, 1.0,
                              curve: Curves.fastOutSlowIn),
                        ),
                      ),
                      builder: (BuildContext context, Widget? child) {
                        return FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: widget.animationController,
                              curve: Interval(
                                  (1 / widget.productList.length) * index, 1.0,
                                  curve: Curves.fastOutSlowIn),
                            ),
                          ),
                          child: Transform(
                            transform: Matrix4.translationValues(
                                0.0,
                                100 *
                                    (1.0 -
                                        Tween<double>(begin: 0.0, end: 1.0)
                                            .animate(
                                              CurvedAnimation(
                                                parent:
                                                    widget.animationController,
                                                curve: Interval(
                                                    (1 /
                                                            widget.productList
                                                                .length) *
                                                        index,
                                                    1.0,
                                                    curve:
                                                        Curves.fastOutSlowIn),
                                              ),
                                            )
                                            .value),
                                0.0),
                            child: child,
                          ),
                        );
                      },
                      child: ProductVeticalListItem(
                        coreTagKey: widget.provider.hashCode.toString() +
                            widget.productList[index].id!,
                        animationController: widget.animationController,
                        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: widget.animationController,
                            curve: Interval(
                                (1 / widget.productList.length) * index, 1.0,
                                curve: Curves.fastOutSlowIn),
                          ),
                        ),
                        product: widget.productList[index],
                        onTap: () {
                          final ProductDetailIntentHolder holder =
                              ProductDetailIntentHolder(
                            productId: product.id,
                            heroTagImage:
                                widget.productList.hashCode.toString() +
                                    product.id! +
                                    PsConst.HERO_TAG__IMAGE,
                            heroTagTitle:
                                widget.productList.hashCode.toString() +
                                    product.id! +
                                    PsConst.HERO_TAG__TITLE,
                            heroTagOriginalPrice:
                                widget.productList.hashCode.toString() +
                                    product.id! +
                                    PsConst.HERO_TAG__ORIGINAL_PRICE,
                            heroTagUnitPrice:
                                widget.productList.hashCode.toString() +
                                    product.id! +
                                    PsConst.HERO_TAG__UNIT_PRICE,
                          );

                          Navigator.pushNamed(context, RoutePaths.productDetail,
                              arguments: holder);
                        },
                        onButtonTap: () async {
                          if (product.isAvailable == '1') {
                            if (product.addOnList!.isNotEmpty &&
                                    product.addOnList![0].id != '' ||
                                product.customizedHeaderList!.isNotEmpty &&
                                    product.customizedHeaderList![0].id != '' &&
                                    product.customizedHeaderList![0]
                                            .customizedDetail !=
                                        null) {
                              showDialog<dynamic>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ChooseAttributeDialog(
                                        product: widget.productList[index]);
                                  });
                            } else {
                              id =
                                  '${product.id}$colorId${basketSelectedAddOn.getSelectedaddOnIdByHeaderId()}${basketSelectedAttribute.getSelectedAttributeIdByHeaderId()}';
                              if (product.minimumOrder == '0') {
                                product.minimumOrder = '1';
                              }
                              basket = Basket(
                                  id: id,
                                  productId: product.id,
                                  qty: qty ?? product.minimumOrder,
                                  shopId: psValueHolder.shopId,
                                  selectedColorId: colorId,
                                  selectedColorValue: colorValue,
                                  // ignore: unnecessary_null_comparison
                                  basketPrice: bottomSheetPrice == null
                                      ? product.unitPrice
                                      : bottomSheetPrice.toString(),
                                  basketOriginalPrice: totalOriginalPrice == 0.0
                                      ? product.originalPrice
                                      : totalOriginalPrice.toString(),
                                  selectedAttributeTotalPrice:
                                      basketSelectedAttribute
                                          .getTotalSelectedAttributePrice()
                                          .toString(),
                                  product: product,
                                  basketSelectedAttributeList: 
                                      basketSelectedAttribute
                                      .getSelectedAttributeList(),
                                  basketSelectedAddOnList: 
                                      basketSelectedAddOn
                                      .getSelectedAddOnList());

                              await basketProvider.addBasket(basket);

                              Fluttertoast.showToast(
                                  msg: Utils.getString(context,
                                      'product_detail__success_add_to_basket'),
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: PsColors.mainColor,
                                  textColor: PsColors.white);

                              await Navigator.pushNamed(
                                context,
                                RoutePaths.basketList,
                              );
                            }
                          } else {
                            showDialog<dynamic>(
                                context: context,
                                builder: (BuildContext context) {
                                  return WarningDialog(
                                    message: Utils.getString(context,
                                        'product_detail__is_not_available'),
                                    onPressed: () {},
                                  );
                                });
                          }
                        },
                        valueHolder: psValueHolder,
                      ));
                }
              }),
        ],
      );
    } else {
      return const SizedBox();
    }
  }
}
