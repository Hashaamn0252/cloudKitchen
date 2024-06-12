import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/search_history/search_history_provider.dart';
import 'package:flutterrestaurant/repository/search_history_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/confirm_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_search_textfield_widget.dart';
import 'package:flutterrestaurant/ui/search_history/search_history_list_item.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/product_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/search_history.dart';
import 'package:provider/provider.dart';

class SearchHistoryListView extends StatefulWidget {

  @override
  _SearchHistoryListViewState createState() => _SearchHistoryListViewState();
}

class _SearchHistoryListViewState extends State<SearchHistoryListView> 
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  @override
  void initState() {
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    super.initState();
  }
    
  final TextEditingController userInputItemNameTextEditingController =
      TextEditingController();
  final ProductParameterHolder productParameterHolder =
      ProductParameterHolder().getLatestParameterHolder();
  PsValueHolder? psValueHolder;

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  SearchHistoryProvider? provider;
  SearchHistoryRepository? searchHistoryRepository;
  
  @override
  Widget build(BuildContext context) {
    searchHistoryRepository = Provider.of<SearchHistoryRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

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
    final Widget _searchTextFieldWidget = PsSearchTextFieldWidget(
       hintText:
            Utils.getString(context, 'search_history__app_bar_search'),
      textEditingController:
          userInputItemNameTextEditingController,
      psValueHolder: psValueHolder,
      height: 40,
      textInputAction: TextInputAction.search,
    );
    return WillPopScope(
      onWillPop: _requestPop,
      child: ChangeNotifierProvider<SearchHistoryProvider>(
          lazy: false,
          create: (BuildContext context) {
            provider = SearchHistoryProvider(repo: searchHistoryRepository!);
            if (psValueHolder!.loginUserId != null &&
                psValueHolder!.loginUserId != '')
            provider!.loadSearchHistoryList();
            return provider!;
          },
       child: Consumer<SearchHistoryProvider>(builder: (BuildContext context,
            SearchHistoryProvider provider, Widget? child) {    
          return Scaffold(
              appBar: AppBar(
                systemOverlayStyle: SystemUiOverlayStyle (
                  statusBarIconBrightness : Utils.getBrightnessForAppBar(context)
                ),
            titleSpacing: 0,
            iconTheme: Theme.of(context)
                .iconTheme
                .copyWith(color: PsColors.mainColorWithWhite),
            title: _searchTextFieldWidget,
            actions: <Widget>[
              Padding(padding: const EdgeInsets.only(right: PsDimens.space8),
                child: IconButton(
                  icon: Icon(Icons.search,
                    color: PsColors.mainColor,
                    size: 26),
                    onPressed: () {
                      productParameterHolder.searchTerm = 
                        userInputItemNameTextEditingController.text;
                      Navigator.pushNamed(
                          context, RoutePaths.searchItemList,
                          arguments: productParameterHolder);
                    },
                  ),
                ),
              ],
            ),
            body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (psValueHolder!.loginUserId != null &&
                psValueHolder!.loginUserId != '' &&
                provider.historyList.data != null &&
                provider.historyList.data!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: PsDimens.space16,
                left: PsDimens.space16,
                right: PsDimens.space16),
              child: Text(
                'Recent Search',
                style: Theme.of(context)
                  .textTheme
                  .titleSmall
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160.0, 
                          childAspectRatio: 3.0),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (provider.historyList.data != null &&
                              provider.historyList.data!.isNotEmpty) {   
                            return SearchHistoryListItem(
                                searchHistory: provider.historyList.data![index],
                                onTap: () {
                                  productParameterHolder.searchTerm = 
                                    provider.historyList.data![index].searchTeam;
                                  Navigator.pushNamed(
                                      context, RoutePaths.searchItemList,
                                      arguments: productParameterHolder);
                                },
                                onDeleteTap: () {
                                showDialog<dynamic>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ConfirmDialogView(
                                        description: Utils.getString(context,
                                            'search_history__confirm_dialog_description'),
                                        leftButtonText: Utils.getString(context,
                                            'app_info__cancel_button_name'),
                                        rightButtonText: Utils.getString(
                                            context,
                                            'dialog__ok'),
                                        onAgreeTap: () async {
                                          Navigator.of(context).pop();
                                          productParameterHolder.searchTerm = 
                                            provider.historyList.data![index].searchTeam;
                                          final SearchHistory searchHistory = SearchHistory(
                                            searchTeam: productParameterHolder.searchTerm);
                                          provider.deleteSearchHistory(searchHistory);

                                        });
                                  });
                                },
                              );
                          } else {
                              return null;
                          }
                        },
                        childCount: provider.historyList.data!.length,
                      ),
                    )
                  ]),
                  onRefresh: () {
                    return provider.resetSearchHistoryList();
                  },
                ),
              ),
            ])
          ));
        })
      ),
    );
  }
}

class SearchHistoryItemListViewWidget extends StatelessWidget {
  const SearchHistoryItemListViewWidget({
    required this.productParameterHolder,
     required this.psValueHolder,
  });

  final ProductParameterHolder productParameterHolder;
  final PsValueHolder psValueHolder;

  @override
  Widget build(BuildContext context) {
    final SearchHistoryProvider provider =
          Provider.of<SearchHistoryProvider>(context, listen: false);
   if (psValueHolder.loginUserId != null &&
      psValueHolder.loginUserId != '')
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: PsDimens.space16,
                left: PsDimens.space16,
                right: PsDimens.space16),
              child: Text(
                'Recent Search',
                style: Theme.of(context)
                  .textTheme
                  .titleSmall
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160.0, 
                          childAspectRatio: 3.0),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (provider.historyList.data != null ||
                              provider.historyList.data!.isEmpty) {   
                            return SearchHistoryListItem(
                                searchHistory: provider.historyList.data!.reversed
                                    .toList()[index],
                                onTap: () {
                                  productParameterHolder.searchTerm = 
                                    provider.historyList.data![index].searchTeam;
                                  Navigator.pushNamed(
                                      context, RoutePaths.searchItemList,
                                      arguments: productParameterHolder);
                                },
                                onDeleteTap: () {
                                showDialog<dynamic>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ConfirmDialogView(
                                        description: Utils.getString(context,
                                            'search_history__confirm_dialog_description'),
                                        leftButtonText: Utils.getString(context,
                                            'app_info__cancel_button_name'),
                                        rightButtonText: Utils.getString(
                                            context,
                                            'dialog__ok'),
                                        onAgreeTap: () async {
                                          Navigator.of(context).pop();
                                          productParameterHolder.searchTerm = 
                                            provider.historyList.data![index].searchTeam;
                                          final SearchHistory searchHistory = SearchHistory(
                                            searchTeam: productParameterHolder.searchTerm);
                                          provider.deleteSearchHistory(searchHistory);

                                        });
                                  });
                                },
                              );
                          } else {
                              return null;
                          }
                        },
                        childCount: provider.historyList.data!.length,
                      ),
                    )
                  ]),
                  onRefresh: () {
                    return provider.resetSearchHistoryList();
                },
              ),
            ),
          ])
        );
        else {
          return Container();
    }
  }
}
