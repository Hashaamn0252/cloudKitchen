import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/ui/common/ps_hero.dart';
import 'package:flutterrestaurant/ui/common/ps_square_progress_widget.dart';
import 'package:flutterrestaurant/viewobject/default_icon.dart';
import 'package:flutterrestaurant/viewobject/default_photo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../constant/ps_constants.dart';
import '../../viewobject/common/ps_value_holder.dart';

class PsNetworkImage extends StatelessWidget {
  const PsNetworkImage(
      {Key? key,
      required this.photoKey,
      required this.defaultPhoto,
      this.width,
      this.height,
      this.onTap,
      this.boxfit = BoxFit.fill})
      : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final DefaultPhoto defaultPhoto;

  @override
  Widget build(BuildContext context) {
    bool isUseThumbnailAsPlaceholder = false;
    final PsValueHolder valueHolder =
        Provider.of<PsValueHolder>(context, listen: false);

    if (valueHolder.isUseThumbnailAsPlaceholder != null &&
        valueHolder.isUseThumbnailAsPlaceholder == PsConst.ONE) {
      isUseThumbnailAsPlaceholder = true;
    } else {
      isUseThumbnailAsPlaceholder = false;
    }
    if (defaultPhoto.imgPath == '') {
      return GestureDetector(
          onTap: onTap as void Function()?,
          child: Image.asset(
            'assets/images/placeholder_image.png',
            width: width,
            height: height,
            fit: boxfit,
          ));
    } else {
      final String fullImagePath =
          '${PsConfig.ps_app_image_url}${defaultPhoto.imgPath}';
      // print('img path : $fullImagePath');
      final String thumbnailImagePath =
          '${PsConfig.ps_app_image_thumbs_url}${defaultPhoto.imgPath}';

      return PsHero(
        transitionOnUserGestures: true,
        tag: photoKey,
        child: GestureDetector(
          onTap: onTap as void Function()?,
          child: Image.network(
            "$fullImagePath",
            width: width,
            height: height,
            fit: boxfit,
          ),
          // CachedNetworkImage(
          //   placeholder: (BuildContext context, String url) {
          //     if (isUseThumbnailAsPlaceholder) {
          //       return CachedNetworkImage(
          //         width: width,
          //         height: height,
          //         fit: boxfit,
          //         placeholder: (BuildContext context, String url) {
          //           return PsSquareProgressWidget();
          //         },
          //         imageUrl: thumbnailImagePath,
          //       );
          //     } else {
          //       return PsSquareProgressWidget();
          //     }
          //   },
          //   width: width,
          //   height: height,
          //   fit: boxfit,
          //   imageUrl: fullImagePath,
          //   errorWidget: (BuildContext context, String url, Object? error) =>
          //       Image.asset(
          //     'assets/images/placeholder_image.png',
          //     // width: width,
          //     // height: height,
          //     fit: boxfit,
          //   ),
          // ),
        ),
      );
    }
  }
}

class PsNetworkImageWithUrl extends StatelessWidget {
  const PsNetworkImageWithUrl(
      {Key? key,
      required this.photoKey,
      required this.imagePath,
      this.width,
      this.height,
      this.onTap,
      this.boxfit = BoxFit.cover})
      : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    bool isUseThumbnailAsPlaceholder = false;
    final PsValueHolder valueHolder =
        Provider.of<PsValueHolder>(context, listen: false);
    if (valueHolder.isUseThumbnailAsPlaceholder != null &&
        valueHolder.isUseThumbnailAsPlaceholder == PsConst.ONE) {
      isUseThumbnailAsPlaceholder = true;
    } else {
      isUseThumbnailAsPlaceholder = false;
    }
    if (imagePath == '') {
      return GestureDetector(
          onTap: onTap as void Function()?,
          child: Image.asset(
            'assets/images/placeholder_image.png',
            width: width,
            height: height,
            fit: boxfit,
          ));
    } else {
      final String fullImagePath = '${PsConfig.ps_app_image_url}$imagePath';
      final String thumbnailImagePath =
          '${PsConfig.ps_app_image_thumbs_url}$imagePath';

      if (photoKey == '') {
        return GestureDetector(
          onTap: onTap as void Function()?,
          child: Image.network(
            "$fullImagePath",
            width: width,
            height: height,
            fit: boxfit,
          ),
          //  CachedNetworkImage(
          //   placeholder: (BuildContext context, String url) {
          //     if (isUseThumbnailAsPlaceholder) {
          //       return CachedNetworkImage(
          //         width: width,
          //         height: height,
          //         fit: boxfit,
          //         placeholder: (BuildContext context, String url) {
          //           return PsSquareProgressWidget();
          //         },
          //         imageUrl: thumbnailImagePath,
          //       );
          //     } else {
          //       return PsSquareProgressWidget();
          //     }
          //   },
          //   width: width,
          //   height: height,
          //   fit: boxfit,
          //   imageUrl: fullImagePath,
          //   errorWidget: (BuildContext context, String url, Object? error) =>
          //       Image.asset(
          //     'assets/images/placeholder_image.png',
          // width: width,
          // height: height,
          // fit: boxfit,
          //   ),
          // ),
        );
      } else {
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: Image.network(
              "$fullImagePath",
              width: width,
              height: height,
              fit: boxfit,
            ));
        //    CachedNetworkImage(
        //     placeholder: (BuildContext context, String url) {
        //       if (isUseThumbnailAsPlaceholder) {
        //         return CachedNetworkImage(
        //           width: width,
        //           height: height,
        //           fit: boxfit,
        //           placeholder: (BuildContext context, String url) {
        //             return PsSquareProgressWidget();
        //           },
        //           imageUrl: thumbnailImagePath,
        //         );
        //       } else {
        //         return PsSquareProgressWidget();
        //       }
        //     },
        //     width: width,
        //     height: height,
        //     fit: boxfit,
        //     imageUrl: fullImagePath,
        //     errorWidget: (BuildContext context, String url, Object? error) =>
        //         Image.asset(
        //       'assets/images/placeholder_image.png',
        //       width: width,
        //       height: height,
        //       fit: boxfit,
        //     ),
        //   ),
        // );
      }
    }
  }
}

class PsFileImage extends StatelessWidget {
  const PsFileImage(
      {Key? key,
      required this.photoKey,
      required this.file,
      this.width,
      this.height,
      this.onTap,
      this.boxfit = BoxFit.cover})
      : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final File? file;

  @override
  Widget build(BuildContext context) {
    if (file == null) {
      return GestureDetector(
          onTap: onTap as void Function()?,
          child: Image.asset(
            'assets/images/placeholder_image.png',
            width: width,
            height: height,
            fit: boxfit,
          ));
    } else {
      if (photoKey == '') {
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: Image(
              image: FileImage(file!),
            ));
      } else {
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: Image(
              image: FileImage(file!),
            ));
      }
    }
  }
}

class PsNetworkCircleImage extends StatelessWidget {
  const PsNetworkCircleImage(
      {Key? key,
      required this.photoKey,
      this.imagePath,
      this.asset,
      this.width,
      this.height,
      this.onTap,
      this.boxfit = BoxFit.cover})
      : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final String? imagePath;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    bool isUseThumbnailAsPlaceholder = false;
    final PsValueHolder valueHolder =
        Provider.of<PsValueHolder>(context, listen: false);
    if (valueHolder.isUseThumbnailAsPlaceholder != null &&
        valueHolder.isUseThumbnailAsPlaceholder == PsConst.ONE) {
      isUseThumbnailAsPlaceholder = true;
    } else {
      isUseThumbnailAsPlaceholder = false;
    }
    if (imagePath == null || imagePath == '') {
      if (asset == null || asset == '') {
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10000.0),
                child: Image.asset(
                  'assets/images/placeholder_image.png',
                  width: width,
                  height: height,
                  fit: boxfit,
                )));
      } else {
        print('I Key : $photoKey$asset');
        print('');
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: Hero(
              tag: '$photoKey$asset',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10000.0),
                child: Image.asset(asset!,
                    width: width, height: height, fit: boxfit),
              ),
            ));
      }
    } else {
      final String fullImagePath = '${PsConfig.ps_app_image_url}$imagePath';
      final String thumbnailImagePath =
          '${PsConfig.ps_app_image_thumbs_url}$imagePath';

      if (photoKey == '') {
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10000.0),
              child: Image.network(
                "$fullImagePath",
                width: width,
                height: height,
                fit: boxfit,
              ),
              // CachedNetworkImage(
              //   placeholder: (BuildContext context, String url) {
              //     if (isUseThumbnailAsPlaceholder) {
              //       return CachedNetworkImage(
              //         width: width,
              //         height: height,
              //         fit: boxfit,
              //         placeholder: (BuildContext context, String url) {
              //           return PsSquareProgressWidget();
              //         },
              //         imageUrl: thumbnailImagePath,
              //       );
              //     } else {
              //       return PsSquareProgressWidget();
              //     }
              //   },
              //   width: width,
              //   height: height,
              //   fit: boxfit,
              //   imageUrl: fullImagePath,
              //   errorWidget:
              //       (BuildContext context, String url, Object? error) =>
              //           Image.asset(
              //     'assets/images/placeholder_image.png',
              //     width: width,
              //     height: height,
              //     fit: boxfit,
              //   ),
              // ),
            ));
      } else {
        return GestureDetector(
          onTap: onTap as void Function()?,
          child: Hero(
              tag: '$photoKey$imagePath',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10000.0),
                child: Image.network(
                  "$fullImagePath",
                  width: width,
                  height: height,
                  fit: boxfit,
                ),
                //  CachedNetworkImage(
                //   placeholder: (BuildContext context, String url) {
                //     if (isUseThumbnailAsPlaceholder) {
                //       return CachedNetworkImage(
                //         width: width,
                //         height: height,
                //         fit: boxfit,
                //         placeholder: (BuildContext context, String url) {
                //           return PsSquareProgressWidget();
                //         },
                //         imageUrl: thumbnailImagePath,
                //       );
                //     } else {
                //       return PsSquareProgressWidget();
                //     }
                //   },
                //   width: width,
                //   height: height,
                //   fit: boxfit,
                //   imageUrl: fullImagePath,
                //   errorWidget:
                //       (BuildContext context, String url, Object? error) =>
                //           Image.asset(
                //     'assets/images/placeholder_image.png',
                //     width: width,
                //     height: height,
                //     fit: boxfit,
                //   ),
                // ),
              )),
        );
      }
    }
  }
}

class PsNetworkCircleImageForUser extends StatelessWidget {
  const PsNetworkCircleImageForUser(
      {Key? key,
      required this.photoKey,
      this.imagePath,
      this.asset,
      this.width,
      this.height,
      this.onTap,
      this.boxfit = BoxFit.cover})
      : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final String? imagePath;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    bool isUseThumbnailAsPlaceholder = false;
    final PsValueHolder valueHolder =
        Provider.of<PsValueHolder>(context, listen: false);
    if (valueHolder.isUseThumbnailAsPlaceholder != null &&
        valueHolder.isUseThumbnailAsPlaceholder == PsConst.ONE) {
      isUseThumbnailAsPlaceholder = true;
    } else {
      isUseThumbnailAsPlaceholder = false;
    }
    if (imagePath == null || imagePath == '') {
      if (asset == null || asset == '') {
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10000.0),
                child: Image.asset(
                  'assets/images/user_default_photo.png',
                  width: width,
                  height: height,
                  fit: boxfit,
                )));
      } else {
        print('I Key : $photoKey$asset');
        print('');
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: Hero(
              tag: '$photoKey$asset',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10000.0),
                child: Image.asset(asset!,
                    width: width, height: height, fit: boxfit),
              ),
            ));
      }
    } else {
      final String fullImagePath = '${PsConfig.ps_app_image_url}$imagePath';
      final String thumbnailImagePath =
          '${PsConfig.ps_app_image_thumbs_url}$imagePath';

      if (photoKey == '') {
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10000.0),
              child: Image.network(
                "$fullImagePath",
                width: width,
                height: height,
                fit: boxfit,
              ),
              //  CachedNetworkImage(
              //   placeholder: (BuildContext context, String url) {
              //     if (isUseThumbnailAsPlaceholder) {
              //       return CachedNetworkImage(
              //         width: width,
              //         height: height,
              //         fit: boxfit,
              //         placeholder: (BuildContext context, String url) {
              //           return PsSquareProgressWidget();
              //         },
              //         imageUrl: thumbnailImagePath,
              //       );
              //     } else {
              //       return PsSquareProgressWidget();
              //     }
              //   },
              //   width: width,
              //   height: height,
              //   fit: boxfit,
              //   imageUrl: fullImagePath,
              //   errorWidget:
              //       (BuildContext context, String url, Object? error) =>
              //           Image.asset(
              //     'assets/images/user_default_photo.png',
              //     width: width,
              //     height: height,
              //     fit: boxfit,
              //   ),
              // ),
            ));
      } else {
        return GestureDetector(
          onTap: onTap as void Function()?,
          child: Hero(
              tag: '$photoKey$imagePath',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10000.0),
                child: Image.network(
                  "$fullImagePath",
                  width: width,
                  height: height,
                  fit: boxfit,
                ),
                // CachedNetworkImage(
                //   placeholder: (BuildContext context, String url) {
                //     if (isUseThumbnailAsPlaceholder) {
                //       return CachedNetworkImage(
                //         width: width,
                //         height: height,
                //         fit: boxfit,
                //         placeholder: (BuildContext context, String url) {
                //           return PsSquareProgressWidget();
                //         },
                //         imageUrl: thumbnailImagePath,
                //       );
                //     } else {
                //       return PsSquareProgressWidget();
                //     }
                //   },
                //   width: width,
                //   height: height,
                //   fit: boxfit,
                //   imageUrl: fullImagePath,
                //   errorWidget:
                //       (BuildContext context, String url, Object? error) =>
                //           Image.asset(
                //     'assets/images/user_default_photo.png',
                //     width: width,
                //     height: height,
                //     fit: boxfit,
                //   ),
                // ),
              )),
        );
      }
    }
  }
}

class PsFileCircleImage extends StatelessWidget {
  const PsFileCircleImage(
      {Key? key,
      required this.photoKey,
      this.file,
      this.asset,
      this.width,
      this.height,
      this.onTap,
      this.boxfit = BoxFit.cover})
      : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final File? file;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    if (file == null) {
      if (asset == null || asset == '') {
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10000.0),
                child: Container(
                    width: width,
                    height: height,
                    child: const Icon(Icons.image))));
      } else {
        print('I Key : $photoKey$asset');
        print('');
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: Hero(
              tag: '$photoKey$asset',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10000.0),
                child: Image.asset(asset!,
                    width: width, height: height, fit: boxfit),
              ),
            ));
      }
    } else {
      if (photoKey == '') {
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10000.0),
                child: Image(
                  image: FileImage(file!),
                )));
      } else {
        return GestureDetector(
          onTap: onTap as void Function()?,
          child: Hero(
              tag: file!,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10000.0),
                  child: Image(image: FileImage(file!)))),
        );
      }
    }
  }
}

class PSProgressIndicator extends StatefulWidget {
  const PSProgressIndicator(this._status, {this.message});
  final PsStatus _status;
  final String? message;

  @override
  _PSProgressIndicator createState() => _PSProgressIndicator();
}

class _PSProgressIndicator extends State<PSProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    if (widget._status == PsStatus.ERROR &&
        widget.message != null &&
        widget.message != '') {
      Fluttertoast.showToast(
          msg: widget.message!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white);
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Visibility(
          visible: widget._status == PsStatus.PROGRESS_LOADING,
          child: const LinearProgressIndicator(),
        ),
      ),
    );
  }
}

class PsNetworkCircleIconImage extends StatelessWidget {
  const PsNetworkCircleIconImage(
      {Key? key,
      required this.photoKey,
      required this.defaultIcon,
      this.width,
      this.height,
      this.onTap,
      this.boxfit = BoxFit.cover})
      : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final DefaultIcon defaultIcon;

  @override
  Widget build(BuildContext context) {
    bool isUseThumbnailAsPlaceholder = false;
    final PsValueHolder valueHolder =
        Provider.of<PsValueHolder>(context, listen: false);
    if (valueHolder.isUseThumbnailAsPlaceholder != null &&
        valueHolder.isUseThumbnailAsPlaceholder == PsConst.ONE) {
      isUseThumbnailAsPlaceholder = true;
    } else {
      isUseThumbnailAsPlaceholder = false;
    }
    if (defaultIcon.imgPath == '') {
      return GestureDetector(
          onTap: onTap as void Function()?,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10000.0),
              child: Image.asset(
                'assets/images/placeholder_image.png',
                width: width,
                height: height,
                fit: boxfit,
              )));
    } else {
      final String fullImagePath =
          '${PsConfig.ps_app_image_url}${defaultIcon.imgPath}';
      final String thumbnailImagePath =
          '${PsConfig.ps_app_image_thumbs_url}${defaultIcon.imgPath}';

      if (photoKey == '') {
        return GestureDetector(
            onTap: onTap as void Function()?,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10000.0),
              child: Image.network(
                "$fullImagePath",
                width: width,
                height: height,
                fit: boxfit,
              ),
              // CachedNetworkImage(
              //   placeholder: (BuildContext context, String url) {
              //     if (isUseThumbnailAsPlaceholder) {
              //       return CachedNetworkImage(
              //         width: width,
              //         height: height,
              //         fit: boxfit,
              //         placeholder: (BuildContext context, String url) {
              //           return PsSquareProgressWidget();
              //         },
              //         imageUrl: thumbnailImagePath,
              //       );
              //     } else {
              //       return PsSquareProgressWidget();
              //     }
              //   },
              //   width: width,
              //   height: height,
              //   fit: boxfit,
              //   imageUrl: fullImagePath,
              //   errorWidget:
              //       (BuildContext context, String url, Object? error) =>
              //           Image.asset(
              //     'assets/images/placeholder_image.png',
              //     width: width,
              //     height: height,
              //     fit: boxfit,
              //   ),
              // ),
            ));
      } else {
        return GestureDetector(
          onTap: onTap as void Function()?,
          child: Hero(
              tag:
                  '$photoKey${PsConfig.ps_app_image_url}${defaultIcon.imgPath}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10000.0),
                child: Image.network(
                  "$fullImagePath",
                  width: width,
                  height: height,
                  fit: boxfit,
                ),
                //  CachedNetworkImage(
                //   placeholder: (BuildContext context, String url) {
                //     if (isUseThumbnailAsPlaceholder) {
                //       return CachedNetworkImage(
                //         width: width,
                //         height: height,
                //         fit: boxfit,
                //         placeholder: (BuildContext context, String url) {
                //           return PsSquareProgressWidget();
                //         },
                //         imageUrl: thumbnailImagePath,
                //       );
                //     } else {
                //       return PsSquareProgressWidget();
                //     }
                //   },
                //   width: width,
                //   height: height,
                //   fit: boxfit,
                //   imageUrl: fullImagePath,
                //   errorWidget:
                //       (BuildContext context, String url, Object? error) =>
                //           Image.asset(
                //     'assets/images/placeholder_image.png',
                //     width: width,
                //     height: height,
                //     fit: boxfit,
                //   ),
                // ),
              )),
        );
      }
    }
  }
}
