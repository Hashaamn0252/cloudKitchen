import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/basket/basket_provider.dart';
import 'package:flutterrestaurant/provider/product/product_by_collectionid_provider.dart';
import 'package:flutterrestaurant/repository/basket_repository.dart';
import 'package:flutterrestaurant/repository/product_repository.dart';
import 'package:flutterrestaurant/ui/common/base/ps_widget_with_multi_provider.dart';
import 'package:flutterrestaurant/ui/common/dialog/choose_attribute_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_admob_banner_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/ui/product/item/product_vertical_list_item.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/basket_selected_add_on.dart';
import 'package:flutterrestaurant/viewobject/basket_selected_attribute.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/product.dart';
import 'package:flutterrestaurant/viewobject/product_collection_header.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ProductListByCollectionIdView extends StatefulWidget {
  const ProductListByCollectionIdView(
      {Key? key,
      required this.productCollectionHeader,
      required this.appBarTitle})
      : super(key: key);

  final ProductCollectionHeader productCollectionHeader;
  final String appBarTitle;
  @override
  State<StatefulWidget> createState() {
    return _ProductListByCollectionIdView();
  }
}

class _ProductListByCollectionIdView
    extends State<ProductListByCollectionIdView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  ProductByCollectionIdProvider? _productCollectionProvider;
  AnimationController? animationController;
  Animation<double>? animation;
  ProductRepository ?productCollectionRepository;
  BasketRepository? basketRepository;
  BasketProvider? basketProvider;
  PsValueHolder? psValueHolder;
  Basket? basket;
  String? id;
  String? colorId = '';
  String? qty;
  String? colorValue;
  bool? checkAttribute;
  double? bottomSheetPrice;
  double ?totalOriginalPrice = 0.0;
  BasketSelectedAttribute basketSelectedAttribute = BasketSelectedAttribute();
  BasketSelectedAddOn basketSelectedAddOn = BasketSelectedAddOn();

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _productCollectionProvider!
            .nextProductListByCollectionId(widget.productCollectionHeader.id!);
      }
    });

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

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
    productCollectionRepository = Provider.of<ProductRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    return WillPopScope(
      onWillPop: _requestPop,
      child: PsWidgetWithMultiProvider(
        child: MultiProvider(
            providers: <SingleChildWidget>[
              ChangeNotifierProvider<ProductByCollectionIdProvider>(
                  lazy: false,
                  create: (BuildContext context) {
                    _productCollectionProvider = ProductByCollectionIdProvider(
                        repo: productCollectionRepository,
                        psValueHolder: psValueHolder);
                    _productCollectionProvider!.loadProductListByCollectionId(
                        widget.productCollectionHeader.id!);
                    return _productCollectionProvider!;
                  }),
              ChangeNotifierProvider<BasketProvider>(
                  lazy: false,
                  create: (BuildContext context) {
                    basketProvider = BasketProvider(repo: basketRepository!);

                    return basketProvider!;
                  }),
            ],
            child: Consumer<ProductByCollectionIdProvider>(builder:
                (BuildContext context, ProductByCollectionIdProvider provider,
                    Widget? child) {
              if (
                //provider.productCollectionList != null &&
                  provider.productCollectionList.data != null) {
                ///
                /// Load Basket List
                ///
                basketProvider =
                    Provider.of<BasketProvider>(context, listen: false);

                basketProvider!.loadBasketList();
                return Scaffold(
                    appBar: AppBar(
                      systemOverlayStyle: SystemUiOverlayStyle(
                        statusBarIconBrightness:
                            Utils.getBrightnessForAppBar(context),
                      ),
                      iconTheme: Theme.of(context)
                          .iconTheme
                          .copyWith(color: PsColors.mainColorWithWhite),
                      title: Text(
                        widget.appBarTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold)
                            .copyWith(color: PsColors.mainColorWithWhite),
                      ),
                      titleSpacing: 0,
                      elevation: 0,
                      toolbarTextStyle:
                          TextStyle(color: PsColors.textPrimaryColor),
                      actions: <Widget>[
                        Consumer<BasketProvider>(builder: (BuildContext context,
                            BasketProvider basketProvider, Widget? child) {
                          return InkWell(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    width: PsDimens.space40,
                                    height: PsDimens.space40,
                                    margin: const EdgeInsets.only(
                                        top: PsDimens.space8,
                                        left: PsDimens.space8,
                                        right: PsDimens.space8),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.shopping_basket,
                                        color: PsColors.mainColor,
                                      ),
                                    ),
                                  ),
                                  if (basketProvider
                                      .basketList.data!.isNotEmpty)
                                  Positioned(
                                    right: PsDimens.space4,
                                    top: PsDimens.space1,
                                    child: Container(
                                      width: PsDimens.space28,
                                      height: PsDimens.space28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: PsColors.black.withAlpha(200),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          basketProvider
                                                      .basketList.data!.length >
                                                  99
                                              ? '99+'
                                              : basketProvider
                                                  .basketList.data!.length
                                                  .toString(),
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(color: PsColors.white),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  RoutePaths.basketList,
                                );
                              });
                        }),
                      ],
                    ),
                    body: Column(
                      children: <Widget>[
                        const PsAdMobBannerWidget(admobSize: AdSize.banner),
                        Expanded(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                  color: PsColors.baseColor,
                                  margin: const EdgeInsets.only(
                                      left: PsDimens.space4,
                                      right: PsDimens.space4,
                                      top: PsDimens.space4,
                                      bottom: PsDimens.space4),
                                  child: RefreshIndicator(
                                    child: CustomScrollView(
                                      controller: _scrollController,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      slivers: <Widget>[
                                        SliverToBoxAdapter(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: PsDimens.space8),
                                            child: PsNetworkImage(
                                              photoKey: '',
                                              defaultPhoto: widget
                                                  .productCollectionHeader
                                                  .defaultPhoto!,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: PsDimens.space240,
                                            ),
                                          ),
                                        ),
                                        SliverGrid(
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                                  maxCrossAxisExtent: 300,
                                                  childAspectRatio: 0.6),
                                          delegate: SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                              if (provider.productCollectionList
                                                      .data !=
                                                  null) {
                                                final int count = provider
                                                    .productCollectionList
                                                    .data!
                                                    .length;
                                                final Product product = provider
                                                    .productCollectionList
                                                    .data![index];
                                                return ProductVeticalListItem(
                                                  coreTagKey: provider.hashCode
                                                          .toString() +
                                                      provider
                                                          .productCollectionList
                                                          .data![index]
                                                          .id!,
                                                  animationController:
                                                      animationController!,
                                                  animation: Tween<double>(
                                                          begin: 0.0, end: 1.0)
                                                      .animate(
                                                    CurvedAnimation(
                                                      parent:
                                                          animationController!,
                                                      curve: Interval(
                                                          (1 / count) * index,
                                                          1.0,
                                                          curve: Curves
                                                              .fastOutSlowIn),
                                                    ),
                                                  ),
                                                  product: provider
                                                      .productCollectionList
                                                      .data![index],
                                                  onTap: () {
                                                    final ProductDetailIntentHolder
                                                        holder =
                                                        ProductDetailIntentHolder(
                                                      productId: product.id,
                                                      heroTagImage: provider
                                                              .hashCode
                                                              .toString() +
                                                          product.id! +
                                                          PsConst
                                                              .HERO_TAG__IMAGE,
                                                      heroTagTitle: provider
                                                              .hashCode
                                                              .toString() +
                                                          product.id !+
                                                          PsConst
                                                              .HERO_TAG__TITLE,
                                                      heroTagOriginalPrice: provider
                                                              .hashCode
                                                              .toString() +
                                                          product.id! +
                                                          PsConst
                                                              .HERO_TAG__ORIGINAL_PRICE,
                                                      heroTagUnitPrice: provider
                                                              .hashCode
                                                              .toString() +
                                                          product.id! +
                                                          PsConst
                                                              .HERO_TAG__UNIT_PRICE,
                                                    );

                                                    Navigator.pushNamed(
                                                        context,
                                                        RoutePaths
                                                            .productDetail,
                                                        arguments: holder);
                                                  },
                                                  onButtonTap: () async {
                                                    if (product.isAvailable ==
                                                        '1') {
                                                      if (product.addOnList!
                                                                  .isNotEmpty &&
                                                              product
                                                                      .addOnList![
                                                                          0]
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
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return ChooseAttributeDialog(
                                                                  product: provider
                                                                      .productCollectionList
                                                                      .data![index]);
                                                            });
                                                      } else {
                                                        id =
                                                            '${product.id}$colorId${basketSelectedAddOn.getSelectedaddOnIdByHeaderId()}${basketSelectedAttribute.getSelectedAttributeIdByHeaderId()}';
                                                        if (product
                                                                .minimumOrder ==
                                                            '0') {
                                                          product.minimumOrder =
                                                              '1';
                                                        }
                                                        basket = Basket(
                                                            id: id,
                                                            productId: product
                                                                .id,
                                                            qty:
                                                                qty ??
                                                                    product
                                                                        .minimumOrder,
                                                            shopId: psValueHolder!
                                                                .shopId,
                                                            selectedColorId:
                                                                colorId,
                                                            selectedColorValue:
                                                                colorValue,
                                                            basketPrice: bottomSheetPrice ==
                                                                    null
                                                                ? product
                                                                    .unitPrice
                                                                : bottomSheetPrice
                                                                    .toString(),
                                                            basketOriginalPrice:
                                                                totalOriginalPrice ==
                                                                        0.0
                                                                    ? product
                                                                        .originalPrice
                                                                    : totalOriginalPrice
                                                                        .toString(),
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

                                                        await basketProvider!
                                                            .addBasket(basket!);

                                                        Fluttertoast.showToast(
                                                            msg: Utils.getString(
                                                                context,
                                                                'product_detail__success_add_to_basket'),
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                            timeInSecForIosWeb:
                                                                1,
                                                            backgroundColor:
                                                                PsColors
                                                                    .mainColor,
                                                            textColor:
                                                                PsColors.white);

                                                        await Navigator
                                                            .pushNamed(
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
                                                              message: Utils
                                                                  .getString(
                                                                      context,
                                                                      'product_detail__is_not_available'),
                                                              onPressed: () {},
                                                            );
                                                          });
                                                    }
                                                  }, valueHolder: psValueHolder!,
                                                );
                                              } else {
                                                return null;
                                              }
                                            },
                                            childCount: provider
                                                .productCollectionList
                                                .data!
                                                .length,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onRefresh: () {
                                      return provider
                                          .resetProductListByCollectionId(widget
                                              .productCollectionHeader.id!);
                                    },
                                  )),
                              PSProgressIndicator(
                                  provider.productCollectionList.status)
                            ],
                          ),
                        ),
                      ],
                    ));
              } else {
                return Container();
              }
            })),
      ),
    );
  }
}
