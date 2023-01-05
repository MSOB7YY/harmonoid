/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart'
    hide ReorderableDragStartListener, Intent;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';
import 'package:harmonoid/interface/modern_layout/settings_modern/settings_modern.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:uri_parser/uri_parser.dart';
import 'package:animations/animations.dart';
import 'package:window_plus/window_plus.dart';
import 'package:media_library/media_library.dart';
import 'package:harmonoid_visual_assets/harmonoid_visual_assets.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:known_extents_list_view_builder/known_extents_list_view_builder.dart';

import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/interface/file_info_screen.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/interface/settings/about.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/web/web.dart';

import 'package:harmonoid/main.dart';

class MobileAppBarOverflowButtonModern extends StatefulWidget {
  final Color? color;
  MobileAppBarOverflowButtonModern({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  State<MobileAppBarOverflowButtonModern> createState() =>
      _MobileAppBarOverflowButtonModernState();
}

class _MobileAppBarOverflowButtonModernState
    extends State<MobileAppBarOverflowButtonModern> {
  @override
  Widget build(BuildContext context) {
    return CircularButton(
      icon: Icon(
        Icons.more_vert,
        color: widget.color ??
            Theme.of(context).appBarTheme.actionsIconTheme?.color,
      ),
      onPressed: () {
        final position = RelativeRect.fromRect(
          Offset(
                MediaQuery.of(context).size.width - tileMargin - 48.0,
                MediaQuery.of(context).padding.top +
                    kMobileSearchBarHeight +
                    2 * tileMargin,
              ) &
              Size(160.0, 160.0),
          Rect.fromLTWH(
            0,
            0,
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
        );
        showMenu<int>(
          context: context,
          position: position,
          elevation: 4.0,
          constraints: BoxConstraints(
            maxWidth: double.infinity,
          ),
          items: [
            PopupMenuItem(
              value: 0,
              child: ListTile(
                leading: Icon(Icons.file_open),
                title: Text(Language.instance.OPEN_FILE_OR_URL),
              ),
            ),
            PopupMenuItem(
              value: 1,
              child: ListTile(
                leading: Icon(Icons.code),
                title: Text(Language.instance.READ_METADATA),
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: ListTile(
                leading: Icon(Icons.waves),
                title: Text(Language.instance.STREAM),
              ),
            ),
            PopupMenuItem(
              value: 3,
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text(Language.instance.SETTING),
              ),
            ),
            PopupMenuItem(
              value: 4,
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text(Language.instance.ABOUT_TITLE),
              ),
            ),
          ],
        ).then((value) async {
          // Prevent visual glitches when pushing a new route into the view.
          await Future.delayed(const Duration(milliseconds: 300));
          switch (value) {
            case 0:
              {
                await showDialog(
                  context: context,
                  builder: (ctx) => SimpleDialog(
                    title: Text(
                      Language.instance.OPEN_FILE_OR_URL,
                    ),
                    children: [
                      ListTile(
                        onTap: () async {
                          final file = await pickFile(
                            label: Language.instance.MEDIA_FILES,
                            extensions: kSupportedFileTypes,
                          );
                          if (file != null) {
                            await Navigator.of(ctx).maybePop();
                            await Intent.instance.playURI(file.uri.toString());
                          }
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(ctx).iconTheme.color,
                          child: Icon(
                            Icons.folder,
                          ),
                        ),
                        title: Text(
                          Language.instance.FILE,
                          style: isDesktop
                              ? Theme.of(ctx).textTheme.headlineMedium
                              : Theme.of(ctx).textTheme.displaySmall?.copyWith(
                                    fontSize: 16.0,
                                  ),
                        ),
                      ),
                      ListTile(
                        onTap: () async {
                          await Navigator.of(ctx).maybePop();
                          String input = '';
                          final GlobalKey<FormState> formKey =
                              GlobalKey<FormState>();
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            elevation: kDefaultHeavyElevation,
                            useRootNavigator: true,
                            builder: (context) => StatefulBuilder(
                              builder: (context, setState) {
                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom -
                                        MediaQuery.of(context).padding.bottom,
                                  ),
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 4.0),
                                      Form(
                                        key: formKey,
                                        child: TextFormField(
                                          autofocus: true,
                                          autocorrect: false,
                                          validator: (value) {
                                            final parser = URIParser(value);
                                            if (!parser.validate()) {
                                              debugPrint(value);
                                              // Empty [String] prevents the message from showing & does not distort the UI.
                                              return '';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) => input = value,
                                          keyboardType: TextInputType.url,
                                          textCapitalization:
                                              TextCapitalization.none,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (value) async {
                                            if (formKey.currentState
                                                    ?.validate() ??
                                                false) {
                                              await Navigator.of(context)
                                                  .maybePop();
                                              await Intent.instance
                                                  .playURI(value);
                                            }
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(
                                              12,
                                              30,
                                              12,
                                              6,
                                            ),
                                            hintText: Language
                                                .instance.FILE_PATH_OR_URL,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color!
                                                    .withOpacity(0.4),
                                                width: 1.8,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color!
                                                    .withOpacity(0.4),
                                                width: 1.8,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 1.8,
                                              ),
                                            ),
                                            errorStyle: TextStyle(height: 0.0),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            await Navigator.of(context)
                                                .maybePop();
                                            await Intent.instance
                                                .playURI(input);
                                          }
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                            Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        child: Text(
                                          Language.instance.PLAY.toUpperCase(),
                                          style: const TextStyle(
                                            letterSpacing: 2.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(ctx).iconTheme.color,
                          child: Icon(
                            Icons.link,
                          ),
                        ),
                        title: Text(
                          Language.instance.URL,
                          style: isDesktop
                              ? Theme.of(ctx).textTheme.headlineMedium
                              : Theme.of(ctx).textTheme.displaySmall?.copyWith(
                                    fontSize: 16.0,
                                  ),
                        ),
                      ),
                    ],
                  ),
                );
                break;
              }
            case 1:
              {
                await FileInfoScreen.show(context);
                break;
              }
            case 2:
              {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: WebTab(),
                    ),
                  ),
                );
                break;
              }
            case 3:
              {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: SettingsModern(),
                    ),
                  ),
                );
                break;
              }
            case 4:
              {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: AboutPage(),
                    ),
                  ),
                );
                break;
              }
          }
        });
      },
    );
  }
}

class SettingsCardsModern extends StatelessWidget {
  const SettingsCardsModern({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(12.0),
      // padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(
            20 * Configuration.instance.borderRadiusMultiplier),
      ),
      child: child,
    );
  }
}

class CustomSwitchListTileModern extends StatefulWidget {
  final bool value;
  final void Function(bool) onChanged;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? svgIconPath;
  final Color? passedColor;
  CustomSwitchListTileModern({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.icon,
    this.svgIconPath,
    this.passedColor,
  }) : super(key: key);

  @override
  State<CustomSwitchListTileModern> createState() =>
      _CustomSwitchListTileModernState();
}

class _CustomSwitchListTileModernState
    extends State<CustomSwitchListTileModern> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.white.withAlpha(10),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              20 * Configuration.instance.borderRadiusMultiplier),
        ),
        onTap: () {
          widget.onChanged(widget.value);
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        horizontalTitleGap: 0.0,
        minVerticalPadding: 8.0,
        leading: widget.svgIconPath != null
            ? Container(
                height: double.infinity,
                child: SvgPicture.asset(
                  widget.svgIconPath!,
                  color: widget.passedColor,
                ),
              )
            : widget.icon != null
                ? Container(
                    height: double.infinity,
                    child: Icon(
                      widget.icon,
                      color: widget.passedColor,
                    ),
                  )
                : null,
        title: Text(
          widget.title,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : Theme.of(context).textTheme.displayMedium,
          maxLines: widget.subtitle != null ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: widget.subtitle != null
            ? Text(
                widget.subtitle!,
                style: Theme.of(context).textTheme.displaySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: FittedBox(
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: widget.passedColor ??
                  Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: widget.value
                  ? [
                      BoxShadow(
                          offset: Offset(0, 2),
                          blurRadius: 8,
                          spreadRadius: 0,
                          color: widget.passedColor ?? Colors.transparent)
                    ]
                  : null,
            ),
            duration: Duration(milliseconds: 400),
            child: FlutterSwitch(
              activeColor: Colors.transparent,
              toggleColor: Color.fromARGB(222, 255, 255, 255),
              inactiveColor: Theme.of(context).disabledColor,
              duration: Duration(milliseconds: 400),
              borderRadius: 30.0,
              padding: 4.0,
              width: 40,
              height: 21,
              toggleSize: 14,
              value: widget.value,
              onToggle: (value) {
                setState(() {
                  widget.onChanged(value);
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CustomListTileModern extends StatelessWidget {
  final void Function()? onTap;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;
  final String? svgIconPath;
  final Color? passedColor;
  CustomListTileModern({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.icon,
    this.svgIconPath,
    this.passedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.white.withAlpha(10),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              20 * Configuration.instance.borderRadiusMultiplier),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        horizontalTitleGap: 0.0,
        minVerticalPadding: 8.0,
        leading: svgIconPath != null
            ? Container(
                height: double.infinity,
                child: SvgPicture.asset(
                  svgIconPath!,
                  color: passedColor,
                ),
              )
            : icon != null
                ? Container(
                    height: double.infinity,
                    child: Icon(
                      icon,
                      color: passedColor,
                    ),
                  )
                : null,
        title: Text(
          title,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : Theme.of(context).textTheme.displayMedium,
          maxLines: subtitle != null ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.displaySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: FittedBox(
          child: AnimatedContainer(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            duration: Duration(milliseconds: 400),
            child: trailing,
          ),
        ),
      ),
    );
  }
}

class AnimatingBackgroundModern extends StatefulWidget {
  final Widget child;
  final Color currentColor;
  final List<Color> currentColorsList;

  const AnimatingBackgroundModern(
      {super.key,
      required this.child,
      required this.currentColor,
      required this.currentColorsList});
  @override
  _AnimatingBackgroundModernState createState() =>
      _AnimatingBackgroundModernState();
}

class _AnimatingBackgroundModernState extends State<AnimatingBackgroundModern>
    with TickerProviderStateMixin {
  late List<Color> colorList;
  List<Alignment> alignmentList = [Alignment.topCenter, Alignment.bottomCenter];
  int index = 0;
  late Color bottomColor;
  late Color topColor;

  @override
  void initState() {
    super.initState();
    setState(() {
      bottomColor = widget.currentColor.withAlpha(150);
      topColor = widget.currentColor.withAlpha(200);
    });
    Timer(
      Duration(microseconds: 0),
      () {
        setState(
          () {
            bottomColor = Color(0xff33267C);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    colorList = [
      widget.currentColor.withAlpha(25),
      widget.currentColor.withAlpha(50),
    ];
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      onEnd: () {
        setState(
          () {
            index = index + 1;
            bottomColor = colorList[index % colorList.length];
            topColor = colorList[(index + 1) % colorList.length];
          },
        );
      },
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bottomColor, topColor],
        ),
      ),
      child: widget.child,
    );
  }
}

class AnimatedSwitchModern extends StatefulWidget {
  final bool isChecked;
  final Color? passedColor;

  const AnimatedSwitchModern(
      {super.key, required this.isChecked, this.passedColor});
  @override
  _AnimatedSwitchModernState createState() => _AnimatedSwitchModernState();
}

class _AnimatedSwitchModernState extends State<AnimatedSwitchModern>
    with TickerProviderStateMixin {
  late bool isChecked;
  Duration _duration = Duration(milliseconds: 370);
  late Animation<Alignment> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    isChecked = widget.isChecked;
    _animationController =
        AnimationController(vsync: this, duration: _duration);
    _animation =
        AlignmentTween(begin: Alignment.centerLeft, end: Alignment.centerRight)
            .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Center(
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              setState(
                () {
                  if (_animationController.isCompleted) {
                    _animationController.reverse();
                  } else {
                    _animationController.forward();
                  }
                  isChecked = !isChecked;
                },
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 10,
              height: MediaQuery.of(context).size.width / 17,
              padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
              decoration: BoxDecoration(
                color: isChecked ? Colors.green : Colors.red,
                borderRadius: BorderRadius.all(
                  Radius.circular(99),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isChecked
                        ? Colors.green.withOpacity(0.6)
                        : Colors.red.withOpacity(0.6),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: _animation.value,
                    child: GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            if (_animationController.isCompleted) {
                              _animationController.reverse();
                            } else {
                              _animationController.forward();
                            }
                            isChecked = !isChecked;
                          },
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 17,
                        height: MediaQuery.of(context).size.width / 17,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
