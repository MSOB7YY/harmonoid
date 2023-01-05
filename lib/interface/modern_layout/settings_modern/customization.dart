/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:ui';

import 'package:drop_shadow/drop_shadow.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/modern_layout/settings_modern/enable_new_layout.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/widgets_modern.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/modern_layout/settings_modern/track_tile_customization.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class CustomizationSetting extends StatefulWidget {
  final Color? currentTrackColor;
  CustomizationSetting({Key? key, this.currentTrackColor}) : super(key: key);
  CustomizationSettingState createState() => CustomizationSettingState();
}

class CustomizationSettingState extends State<CustomizationSetting> {
  late TextEditingController albumListTileHeightController;
  late TextEditingController albumThumbnailSizeinListController;
  late TextEditingController borderRadiusMultiplierController;
  late TextEditingController dateFormatChangerController;
  ScrollController _scrollController = ScrollController();
  String dateTimeFormatValue = Configuration.instance.dateTimeFormat;
  @override
  void initState() {
    super.initState();
    if (isMobile) {
      albumThumbnailSizeinListController = TextEditingController();
      albumListTileHeightController = TextEditingController();
      borderRadiusMultiplierController = TextEditingController();
      dateFormatChangerController = TextEditingController();
    }
  }

  @override
  void dispose() {
    if (isMobile) {
      albumThumbnailSizeinListController.dispose();
      albumListTileHeightController.dispose();
      borderRadiusMultiplierController.dispose();
      dateFormatChangerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Language.instance.CUSTOMIZATIONS,
      subtitle: Language.instance.CUSTOMIZATIONS_SUBTITLE.replaceAll('\n', ' '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (isMobile)
            Container(
              padding: const EdgeInsets.only(left: 16.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                Language.instance.CUSTOMIZATIONS_SUBTITLE,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(height: 1.2),
              ),
            ),
          CustomSwitchListTileModern(
            passedColor: widget.currentTrackColor,
            svgIconPath: "assets/modern_icons/3d-cube-scan.svg",
            title:
                "${Language.instance.USE_MODERN_LAYOUT} (${Language.instance.REQUIRES_APP_RESTART})",
            subtitle: Language.instance.USE_MODERN_LAYOUT_SUBTITLE,
            onChanged: (_) => Configuration.instance
                .save(
                  isModernLayout: !Configuration.instance.isModernLayout,
                )
                .then((value) => setState(() {})),
            value: Configuration.instance.isModernLayout,
          ),
          // Sticky Miniplayer
          if (isMobile)
            CustomSwitchListTileModern(
              passedColor: widget.currentTrackColor,
              svgIconPath: "assets/modern_icons/arrow-right-3.svg",
              title: Language.instance.STICKY_MINIPLAYER,
              subtitle: Language.instance.STICKY_MINIPLAYER_SUBTITLE,
              onChanged: (_) => Configuration.instance
                  .save(
                stickyMiniplayer: !Configuration.instance.stickyMiniplayer,
              )
                  .then((_) {
                setState(() {});
              }),
              value: Configuration.instance.stickyMiniplayer,
            ),
          CustomSwitchListTileModern(
            passedColor: widget.currentTrackColor,
            svgIconPath: "assets/modern_icons/smallcaps.svg",
            title: Language.instance.DISPLAY_AUDIO_FORMAT,
            onChanged: (_) => Configuration.instance
                .save(
              displayAudioFormat: !Configuration.instance.displayAudioFormat,
            )
                .then((_) {
              setState(() {});
            }),
            value: Configuration.instance.displayAudioFormat,
          ),

          // Album Thumbnail Size in List
          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: ListTile(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0))),
                          content: Container(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: albumThumbnailSizeinListController,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1.0),
                                ),
                                hintText: Language.instance.VALUE,
                              ),
                            ),
                          ),
                          actions: [
                            IconButton(
                                tooltip: Language.instance.RESTORE_DEFAULTS,
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                  setState(() {
                                    Configuration.instance.save(
                                      albumThumbnailSizeinList: 90,
                                    );
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    content: Text(
                                      '${Language.instance.SIZE_OF_ALBUM_THUMBNAIL_RESET_TO_DEFAULT} ${Configuration.instance.albumThumbnailSizeinList.toInt()}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ));
                                },
                                icon: Icon(Icons.restore_rounded)),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).disabledColor)),
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                },
                                child: Text(Language.instance.CANCEL)),
                            ElevatedButton(
                                onPressed: () {
                                  Configuration.instance.save(
                                    albumThumbnailSizeinList: double.parse(
                                        albumThumbnailSizeinListController
                                            .text),
                                  );
                                  Navigator.of(context).maybePop();
                                },
                                child: Text(Language.instance.OK))
                          ],
                        );
                      },
                    );
                  },
                  leading: Text(
                    Language.instance.ALBUM_THUMBNAIL_SIZE_IN_LIST,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                  trailing: Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      "${Configuration.instance.albumThumbnailSizeinList.toInt()}",
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(color: Colors.grey[500]),
                    ),
                  ),
                ),
              ),
            ),

          // Album Tile Height
          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: ListTile(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0))),
                          content: Container(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: albumListTileHeightController,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1.0),
                                ),
                                hintText: Language.instance.VALUE,
                              ),
                            ),
                          ),
                          actions: [
                            IconButton(
                                tooltip: Language.instance.RESTORE_DEFAULTS,
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                  setState(() {
                                    Configuration.instance.save(
                                      albumListTileHeight: 90,
                                    );
                                  });
                                  setState(() {});
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    content: Text(
                                      '${Language.instance.ALBUM_TILE_HEIGHT_RESET_TO_DEFAULT} ${Configuration.instance.albumListTileHeight.toInt()}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ));
                                },
                                icon: Icon(Icons.restore_rounded)),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).disabledColor)),
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                },
                                child: Text(Language.instance.CANCEL)),
                            ElevatedButton(
                                onPressed: () {
                                  Configuration.instance.save(
                                    albumListTileHeight: double.parse(
                                        albumListTileHeightController.text),
                                  );

                                  Navigator.of(context).maybePop();
                                },
                                child: Text(Language.instance.OK))
                          ],
                        );
                      },
                    );
                  },
                  leading: Text(
                    Language.instance.HEIGHT_OF_ALBUM_TILE,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                  trailing: Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      "${Configuration.instance.albumListTileHeight.toInt()}",
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(color: Colors.grey[500]),
                    ),
                  ),
                ),
              ),
            ),

          // Track Number in a small Box
          // Should be available only with the new style
          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: CustomSwitchListTileModern(
                  passedColor: widget.currentTrackColor,
                  svgIconPath: "assets/modern_icons/card-remove.svg",
                  title: Language.instance.DISPLAY_TRACK_NUMBER_IN_ALBUM_PAGE,
                  subtitle: Language
                      .instance.DISPLAY_TRACK_NUMBER_IN_ALBUM_PAGE_SUBTITLE,
                  onChanged: (_) => Configuration.instance
                      .save(
                    displayTrackNumberinAlbumPage:
                        !Configuration.instance.displayTrackNumberinAlbumPage,
                  )
                      .then((_) {
                    setState(() {});
                  }),
                  value: Configuration.instance.displayTrackNumberinAlbumPage,
                ),
              ),
            ),
          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: CustomSwitchListTileModern(
                  passedColor: widget.currentTrackColor,
                  svgIconPath: "assets/modern_icons/notification-status.svg",
                  title: Language.instance.DISPLAY_ALBUM_CARD_TOP_RIGHT_DATE,
                  subtitle: Language
                      .instance.DISPLAY_ALBUM_CARD_TOP_RIGHT_DATE_SUBTITLE,
                  onChanged: (_) => Configuration.instance
                      .save(
                    albumCardTopRightDate:
                        !Configuration.instance.albumCardTopRightDate,
                  )
                      .then((_) {
                    setState(() {});
                  }),
                  value: Configuration.instance.albumCardTopRightDate,
                ),
              ),
            ),

          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: CustomSwitchListTileModern(
                  passedColor: widget.currentTrackColor,
                  svgIconPath: "assets/modern_icons/crop.svg",
                  title: Language.instance.FORCE_SQUARED_ALBUM_THUMBNAIL,
                  onChanged: (_) => Configuration.instance
                      .save(
                    forceSquaredAlbumThumbnail:
                        !Configuration.instance.forceSquaredAlbumThumbnail,
                  )
                      .then((_) {
                    setState(() {});
                  }),
                  value: Configuration.instance.forceSquaredAlbumThumbnail,
                ),
              ),
            ),
          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: CustomSwitchListTileModern(
                  passedColor: widget.currentTrackColor,
                  svgIconPath: "assets/modern_icons/element-4.svg",
                  title: Language.instance.STAGGERED_ALBUM_GRID_VIEW,
                  onChanged: (_) => Configuration.instance
                      .save(
                    useAlbumStaggeredGridView:
                        !Configuration.instance.useAlbumStaggeredGridView,
                  )
                      .then((_) {
                    setState(() {});
                  }),
                  value: Configuration.instance.useAlbumStaggeredGridView,
                ),
              ),
            ),
          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: CustomSwitchListTileModern(
                  passedColor: widget.currentTrackColor,
                  svgIconPath: "assets/modern_icons/drop.svg",
                  title: Language.instance.ENABLE_BLUR_EFFECT,
                  onChanged: (_) => Configuration.instance
                      .save(
                    enableBlurEffect: !Configuration.instance.enableBlurEffect,
                  )
                      .then((_) {
                    setState(() {});
                  }),
                  value: Configuration.instance.enableBlurEffect,
                ),
              ),
            ),
          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: CustomSwitchListTileModern(
                  passedColor: widget.currentTrackColor,
                  svgIconPath: "assets/modern_icons/sun-1.svg",
                  title: Language.instance.ENABLE_GLOW_EFFECT,
                  onChanged: (_) => Configuration.instance
                      .save(
                    enableGlowEffect: !Configuration.instance.enableGlowEffect,
                  )
                      .then((_) {
                    setState(() {});
                  }),
                  value: Configuration.instance.enableGlowEffect,
                ),
              ),
            ),
          if (isMobile)
            CustomSwitchListTileModern(
              passedColor: widget.currentTrackColor,
              svgIconPath: "assets/modern_icons/volume-high.svg",
              title: Language.instance.MOBILE_ENABLE_VOLUME_SLIDER,
              onChanged: (_) => Configuration.instance
                  .save(
                mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen:
                    !Configuration.instance
                        .mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen,
              )
                  .then((_) {
                setState(() {});
              }),
              value: Configuration
                  .instance.mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen,
            ),

          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: ListTile(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0))),
                          content: Container(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: borderRadiusMultiplierController,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1.0),
                                ),
                                hintText: Language.instance.VALUE,
                              ),
                            ),
                          ),
                          actions: [
                            IconButton(
                                tooltip: Language.instance.RESTORE_DEFAULTS,
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                  setState(() {
                                    Configuration.instance.save(
                                      borderRadiusMultiplier: 1.0,
                                    );
                                  });
                                  setState(() {});
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    content: Text(
                                      '${Language.instance.BORDER_RADIUS_MULTIPLIER_RESET_TO_DEFAULT} ${Configuration.instance.borderRadiusMultiplier}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ));
                                },
                                icon: Icon(Icons.restore_rounded)),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).disabledColor)),
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                },
                                child: Text(Language.instance.CANCEL)),
                            ElevatedButton(
                                onPressed: () {
                                  Configuration.instance.save(
                                    borderRadiusMultiplier: double.parse(
                                        borderRadiusMultiplierController.text),
                                  );

                                  Navigator.of(context).maybePop();
                                },
                                child: Text(Language.instance.OK))
                          ],
                        );
                      },
                    );
                  },
                  leading: Text(
                    Language.instance.BORDER_RADIUS_MULTIPLIER,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                  trailing: Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      "${Configuration.instance.borderRadiusMultiplier}",
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(color: Colors.grey[500]),
                    ),
                  ),
                ),
              ),
            ),

          // Date Format Changer
          // must be used with both layouts (pls change as following)
          // decleration:
          // final formatDate = DateFormat(Configuration.instance.dateTimeFormat);
          // usage:
          // Text('${formatDate.format(DateTime.parse(widget.album.year))}')
          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: ListTile(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0))),
                          content: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: kDefaultDateTimeStrings.entries
                                      .map(
                                        (e) => RadioListTile<String>(
                                          groupValue: dateTimeFormatValue,
                                          value: e.key,
                                          onChanged: (e) async {
                                            if (e != null) {
                                              setState(() =>
                                                  dateTimeFormatValue = e);
                                              Navigator.of(context).maybePop();

                                              await Configuration.instance.save(
                                                dateTimeFormat:
                                                    dateTimeFormatValue,
                                              );
                                              setState(() {});
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500));
                                            }
                                          },
                                          title: Text(
                                            '${e.value}',
                                            style: isDesktop
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                : null,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                TextField(
                                  controller: dateFormatChangerController,
                                  textAlign: TextAlign.left,
                                  onTap: () {
                                    // just automatically scrolls to the end of list
                                    Future.delayed(Duration(milliseconds: 500),
                                        () {
                                      _scrollController.animateTo(
                                          _scrollController
                                                  .position.viewportDimension *
                                              2,
                                          duration: Duration(milliseconds: 200),
                                          curve: Curves.ease);
                                    });
                                  },
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 1.0),
                                    ),
                                    hintText:
                                        "${Language.instance.OR.toUpperCase()} ${Language.instance.ENTER_YOUR_OWN_FORMAT_HERE}",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            IconButton(
                                tooltip: Language.instance.RESTORE_DEFAULTS,
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                  setState(() {
                                    Configuration.instance.save(
                                      dateTimeFormat: 'MMM yyyy',
                                    );
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    content: Text(
                                      '${Language.instance.DATE_TIME_FORMAT_RESET_TO_DEFAULT} ${Configuration.instance.dateTimeFormat}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ));
                                },
                                icon: Icon(Icons.restore_rounded)),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).disabledColor)),
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                },
                                child: Text(Language.instance.CANCEL)),
                            ElevatedButton(
                                onPressed: () {
                                  Configuration.instance.save(
                                    dateTimeFormat:
                                        dateFormatChangerController.text,
                                  );

                                  Navigator.of(context).maybePop();
                                },
                                child: Text(Language.instance.OK))
                          ],
                        );
                      },
                    );
                  },
                  leading: Text(
                    Language.instance.DATE_TIME_FORMAT,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                  trailing: Text(
                    "${Configuration.instance.dateTimeFormat}",
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(color: Colors.grey[500]),
                  ),
                ),
              ),
            ),

          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: CustomSwitchListTileModern(
                  passedColor: widget.currentTrackColor,
                  svgIconPath: "assets/modern_icons/clock.svg",
                  title: Language.instance.HOUR_FORMAT_12,
                  onChanged: (_) => Configuration.instance
                      .save(
                        hourFormat12: !Configuration.instance.hourFormat12,
                      )
                      .then((value) => setState(() {})),
                  value: Configuration.instance.hourFormat12,
                ),
              ),
            ),
          // Full track tile info Editor
          AbsorbPointer(
            absorbing: Configuration.instance.isModernLayout ? false : true,
            child: Opacity(
              opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
              child: TrackTileCustomization(
                  currentTrackColor: widget.currentTrackColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Default values available for setting the Date Time Format.
const kDefaultDateTimeStrings = {
  'yyyyMMdd': '20220413',
  'dd/MM/yyyy': '13/04/2022',
  'MM/dd/yyyy': '04/13/2022',
  'yyyy/MM/dd': '2022/04/13',
  'yyyy/dd/MM': '2022/13/04',
  'dd-MM-yyyy': '13-04-2022',
  'MM-dd-yyyy': '04-13-2022',
  'MMMM dd, yyyy': 'April 13, 2022',
  'MMM dd, yyyy': 'Apr 13, 2022',
};
