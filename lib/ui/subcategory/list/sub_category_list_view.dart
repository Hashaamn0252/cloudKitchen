import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/subcategory/sub_category_provider.dart';
import 'package:flutterrestaurant/repository/sub_category_repository.dart';
import 'package:flutterrestaurant/ui/common/ps_admob_banner_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/ui/subcategory/item/sub_category_vertical_list_item.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/category.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SubCategoryListView extends StatefulWidget {
  const SubCategoryListView({this.category});
  final Category? category;
  @override
  _SubCategoryListViewState createState() {
    return _SubCategoryListViewState();
  }
}

class _SubCategoryListViewState extends State<SubCategoryListView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  SubCategoryProvider? _subCategoryProvider;

  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final String categId = widget.category!.id!;
        Utils.psPrint('CategoryId number is $categId');

        _subCategoryProvider!.nextSubCategoryList(widget.category!.id!);
      }
    });
  }

  SubCategoryRepository? repo1;
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;


  @override
  Widget build(BuildContext context) {
  
    timeDilation = 1.0;
    repo1 = Provider.of<SubCategoryRepository>(context);
    // final dynamic data = EasyLocalizationProvider.of(context).data;

    return
        // EasyLocalizationProvider(
        //     data: data,
        //     child:
        Scaffold(
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
              ), 
              title: Text(
                Utils.getString(context, 'Sub'),
                style: TextStyle(color: PsColors.white),
              ),
              iconTheme: IconThemeData(
                color: PsColors.white,
              ),
            ),
            body: ChangeNotifierProvider<SubCategoryProvider>(
                lazy: false,
                create: (BuildContext context) {
                  _subCategoryProvider = SubCategoryProvider(repo: repo1!);
                  _subCategoryProvider!.loadSubCategoryList(widget.category!.id!);
                  return _subCategoryProvider!;
                },
                child: Consumer<SubCategoryProvider>(builder:
                    (BuildContext context, SubCategoryProvider provider,
                        Widget? child) {
                  return Column(
                    children: <Widget>[
                      const PsAdMobBannerWidget(
                        admobSize: AdSize.banner
                      ),
                      Expanded(
                        child: Stack(children: <Widget>[
                          Container(
                              child: RefreshIndicator(
                            onRefresh: () {
                              return _subCategoryProvider!
                                  .resetSubCategoryList(widget.category!.id!);
                            },
                            child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                itemCount: provider.subCategoryList.data!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (provider.subCategoryList.status ==
                                      PsStatus.BLOCK_LOADING) {
                                    return Shimmer.fromColors(
                                        baseColor: PsColors.grey,
                                        highlightColor: PsColors.white,
                                        child: Column(children: const <Widget>[
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                        ]));
                                  } else {
                                    return SubCategoryVerticalListItem(
                                      subCategory:
                                          provider.subCategoryList.data![index],
                                      onTap: () {
                                        print(provider.subCategoryList
                                            .data![index].defaultPhoto!.imgPath);
                                      },
                                    );
                                  }
                                }),
                          )),
                          PSProgressIndicator(provider.subCategoryList.status)
                        ]),
                      )
                    ],
                  );
                })));
  }
}

class FrameUIForLoading extends StatelessWidget {
  const FrameUIForLoading({
    Key ?key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
            height: 70,
            width: 70,
            margin: const EdgeInsets.all(PsDimens.space16),
            decoration: BoxDecoration(color: PsColors.grey)),
        Expanded(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
              height: 15,
              margin: const EdgeInsets.all(PsDimens.space8),
              decoration: BoxDecoration(color: PsColors.grey)),
          Container(
              height: 15,
              margin: const EdgeInsets.all(PsDimens.space8),
              decoration: BoxDecoration(color: PsColors.grey)),
        ]))
      ],
    );
  }
}
