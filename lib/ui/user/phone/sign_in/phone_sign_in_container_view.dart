import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/user/phone/sign_in/phone_sign_in_view.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:provider/provider.dart';

class PhoneSignInContainerView extends StatefulWidget {
  @override
  _CityPhoneSignInContainerViewState createState() =>
      _CityPhoneSignInContainerViewState();
}

class _CityPhoneSignInContainerViewState extends State<PhoneSignInContainerView>
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

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserProvider? userProvider;
  UserRepository? userRepo;

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

    print(
        '............................Build UI Again ............................');
    userRepo = Provider.of<UserRepository>(context);
    return WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
          body: Stack(children: <Widget>[
            Container(
              color: PsColors.mainLightColorWithBlack,
              width: double.infinity,
              height: double.maxFinite,
            ),
            CustomScrollView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                slivers: <Widget>[
                  _SliverAppbar(
                    title: Utils.getString(context, 'home_phone_signin'),
                    scaffoldKey: scaffoldKey,
                  ),
                  PhoneSignInView(
                    animationController: animationController!,
                  ),
                ])
          ]),
        ));
  }
}

class _SliverAppbar extends StatefulWidget {
  const _SliverAppbar(
      {Key? key, required this.title, this.scaffoldKey,})
      : super(key: key);
  final String title;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  
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
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(fontWeight: FontWeight.bold)
            .copyWith(color: PsColors.mainColorWithWhite),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.notifications_none,
              color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pushNamed(
              context,
              RoutePaths.notiList,
            );
          },
        ),
        IconButton(
          icon:
              Icon(FontAwesome5.book_open, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pushNamed(
              context,
              RoutePaths.blogList,
            );
          },
        )
      ],
      elevation: 0,
    );
  }
}
