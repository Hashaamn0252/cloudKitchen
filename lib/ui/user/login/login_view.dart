import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_button_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/privacy_policy_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/user.dart';
import 'package:provider/provider.dart';
import 'package:the_apple_sign_in/apple_sign_in_button.dart' as apple;

import '../../../constant/ps_constants.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    Key? key,
    this.animationController,
    this.animation,
    this.onProfileSelected,
    this.onForgotPasswordSelected,
    this.onSignInSelected,
    this.onPhoneSignInSelected,
    this.onFbSignInSelected,
    this.onGoogleSignInSelected,
  }) : super(key: key);

  final AnimationController? animationController;
  final Animation<double>? animation;
  final Function? onProfileSelected,
      onForgotPasswordSelected,
      onSignInSelected,
      onPhoneSignInSelected,
      onFbSignInSelected,
      onGoogleSignInSelected;
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  UserRepository? repo1;
  PsValueHolder? psValueHolder;
  bool showFacebookLogin = true;
  bool showGoogleLogin = true;
  bool showPhoneLogin = true;

  @override
  Widget build(BuildContext context) {
    widget.animationController!.forward();
    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space28,
    );

    repo1 = Provider.of<UserRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    if (psValueHolder!.showFacebookLogin != null &&
        psValueHolder!.showFacebookLogin == PsConst.ONE) {
          showFacebookLogin = true;
      } else {
          showFacebookLogin = false;
      }
    if (psValueHolder!.showGoogleLogin != null &&
        psValueHolder!.showGoogleLogin == PsConst.ONE) {
          showGoogleLogin = true;
      } else {
          showGoogleLogin = false;
      }
    if (psValueHolder!.showPhoneLogin != null &&
        psValueHolder!.showPhoneLogin == PsConst.ONE) {
          showPhoneLogin = true;
      } else {
          showPhoneLogin = false;
      }

    return SliverToBoxAdapter(
        child: ChangeNotifierProvider<UserProvider>(
      lazy: false,
      create: (BuildContext context) {
        final UserProvider provider =
            UserProvider(repo: repo1!, psValueHolder: psValueHolder!);
        print(provider.getCurrentFirebaseUser());
        // provider.postUserLogin(userLoginParameterHolder.toMap());
        return provider;
      },
      child: Consumer<UserProvider>(
          builder: (BuildContext context, UserProvider provider, Widget? child) {
        return AnimatedBuilder(
          animation: widget.animationController!,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _HeaderIconAndTextWidget(),
                _TextFieldAndSignInButtonWidget(
                  provider: provider,
                  text: Utils.getString(context, 'login__submit'),
                  onProfileSelected: widget.onProfileSelected,
                ),
                _spacingWidget,
                _DividerORWidget(),
                const SizedBox(
                  height: PsDimens.space12,
                ),
                _TermsAndConCheckbox(
                  provider: provider,
                  onCheckBoxClick: () {
                    setState(() {
                      updateCheckBox(context, provider);
                    });
                  },
                ),
                const SizedBox(
                  height: PsDimens.space8,
                ),
                if (showPhoneLogin)
                  _LoginWithPhoneWidget(
                    onPhoneSignInSelected: widget.onPhoneSignInSelected,
                    provider: provider,
                  ),
                if (showFacebookLogin)
                  _LoginWithFbWidget(
                      userProvider: provider,
                      onFbSignInSelected: widget.onFbSignInSelected),
                if (showGoogleLogin)
                  _LoginWithGoogleWidget(
                      userProvider: provider,
                      onGoogleSignInSelected: widget.onGoogleSignInSelected),
                if (Utils.isAppleSignInAvailable == 1 && Platform.isIOS)
                  _LoginWithAppleIdWidget(
                      onAppleIdSignInSelected: widget.onGoogleSignInSelected),
                _spacingWidget,
                _spacingWidget,
                _ForgotPasswordAndRegisterWidget(
                  provider: provider,
                  animationController: widget.animationController!,
                  onForgotPasswordSelected: widget.onForgotPasswordSelected,
                  onSignInSelected: widget.onSignInSelected,
                ),
                _spacingWidget,
              ],
            ),
          ),
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
                opacity: widget.animation!,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - widget.animation!.value), 0.0),
                  child: child,
                ));
          },
        );
      }),
    ));
  }
}

class _TermsAndConCheckbox extends StatefulWidget {
  const _TermsAndConCheckbox(
      {required this.provider, required this.onCheckBoxClick});

  final UserProvider provider;
  final Function? onCheckBoxClick;

  @override
  __TermsAndConCheckboxState createState() => __TermsAndConCheckboxState();
}

class __TermsAndConCheckboxState extends State<_TermsAndConCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const SizedBox(
          width: PsDimens.space20,
        ),
        Checkbox(
          activeColor: PsColors.mainColor,
          value: widget.provider.isCheckBoxSelect,
          onChanged: (bool? value) {
            widget.onCheckBoxClick!();
          },
        ),
        Expanded(
          child: InkWell(
            child: Text(
              Utils.getString(context, 'login__agree_privacy'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () {
              widget.onCheckBoxClick!();
            },
          ),
        ),
      ],
    );
  }
}

void updateCheckBox(BuildContext context, UserProvider provider) {
  if (provider.isCheckBoxSelect) {
    provider.isCheckBoxSelect = false;
  } else {
    provider.isCheckBoxSelect = true;

    Navigator.pushNamed(context, RoutePaths.privacyPolicy,
        arguments: PrivacyPolicyIntentHolder(
            title: Utils.getString(context, 'privacy_policy__toolbar_name'),
            description: ''));
  }
}

class _HeaderIconAndTextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Widget _textWidget = Text(Utils.getString(context, 'app_name'),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: PsColors.mainColor));

    final Widget _imageWidget = Container(
      width: 90,
      height: 90,
      child: Image.asset(
        'assets/images/fs_android_3x.png',
      ),
    );
    return Column(
      children: <Widget>[
        const SizedBox(
          height: PsDimens.space32,
        ),
        _imageWidget,
        const SizedBox(
          height: PsDimens.space8,
        ),
        _textWidget,
        const SizedBox(
          height: PsDimens.space52,
        ),
      ],
    );
  }
}

class _TextFieldAndSignInButtonWidget extends StatefulWidget {
  const _TextFieldAndSignInButtonWidget({
    required this.provider,
    required this.text,
    this.onProfileSelected,
  });

  final UserProvider provider;
  final String text;
  final Function? onProfileSelected;

  @override
  __CardWidgetState createState() => __CardWidgetState();
}

class __CardWidgetState extends State<_TextFieldAndSignInButtonWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // final FirebaseAuth auth = FirebaseAuth.instance;
  // Future<FirebaseUser> handleSignInEmail(String email, String password) async {
  //   AuthResult result =
  //       await auth.signInWithEmailAndPassword(email: email, password: password);
  //   final FirebaseUser user = result.user;

  //   assert(user != null);
  //   assert(await user.getIdToken() != null);

  //   final FirebaseUser currentUser = await auth.currentUser();
  //   assert(user.uid == currentUser.uid);

  //   print('signInEmail succeeded: $user');

  //   return user;
  // }

  // Future<FirebaseUser> handleSignUp(email, password) async {
  //   AuthResult result = await auth.createUserWithEmailAndPassword(
  //       email: email, password: password);
  //   final FirebaseUser user = result.user;

  //   assert(user != null);
  //   assert(await user.getIdToken() != null);

  //   return user;
  // }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets _marginEdgeInsetsforCard = EdgeInsets.only(
        left: PsDimens.space16,
        right: PsDimens.space16,
        top: PsDimens.space4,
        bottom: PsDimens.space4);
    return Column(
      children: <Widget>[
        Card(
          elevation: 0.3,
          margin: const EdgeInsets.only(
              left: PsDimens.space32, right: PsDimens.space32),
          child: Column(
            children: <Widget>[
              Container(
                margin: _marginEdgeInsetsforCard,
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: Utils.getString(context, 'login__email'),
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: PsColors.textPrimaryLightColor),
                      icon: Icon(Icons.email,
                          color: Theme.of(context).iconTheme.color)),
                ),
              ),
              const Divider(
                height: PsDimens.space1,
              ),
              Container(
                margin: _marginEdgeInsetsforCard,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: Utils.getString(context, 'login__password'),
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: PsColors.textPrimaryLightColor),
                      icon: Icon(Icons.lock,
                          color: Theme.of(context).iconTheme.color)),
                  // keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: PsDimens.space8,
        ),
        Container(
          margin: const EdgeInsets.only(
              left: PsDimens.space32, right: PsDimens.space32),
          child: PSButtonWidget(
            hasShadow: true,
            width: double.infinity,
            titleText: Utils.getString(context, 'login__sign_in'),
            onPressed: () async {
              if (emailController.text.isEmpty) {
                callWarningDialog(context,
                    Utils.getString(context, 'warning_dialog__input_email'));
              } else if (passwordController.text.isEmpty) {
                callWarningDialog(context,
                    Utils.getString(context, 'warning_dialog__input_password'));
              } else {
                if (Utils.checkEmailFormat(emailController.text.trim())!) {
                  await widget.provider.loginWithEmailId(
                      context,
                      emailController.text.trim(),
                      passwordController.text,
                      widget.onProfileSelected);
                } else {
                  callWarningDialog(context,
                      Utils.getString(context, 'warning_dialog__email_format'));
                }
              }
            },
          ),
        )
      ],
    );
  }
}

dynamic callWarningDialog(BuildContext context, String text) {
  showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return WarningDialog(
          message: Utils.getString(context, text),
          onPressed: () {},
        );
      });
}

class _DividerORWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const Widget _dividerWidget = Expanded(
      child: Divider(
        height: PsDimens.space2,
      ),
    );

    const Widget _spacingWidget = SizedBox(
      width: PsDimens.space8,
    );

    final Widget _textWidget =
        Text('OR', style: Theme.of(context).textTheme.titleMedium);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _dividerWidget,
        _spacingWidget,
        _textWidget,
        _spacingWidget,
        _dividerWidget,
      ],
    );
  }
}

class _LoginWithPhoneWidget extends StatefulWidget {
  const _LoginWithPhoneWidget(
      {required this.onPhoneSignInSelected, required this.provider});
  final Function? onPhoneSignInSelected;
  final UserProvider provider;

  @override
  __LoginWithPhoneWidgetState createState() => __LoginWithPhoneWidgetState();
}

class __LoginWithPhoneWidgetState extends State<_LoginWithPhoneWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          left: PsDimens.space32, right: PsDimens.space32),
      child: PSButtonWithIconWidget(
        titleText: Utils.getString(context, 'login__phone_signin'),
        icon: Icons.phone,
        colorData: widget.provider.isCheckBoxSelect
            ? PsColors.mainColor
            : PsColors.mainColor,
        onPressed: () async {
          if (widget.provider.isCheckBoxSelect) {
            if (widget.onPhoneSignInSelected != null) {
              widget.onPhoneSignInSelected!();
            } else {
              Navigator.pushReplacementNamed(
                context,
                RoutePaths.user_phone_signin_container,
              );
            }
          } else {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return WarningDialog(
                    message: Utils.getString(
                        context, 'login__warning_agree_privacy'),
                    onPressed: () {},
                  );
                });
          }
        },
      ),
    );
  }
}

class _LoginWithFbWidget extends StatefulWidget {
  const _LoginWithFbWidget(
      {required this.userProvider, required this.onFbSignInSelected});
  final UserProvider userProvider;
  final Function? onFbSignInSelected;

  @override
  __LoginWithFbWidgetState createState() => __LoginWithFbWidgetState();
}

class __LoginWithFbWidgetState extends State<_LoginWithFbWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          left: PsDimens.space32,
          top: PsDimens.space8,
          right: PsDimens.space32),
      child: PSButtonWithIconWidget(
          titleText: Utils.getString(context, 'login__fb_signin'),
          icon: FontAwesome.facebook_official,
          colorData: widget.userProvider.isCheckBoxSelect == false
              ? PsColors.facebookLoginButtonColor
              : PsColors.facebookLoginButtonColor,
          onPressed: () async {
            await widget.userProvider
                .loginWithFacebookId(context, widget.onFbSignInSelected);
          }),
    );
  }
}

class _LoginWithAppleIdWidget extends StatelessWidget {
  const _LoginWithAppleIdWidget({required this.onAppleIdSignInSelected});

  final Function? onAppleIdSignInSelected;

  @override
  Widget build(BuildContext context) {
    final UserProvider _userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return Container(
        margin: const EdgeInsets.only(
            left: PsDimens.space32,
            top: PsDimens.space8,
            right: PsDimens.space32),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: apple.AppleSignInButton(
            style: apple.ButtonStyle.black, // style as needed
            type: apple.ButtonType.signIn, // style as needed
            onPressed: () async {
              await _userProvider.loginWithAppleId(
                  context, onAppleIdSignInSelected);
            },
          ),
        ));
  }
}

class _LoginWithGoogleWidget extends StatefulWidget {
  const _LoginWithGoogleWidget(
      {required this.userProvider, required this.onGoogleSignInSelected});
  final UserProvider userProvider;
  final Function? onGoogleSignInSelected;

  @override
  __LoginWithGoogleWidgetState createState() => __LoginWithGoogleWidgetState();
}

class __LoginWithGoogleWidgetState extends State<_LoginWithGoogleWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          left: PsDimens.space32,
          top: PsDimens.space8,
          right: PsDimens.space32),
      child: PSButtonWithIconWidget(
        titleText: Utils.getString(context, 'login__google_signin'),
        icon: FontAwesome.google,
        colorData: widget.userProvider.isCheckBoxSelect
            ? PsColors.googleLoginButtonColor
            : PsColors.googleLoginButtonColor,
        onPressed: () async {
          await widget.userProvider
              .loginWithGoogleId(context, widget.onGoogleSignInSelected);
        },
      ),
    );
  }
}

class _ForgotPasswordAndRegisterWidget extends StatefulWidget {
  const _ForgotPasswordAndRegisterWidget(
      {Key? key,
      this.provider,
      this.animationController,
      this.onForgotPasswordSelected,
      this.onSignInSelected})
      : super(key: key);

  final AnimationController? animationController;
  final Function? onForgotPasswordSelected;
  final Function? onSignInSelected;
  final UserProvider? provider;

  @override
  __ForgotPasswordAndRegisterWidgetState createState() =>
      __ForgotPasswordAndRegisterWidgetState();
}

class __ForgotPasswordAndRegisterWidgetState
    extends State<_ForgotPasswordAndRegisterWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: PsDimens.space40),
      margin: const EdgeInsets.all(PsDimens.space12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: GestureDetector(
              child: Text(
                Utils.getString(context, 'login__forgot_password'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: PsColors.mainColor,
                    ),
              ),
              onTap: () {
                if (widget.onForgotPasswordSelected != null) {
                  widget.onForgotPasswordSelected!();
                } else {
                  Navigator.pushReplacementNamed(
                    context,
                    RoutePaths.user_forgot_password_container,
                  );
                }
              },
            ),
          ),
          Flexible(
            child: GestureDetector(
              child: Text(
                Utils.getString(context, 'login__sign_up'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: PsColors.mainColor,
                    ),
              ),
              onTap: () async {
                if (widget.onSignInSelected != null) {
                  widget.onSignInSelected!();
                } else {
                  final dynamic returnData =
                      await Navigator.pushReplacementNamed(
                    context,
                    RoutePaths.user_register_container,
                  );
                  if (returnData != null && returnData is User) {
                    final User user = returnData;
                    widget.provider!.psValueHolder =
                        Provider.of<PsValueHolder>(context, listen: false);
                    widget.provider!.psValueHolder.loginUserId = user.userId;
                    widget.provider!.psValueHolder.userIdToVerify = '';
                    widget.provider!.psValueHolder.userNameToVerify = '';
                    widget.provider!.psValueHolder.userEmailToVerify = '';
                    widget.provider!.psValueHolder.userPasswordToVerify = '';
                    Navigator.pop(context, user);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
