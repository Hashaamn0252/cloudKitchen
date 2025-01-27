import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/search/home_item_search_view.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/holder/product_parameter_holder.dart';
import 'package:provider/provider.dart';

class HomeItemSearchContainerView extends StatefulWidget {
  const HomeItemSearchContainerView({required this.productParameterHolder});
  final ProductParameterHolder productParameterHolder;
  @override
  _CityHomeItemSearchContainerViewState createState() =>
      _CityHomeItemSearchContainerViewState();
}

class _CityHomeItemSearchContainerViewState
    extends State<HomeItemSearchContainerView>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  @override
  void initState() {
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  UserProvider? userProvider;
  UserRepository? userRepo;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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

    print(
        '............................Build UI Again ............................');
    userRepo = Provider.of<UserRepository>(context);
    return WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
          body: CustomScrollView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              slivers: <Widget>[
                _SliverAppbar(
                  title:
                      Utils.getString(context, 'home__bottom_app_bar_search'),
                  scaffoldKey: scaffoldKey,
                ),
                HomeItemSearchView(
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController!,
                      curve: const Interval((1 / 4) * 2, 1.0,
                          curve: Curves.fastOutSlowIn),
                    ),
                  ),
                  animationController: animationController!,
                  productParameterHolder: widget.productParameterHolder,
                ),
              ]),
        ));
  }
}

class _SliverAppbar extends StatefulWidget {
  const _SliverAppbar({
    Key? key,
    required this.title,
    this.scaffoldKey,
    // this.menuDrawer,
  }) : super(key: key);
  final String title;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  // final Drawer? menuDrawer;
  @override
  _SliverAppbarState createState() => _SliverAppbarState();
}

class _SliverAppbarState extends State<_SliverAppbar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
      ),
      iconTheme: Theme.of(context)
          .iconTheme
          .copyWith(color: PsColors.mainColorWithWhite),
      title: Text(
        widget.title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold, color: PsColors.mainColorWithWhite),
      ),
      elevation: 0,
    );
  }
}
