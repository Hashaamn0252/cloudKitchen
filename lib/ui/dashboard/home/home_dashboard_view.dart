import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/basket/basket_provider.dart';
import 'package:flutterrestaurant/provider/category/category_provider.dart';
import 'package:flutterrestaurant/provider/category/trending_category_provider.dart';
import 'package:flutterrestaurant/provider/product/search_product_provider.dart';
import 'package:flutterrestaurant/provider/productcollection/product_collection_provider.dart';
import 'package:flutterrestaurant/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrestaurant/repository/basket_repository.dart';
import 'package:flutterrestaurant/repository/category_repository.dart';
import 'package:flutterrestaurant/repository/product_collection_repository.dart';
import 'package:flutterrestaurant/repository/product_repository.dart';
import 'package:flutterrestaurant/repository/shop_info_repository.dart';
import 'package:flutterrestaurant/ui/category/item/category_vertical_list_item.dart';
import 'package:flutterrestaurant/ui/common/dialog/choose_attribute_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/confirm_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/dialog/rating_dialog/core.dart';
import 'package:flutterrestaurant/ui/common/dialog/rating_dialog/style.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/ui/dashboard/home/home_tabbar_slider.dart';
import 'package:flutterrestaurant/ui/product/item/product_vertical_list_item.dart';
import 'package:flutterrestaurant/ui/search/search_item_view_all/search_item_view_all_container.dart';
import 'package:flutterrestaurant/utils/colors.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/basket_selected_add_on.dart';
import 'package:flutterrestaurant/viewobject/basket_selected_attribute.dart';
import 'package:flutterrestaurant/viewobject/category.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/category_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/product_list_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/product_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/touch_count_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/product.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class HomeDashboardViewWidget extends StatefulWidget {
  const HomeDashboardViewWidget(this.animationController, this.context);

  final AnimationController animationController;
  final BuildContext context;

  @override
  _HomeDashboardViewWidgetState createState() =>
      _HomeDashboardViewWidgetState();
}

class _HomeDashboardViewWidgetState extends State<HomeDashboardViewWidget> {
  PsValueHolder? valueHolder;
  List imageList = [];
  CategoryRepository? repo1;
  ProductRepository? repo2;
  ProductCollectionRepository? repo3;
  ShopInfoRepository? shopInfoRepository;
  ShopInfoProvider? shopInfoProvider;
  CategoryProvider? _categoryProvider;
  TrendingCategoryProvider? _trendingCategoryProvider;
  BasketRepository? basketRepository;
  BasketProvider? basketProvider;
  final int count = 8;
  final CategoryParameterHolder trendingCategory = CategoryParameterHolder();
  final CategoryParameterHolder categoryIconList = CategoryParameterHolder();
  final TextEditingController userInputItemNameTextEditingController =
      TextEditingController();

  final RateMyApp _rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: 0,
      minLaunches: 1,
      remindDays: 5,
      remindLaunches: 1);

  get psValueHolder => null;
  @override
  void initState() {
    super.initState();
    if (_categoryProvider != null) {
      _categoryProvider!.loadCategoryList(categoryIconList.toMap());
    }

    if (Platform.isAndroid) {
      _rateMyApp.init().then((_) {
        if (_rateMyApp.shouldOpenDialog) {
          _rateMyApp.showStarRateDialog(
            context,
            title: Utils.getString(context, 'home__menu_drawer_rate_this_app'),
            message: Utils.getString(context, 'rating_popup_dialog_message'),
            ignoreNativeDialog: true,
            actionsBuilder: (BuildContext context, double? stars) {
              return <Widget>[
                TextButton(
                  child: Text(
                    Utils.getString(context, 'dialog__ok'),
                  ),
                  onPressed: () async {
                    if (stars != null) {
                      // _rateMyApp.save().then((void v) => Navigator.pop(context));
                      Navigator.pop(context);
                      if (stars < 1) {
                      } else if (stars >= 1 && stars <= 3) {
                        await _rateMyApp
                            .callEvent(RateMyAppEventType.laterButtonPressed);
                        await showDialog<dynamic>(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmDialogView(
                                description: Utils.getString(
                                    context, 'rating_confirm_message'),
                                leftButtonText:
                                    Utils.getString(context, 'dialog__cancel'),
                                rightButtonText: Utils.getString(
                                    context, 'home__menu_drawer_contact_us'),
                                onAgreeTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    RoutePaths.contactUs,
                                  );
                                },
                              );
                            });
                      } else if (stars >= 4) {
                        await _rateMyApp
                            .callEvent(RateMyAppEventType.rateButtonPressed);
                        if (Platform.isIOS) {
                          Utils.launchAppStoreURL(
                              iOSAppId: valueHolder!.iOSAppStoreId,
                              writeReview: true);
                        } else {
                          Utils.launchURL();
                        }
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                )
              ];
            },
            onDismissed: () =>
                _rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
            dialogStyle: const DialogStyle(
              titleAlign: TextAlign.center,
              messageAlign: TextAlign.center,
              messagePadding: EdgeInsets.only(bottom: 16.0),
            ),
            starRatingOptions: const StarRatingOptions(),
          );
        }
      });
    }
  }

  SearchProductProvider? searchProductProvider;
  var width, height;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    repo1 = Provider.of<CategoryRepository>(context);
    repo2 = Provider.of<ProductRepository>(context);
    repo3 = Provider.of<ProductCollectionRepository>(context);
    shopInfoRepository = Provider.of<ShopInfoRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);

    return MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<ShopInfoProvider>(
              lazy: false,
              create: (BuildContext context) {
                shopInfoProvider = ShopInfoProvider(
                    repo: shopInfoRepository!,
                    psValueHolder: valueHolder,
                    ownerCode: 'HomeDashboardViewWidget');
                shopInfoProvider!.loadShopInfo();
                return shopInfoProvider!;
              }),
          ChangeNotifierProvider<CategoryProvider>(
              lazy: false,
              create: (BuildContext context) {
                _categoryProvider ??= CategoryProvider(
                    repo: repo1!,
                    psValueHolder: valueHolder,
                    limit: valueHolder!.categoryLoadingLimit == null
                        ? 0
                        : int.parse(valueHolder!.categoryLoadingLimit!));
                _categoryProvider!.loadCategoryList(categoryIconList.toMap());
                // print(
                //     "the provider length is: ${_categoryProvider!.categoryList!.data!.length}");
                return _categoryProvider!;
              }),
          ChangeNotifierProvider<TrendingCategoryProvider>(
              lazy: false,
              create: (BuildContext context) {
                final TrendingCategoryProvider provider =
                    TrendingCategoryProvider(
                        repo: repo1!,
                        psValueHolder: valueHolder,
                        limit: int.parse(valueHolder!.categoryLoadingLimit!));
                provider
                    .loadTrendingCategoryList(trendingCategory.toMap())
                    .then((dynamic value) {
                  // Utils.psPrint("Is Has Internet " + value);
                  final bool isConnectedToIntenet = value ?? bool;
                  if (!isConnectedToIntenet) {
                    Fluttertoast.showToast(
                        msg: 'No Internet Connectiion. Please try again !',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blueGrey,
                        textColor: Colors.white);
                  }
                });
                return provider;
              }),
          ChangeNotifierProvider<ProductCollectionProvider>(
              lazy: false,
              create: (BuildContext context) {
                final ProductCollectionProvider provider =
                    ProductCollectionProvider(
                        repo: repo3!,
                        limit: int.parse(
                            valueHolder!.collectionProductLoadingLimit!));
                provider.loadProductCollectionList();

                return provider;
              }),
          ChangeNotifierProvider<BasketProvider>(
              lazy: false,
              create: (BuildContext context) {
                basketProvider = BasketProvider(
                    repo: basketRepository!, psValueHolder: valueHolder);
                basketProvider!.loadBasketList();
                return basketProvider!;
              }),
        ],
        child: Container(
          // color: PsColors.white,
          child:

              ///
              /// category List Widget
              ///
              RefreshIndicator(
            onRefresh: () {
              return _trendingCategoryProvider!
                  .resetTrendingCategoryList(trendingCategory.toMap())
                  .then((dynamic value) {
                // Utils.psPrint("Is Has Internet " + value);
                final bool isConnectedToIntenet = value ?? bool;
                if (!isConnectedToIntenet) {
                  Fluttertoast.showToast(
                      msg: 'No Internet Connectiion. Please try again !',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blueGrey,
                      textColor: Colors.white);
                }
              });
            },
            child: Container(
              width: width,
              height: height,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: width,
                        height: height * .23,
                        decoration: BoxDecoration(
                          image: shopInfoProvider == null
                              ? DecorationImage(
                                  image: AssetImage("myImages/homeImage.jpeg"),
                                  fit: BoxFit.fill)
                              : DecorationImage(
                                  image: NetworkImage(
                                      "${PsConfig.ps_app_image_url}${shopInfoProvider!.shopInfo!.data!.banner}"),
                                  fit: BoxFit.fill),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: height * .04,
                  ),
                  Container(
                    width: width,
                    height: height * .3,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2),
                      itemBuilder: (_, index) {
                        print(
                            "images length: ${_categoryProvider!.categoryList.data!.length}");
                        if (_categoryProvider!.categoryList.data != null ||
                            _categoryProvider!.categoryList.data!.isNotEmpty) {
                          final int count =
                              _categoryProvider!.categoryList.data!.length;
                          final String fullImagePath =
                              '${PsConfig.ps_app_image_url}${_categoryProvider!.categoryList.data![index]!.defaultPhoto!.imgPath}';
                          return InkWell(
                            onTap: () {
                              if (PsConfig.isShowSubCategory) {
                                Navigator.pushNamed(
                                    context, RoutePaths.subCategoryGrid,
                                    arguments: _categoryProvider!
                                        .categoryList.data![index]);
                              } else {
                                final String loginUserId =
                                    Utils.checkUserLoginId(psValueHolder!);
                                final TouchCountParameterHolder
                                    touchCountParameterHolder =
                                    TouchCountParameterHolder(
                                  typeId: _categoryProvider!
                                      .categoryList.data![index].id!,
                                  typeName:
                                      PsConst.FILTERING_TYPE_NAME_CATEGORY,
                                  userId: loginUserId,
                                );

                                _categoryProvider!.postTouchCount(
                                    touchCountParameterHolder.toMap());

                                final ProductParameterHolder
                                    productParameterHolder =
                                    ProductParameterHolder()
                                        .getLatestParameterHolder();
                                productParameterHolder.catId =
                                    _categoryProvider!
                                        .categoryList.data![index].id;
                                Navigator.pushNamed(
                                    context, RoutePaths.filterProductList,
                                    arguments: ProductListIntentHolder(
                                      appBarTitle: _categoryProvider!
                                          .categoryList.data![index].name!,
                                      productParameterHolder:
                                          productParameterHolder,
                                    ));
                              }
                            },
                            child: Container(
                                width: width * .08,
                                height: height * .08,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                  image: _categoryProvider!
                                              .categoryList
                                              .data![index]
                                              .defaultPhoto!
                                              .imgPath ==
                                          ''
                                      ? DecorationImage(
                                          colorFilter: ColorFilter.mode(
                                            Colors.white.withOpacity(0.9),
                                            BlendMode.darken,
                                          ),
                                          image: AssetImage(
                                              'assets/images/placeholder_image.png'
                                              // "${_categoryProvider!.categoryList!.data![index]}"
                                              ),
                                          fit: BoxFit.fill)
                                      : DecorationImage(
                                          colorFilter: ColorFilter.mode(
                                            Colors.white.withOpacity(0.5),
                                            BlendMode.dstATop,
                                          ),
                                          image: NetworkImage('$fullImagePath'
                                              // "${_categoryProvider!.categoryList!.data![index]}"
                                              ),
                                          fit: BoxFit.fill),
                                ),
                                child: Center(
                                  child: Text(
                                    "${_categoryProvider!.categoryList.data![index].name}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: purpleColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                          );

                          // CategoryVerticalListItem(
                          //   animationController: animationController,
                          //   animation: Tween<double>(begin: 0.0, end: 1.0)
                          //       .animate(
                          //     CurvedAnimation(
                          //       parent: animationController!,
                          //       curve: Interval((1 / count) * index, 1.0,
                          //           curve: Curves.fastOutSlowIn),
                          //     ),
                          //   ),
                          //   category: _categoryProvider!
                          //       .categoryList.data![index],
                          //   onTap: () {
                          //     if (PsConfig.isShowSubCategory) {
                          //       Navigator.pushNamed(
                          //           context, RoutePaths.subCategoryGrid,
                          //           arguments: _categoryProvider!
                          //               .categoryList.data![index]);
                          //     } else {
                          //       final String loginUserId =
                          //           Utils.checkUserLoginId(
                          //               psValueHolder!);
                          //       final TouchCountParameterHolder
                          //           touchCountParameterHolder =
                          //           TouchCountParameterHolder(
                          //         typeId: _categoryProvider!
                          //             .categoryList.data![index].id!,
                          //         typeName: PsConst
                          //             .FILTERING_TYPE_NAME_CATEGORY,
                          //         userId: loginUserId,
                          //       );

                          //       _categoryProvider!.postTouchCount(
                          //           touchCountParameterHolder.toMap());

                          //       final ProductParameterHolder
                          //           productParameterHolder =
                          //           ProductParameterHolder()
                          //               .getLatestParameterHolder();
                          //       productParameterHolder.catId =
                          //           _categoryProvider!
                          //               .categoryList.data![index].id;
                          //       Navigator.pushNamed(
                          //           context, RoutePaths.filterProductList,
                          //           arguments: ProductListIntentHolder(
                          //             appBarTitle: _categoryProvider!
                          //                 .categoryList
                          //                 .data![index]
                          //                 .name!,
                          //             productParameterHolder:
                          //                 productParameterHolder,
                          //           ));
                          //     }
                          //   },
                          // );
                        } else {
                          return null;
                        }
                      },
                      itemCount: _categoryProvider == null
                          ? 0
                          : _categoryProvider!.categoryList.data!.length,
                    ),
                  ),
                  Row(
                    children: [
                      shopInfoProvider == null
                          ? Container()
                          : shopInfoProvider!
                                  .shopInfo!.data!.sliderImages!.isEmpty
                              ? Container()
                              : Container(
                                  width: width,
                                  height: height * .24,
                                  child: CarouselSlider.builder(
                                    itemCount: shopInfoProvider!
                                        .shopInfo!.data!.sliderImages!.length,
                                    itemBuilder: (BuildContext context,
                                        int itemIndex, int pageViewIndex) {
                                      print(
                                          "carousel url is: ${"${PsConfig.ps_app_image_url}${shopInfoProvider!.shopInfo!.data!.sliderImages![itemIndex]}"}");
                                      return Container(
                                        margin: EdgeInsets.only(
                                            left: width * .04,
                                            right: width * .04),
                                        width: width,
                                        height: height * .24,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                width * .03),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    "${PsConfig.ps_app_image_url}${shopInfoProvider!.shopInfo!.data!.sliderImages![itemIndex]}"),
                                                fit: BoxFit.fill)),
                                      );
                                    },
                                    options:
                                        CarouselOptions(viewportFraction: 1),
                                  ))
                    ],
                  ),
                ],
              ),
            ),
            // _HomeCategoryHorizontalListWidget(
            //   shopInfoProvider: shopInfoProvider,
            //   psValueHolder: valueHolder!,
            //   animationController: widget.animationController,
            //   userInputItemNameTextEditingController:
            //       userInputItemNameTextEditingController,
            //   animation: Tween<double>(begin: 0.0, end: 1.0).animate(
            //       CurvedAnimation(
            //           parent: widget.animationController,
            //           curve: Interval((1 / count) * 2, 1.0,
            //               curve: Curves.fastOutSlowIn))), //animation
            // ),
          ),
        ));
  }
}

class _HomeLatestProductHorizontalListWidget extends StatefulWidget {
  const _HomeLatestProductHorizontalListWidget(
      {Key? key,
      required this.animationController,
      required this.animation,
      required this.productProvider,
      required this.basketProvider,
      required this.bottomSheetPrice,
      required this.totalOriginalPrice,
      required this.basketSelectedAddOn,
      required this.basketSelectedAttribute})
      : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;
  final SearchProductProvider productProvider;
  final BasketProvider basketProvider;
  final double? bottomSheetPrice;
  final double? totalOriginalPrice;
  final BasketSelectedAddOn basketSelectedAddOn;
  final BasketSelectedAttribute basketSelectedAttribute;

  @override
  __HomeLatestProductHorizontalListWidgetState createState() =>
      __HomeLatestProductHorizontalListWidgetState();
}

class __HomeLatestProductHorizontalListWidgetState
    extends State<_HomeLatestProductHorizontalListWidget> {
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // _offset = 0;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        widget.productProvider.nextProductListByKey(
          widget.productProvider.productParameterHolder,
        );
      }
      // setState(() {
      //   final double offset = _scrollController.offset;
      //   _delta = offset - _oldOffset!;
      //   if (_delta! > _containerMaxHeight)
      //     _delta = _containerMaxHeight;
      //   else if (_delta! < 0) {
      //     _delta = 0;
      //   }
      //   _oldOffset = offset;
      //   _offset = -_delta!;
      // });

      // print(' Offset $_offset');
    });
  }

  // final double _containerMaxHeight = 60;
  // double? _offset, _delta = 0, _oldOffset = 0;
  Basket? basket;
  String? id;
  String? colorId = '';
  String? qty;
  String? colorValue;
  bool? checkAttribute;
  double? bottomSheetPrice;
  double totalOriginalPrice = 0.0;
  BasketSelectedAttribute basketSelectedAttribute = BasketSelectedAttribute();
  BasketSelectedAddOn basketSelectedAddOn = BasketSelectedAddOn();
  PsValueHolder? valueHolder;
  @override
  Widget build(BuildContext context) {
    valueHolder = Provider.of<PsValueHolder>(context);

    return Consumer<SearchProductProvider>(
      builder: (BuildContext context, SearchProductProvider productProvider,
          Widget? child) {
        return AnimatedBuilder(
            animation: widget.animationController,
            builder: (BuildContext context, Widget? child) {
              return Column(children: <Widget>[
                Expanded(
                  child: Container(
                    color: PsColors.coreBackgroundColor,
                    child: Stack(children: <Widget>[
                      if (productProvider.productList.data!.isNotEmpty &&
                          productProvider.productList.data != null)
                        Container(
                            color: PsColors.coreBackgroundColor,
                            margin: const EdgeInsets.only(
                                left: PsDimens.space8,
                                right: PsDimens.space8,
                                top: PsDimens.space4,
                                bottom: PsDimens.space4),
                            child: RefreshIndicator(
                              child: CustomScrollView(
                                  controller: _scrollController,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  slivers: <Widget>[
                                    SliverGrid(
                                      gridDelegate:
                                          const SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: 220,
                                              childAspectRatio: 0.6),
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          if (productProvider
                                                      .productList.data !=
                                                  null ||
                                              productProvider.productList.data!
                                                  .isNotEmpty) {
                                            final int count = productProvider
                                                .productList.data!.length;
                                            final Product product =
                                                productProvider
                                                    .productList.data![index];
                                            return ProductVeticalListItem(
                                              coreTagKey: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  productProvider.productList
                                                      .data![index].id!,
                                              animationController:
                                                  widget.animationController,
                                              animation: Tween<double>(
                                                      begin: 0.0, end: 1.0)
                                                  .animate(
                                                CurvedAnimation(
                                                  parent: widget
                                                      .animationController,
                                                  curve: Interval(
                                                      (1 / count) * index, 1.0,
                                                      curve:
                                                          Curves.fastOutSlowIn),
                                                ),
                                              ),
                                              product: productProvider
                                                  .productList.data![index],
                                              onTap: () {
                                                final ProductDetailIntentHolder
                                                    holder =
                                                    ProductDetailIntentHolder(
                                                  productId: product.id,
                                                  heroTagImage: productProvider
                                                          .hashCode
                                                          .toString() +
                                                      product.id! +
                                                      PsConst.HERO_TAG__IMAGE,
                                                  heroTagTitle: productProvider
                                                          .hashCode
                                                          .toString() +
                                                      product.id! +
                                                      PsConst.HERO_TAG__TITLE,
                                                  heroTagOriginalPrice:
                                                      productProvider.hashCode
                                                              .toString() +
                                                          product.id! +
                                                          PsConst
                                                              .HERO_TAG__ORIGINAL_PRICE,
                                                  heroTagUnitPrice: productProvider
                                                          .hashCode
                                                          .toString() +
                                                      product.id! +
                                                      PsConst
                                                          .HERO_TAG__UNIT_PRICE,
                                                );

                                                Navigator.pushNamed(context,
                                                    RoutePaths.productDetail,
                                                    arguments: holder);
                                              },
                                              onButtonTap: () async {
                                                if (product.isAvailable ==
                                                    '1') {
                                                  if (product.addOnList!
                                                              .isNotEmpty &&
                                                          product.addOnList![0]
                                                                  .id !=
                                                              '' ||
                                                      product.customizedHeaderList!
                                                              .isNotEmpty &&
                                                          product
                                                                  .customizedHeaderList![
                                                                      0]
                                                                  .id !=
                                                              '' &&
                                                          product
                                                                  .customizedHeaderList![
                                                                      0]
                                                                  .customizedDetail !=
                                                              null) {
                                                    showDialog<dynamic>(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return ChooseAttributeDialog(
                                                              product: productProvider
                                                                  .productList
                                                                  .data![index]);
                                                        });
                                                  } else {
                                                    id =
                                                        '${product.id}$colorId${widget.basketSelectedAddOn.getSelectedaddOnIdByHeaderId()}${widget.basketSelectedAttribute.getSelectedAttributeIdByHeaderId()}';
                                                    if (product.minimumOrder ==
                                                        '0') {
                                                      product.minimumOrder =
                                                          '1';
                                                    }
                                                    basket = Basket(
                                                        id: id,
                                                        productId: product.id,
                                                        qty: qty ??
                                                            product
                                                                .minimumOrder,
                                                        shopId: valueHolder!
                                                            .shopId,
                                                        selectedColorId:
                                                            colorId,
                                                        selectedColorValue:
                                                            colorValue,
                                                        basketPrice: widget
                                                                    .bottomSheetPrice ==
                                                                null
                                                            ? product.unitPrice
                                                            : widget
                                                                .bottomSheetPrice
                                                                .toString(),
                                                        basketOriginalPrice: widget
                                                                    .totalOriginalPrice ==
                                                                0.0
                                                            ? product
                                                                .originalPrice
                                                            : widget
                                                                .totalOriginalPrice
                                                                .toString(),
                                                        selectedAttributeTotalPrice:
                                                            widget.basketSelectedAttribute
                                                                .getTotalSelectedAttributePrice()
                                                                .toString(),
                                                        product: product,
                                                        basketSelectedAttributeList: widget
                                                            .basketSelectedAttribute
                                                            .getSelectedAttributeList(),
                                                        basketSelectedAddOnList: widget
                                                            .basketSelectedAddOn
                                                            .getSelectedAddOnList());

                                                    await widget.basketProvider
                                                        .addBasket(basket!);

                                                    Fluttertoast.showToast(
                                                        msg: Utils.getString(
                                                            context,
                                                            'product_detail__success_add_to_basket'),
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            PsColors.mainColor,
                                                        textColor:
                                                            PsColors.white);

                                                    await Navigator.pushNamed(
                                                      context,
                                                      RoutePaths.basketList,
                                                    );
                                                  }
                                                } else {
                                                  showDialog<dynamic>(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return WarningDialog(
                                                          message: Utils.getString(
                                                              context,
                                                              'product_detail__is_not_available'),
                                                          onPressed: () {},
                                                        );
                                                      });
                                                }
                                              },
                                              valueHolder: valueHolder!,
                                            );
                                          } else {
                                            return null;
                                          }
                                        },
                                        childCount: productProvider
                                            .productList.data!.length,
                                      ),
                                    ),
                                  ]),
                              onRefresh: () {
                                return productProvider.resetLatestProductList(
                                    productProvider.productParameterHolder);
                              },
                            ))
                      else if (productProvider.productList.status !=
                              PsStatus.PROGRESS_LOADING &&
                          productProvider.productList.status !=
                              PsStatus.BLOCK_LOADING &&
                          productProvider.productList.status !=
                              PsStatus.NOACTION)
                        Align(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Image.asset(
                                  'assets/images/baseline_empty_item_grey_24.png',
                                  height: 100,
                                  width: 150,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(
                                  height: PsDimens.space32,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: PsDimens.space20,
                                      right: PsDimens.space20),
                                  child: Text(
                                    Utils.getString(context,
                                        'procuct_list__no_result_data'),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(),
                                  ),
                                ),
                                const SizedBox(
                                  height: PsDimens.space20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      PSProgressIndicator(productProvider.productList.status),
                    ]),
                  ),
                ),
              ]);
            });
      },
    );
  }
}

class _HomeCategoryHorizontalListWidget extends StatefulWidget {
  const _HomeCategoryHorizontalListWidget(
      {Key? key,
      required this.shopInfoProvider,
      required this.animationController,
      required this.animation,
      required this.psValueHolder,
      required this.userInputItemNameTextEditingController})
      : super(key: key);

  final ShopInfoProvider? shopInfoProvider;
  final AnimationController animationController;
  final Animation<double> animation;
  final PsValueHolder psValueHolder;
  final TextEditingController userInputItemNameTextEditingController;

  @override
  __HomeCategoryHorizontalListWidgetState createState() =>
      __HomeCategoryHorizontalListWidgetState();
}

bool showMainMenu = true;
bool showSpecialCollections = true;
bool showFeatureItems = true;

class __HomeCategoryHorizontalListWidgetState
    extends State<_HomeCategoryHorizontalListWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.psValueHolder.showMainMenu != null &&
        widget.psValueHolder.showMainMenu == PsConst.ONE) {
      showMainMenu = true;
    } else {
      showMainMenu = false;
    }
    if (widget.psValueHolder.showSpecialCollections != null &&
        widget.psValueHolder.showSpecialCollections == PsConst.ONE) {
      showSpecialCollections = true;
    } else {
      showSpecialCollections = false;
    }
    if (widget.psValueHolder.showFeaturedItems != null &&
        widget.psValueHolder.showFeaturedItems == PsConst.ONE) {
      showFeatureItems = true;
    } else {
      showFeatureItems = false;
    }
    return Consumer<CategoryProvider>(
      builder: (BuildContext context, CategoryProvider categoryProvider,
          Widget? child) {
        if (categoryProvider.categoryList.data == null ||
            categoryProvider.categoryList.data!.isEmpty ||
            widget.shopInfoProvider == null ||
            widget.shopInfoProvider!.shopInfo.data == null) {
          return Container();
        }

        final List<Category> _tmpList =
            List<Category>.from(categoryProvider.categoryList.data!);
        int i = 0;

        if (showMainMenu) {
          _tmpList.insert(
              i,
              Category(
                  id: PsConst.mainMenu,
                  name: Utils.getString(context, 'dashboard__main_menu')));
          i++;
        }

        if (showFeatureItems) {
          _tmpList.insert(
              i,
              Category(
                  id: PsConst.featuredItem,
                  name: Utils.getString(context, 'dashboard__featured_items')));
        }

        if (showSpecialCollections) {
          _tmpList.insert(
              i,
              Category(
                  id: PsConst.specialCollection,
                  name: Utils.getString(
                      context, 'dashboard__special_collection')));
        }

        return AnimatedBuilder(
            animation: widget.animationController,
            child: HomeTabbarProductListView(
                shopInfo: widget.shopInfoProvider!.shopInfo.data!,
                animationController: widget.animationController,
                categoryList: _tmpList, //categoryProvider.categoryList.data,
                userInputItemNameTextEditingController:
                    widget.userInputItemNameTextEditingController,
                valueHolder: widget.psValueHolder,
                key: Key('${_tmpList.length}')),
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                  opacity: widget.animation,
                  child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 30 * (1.0 - widget.animation.value), 0.0),
                      child: child));
            });
      },
    );
  }
}

class _MyHeaderWidget extends StatefulWidget {
  const _MyHeaderWidget({
    Key? key,
    required this.headerName,
    // this.productCollectionHeader,
    required this.viewAllClicked,
  }) : super(key: key);

  final String headerName;
  final Function? viewAllClicked;
  // final ProductCollectionHeader? productCollectionHeader;

  @override
  __MyHeaderWidgetState createState() => __MyHeaderWidgetState();
}

class __MyHeaderWidgetState extends State<_MyHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.viewAllClicked as void Function()?,
      child: Padding(
        padding: const EdgeInsets.only(
            top: PsDimens.space20,
            left: PsDimens.space16,
            right: PsDimens.space16,
            bottom: PsDimens.space10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(widget.headerName,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PsColors.textPrimaryDarkColor)),
            ),
            Text(
              Utils.getString(context, 'dashboard__view_all'),
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: PsColors.mainColor),
            ),
          ],
        ),
      ),
    );
  }
}
