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
import 'package:flutter_svg/flutter_svg.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/widgets_modern.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class TrackTileCustomization extends StatelessWidget {
  final Color? currentTrackColor;
  TrackTileCustomization({super.key, this.currentTrackColor});
  late final TextEditingController trackTileSeparatorController =
      TextEditingController();
  late final TextEditingController trackThumbnailSizeinListController =
      TextEditingController();
  late final TextEditingController trackListTileHeightController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomListTileModern(
        passedColor: currentTrackColor,
        title: Language.instance.TRACK_TILE_CUSTOMIZATION,
        trailing: SvgPicture.asset(
          "assets/modern_icons/arrow-right-3.svg",
          color: currentTrackColor,
        ),
        svgIconPath: "assets/modern_icons/brush.svg",
        onTap: () async {
          await showDialog(
              context: context,
              builder: (context) {
                return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                    child: StatefulBuilder(builder: (context, setState) {
                      return Dialog(
                          clipBehavior: Clip.antiAlias,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Color.fromARGB(255, 253, 253, 253)
                                  : Color.fromARGB(255, 11, 11, 11),
                          insetPadding: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(
                                  16.0 *
                                      Configuration
                                          .instance.borderRadiusMultiplier))),
                          child: SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isMobile)
                                    AbsorbPointer(
                                      absorbing:
                                          Configuration.instance.isModernLayout
                                              ? false
                                              : true,
                                      child: Opacity(
                                        opacity: Configuration
                                                .instance.isModernLayout
                                            ? 1.0
                                            : 0.7,
                                        child: CorrectedSwitchListTile(
                                          title: Language.instance
                                              .FORCE_SQUARED_TRACK_THUMBNAIL,
                                          subtitle: Language.instance
                                              .FORCE_SQUARED_TRACK_THUMBNAIL,
                                          onChanged: (_) =>
                                              Configuration.instance
                                                  .save(
                                            forceSquaredTrackThumbnail:
                                                !Configuration.instance
                                                    .forceSquaredTrackThumbnail,
                                          )
                                                  .then((_) {
                                            setState(() {});
                                          }),
                                          value: Configuration.instance
                                              .forceSquaredTrackThumbnail,
                                        ),
                                      ),
                                    ),
                                  // Track Thumbnail Size in List
                                  if (isMobile)
                                    AbsorbPointer(
                                      absorbing:
                                          Configuration.instance.isModernLayout
                                              ? false
                                              : true,
                                      child: Opacity(
                                        opacity: Configuration
                                                .instance.isModernLayout
                                            ? 1.0
                                            : 0.7,
                                        child: ListTile(
                                          onTap: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12.0))),
                                                  content: Container(
                                                    width: 100,
                                                    child: TextField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller:
                                                          trackThumbnailSizeinListController,
                                                      textAlign: TextAlign.left,
                                                      decoration:
                                                          InputDecoration(
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              width: 2.0),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              width: 1.0),
                                                        ),
                                                        hintText: Language
                                                            .instance.VALUE,
                                                      ),
                                                    ),
                                                  ),
                                                  actions: [
                                                    IconButton(
                                                        tooltip: Language
                                                            .instance
                                                            .RESTORE_DEFAULTS,
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .maybePop();
                                                          setState(() {
                                                            Configuration
                                                                .instance
                                                                .save(
                                                              trackThumbnailSizeinList:
                                                                  75,
                                                            );
                                                          });
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            backgroundColor: Theme
                                                                    .of(context)
                                                                .scaffoldBackgroundColor,
                                                            content: Text(
                                                              '${Language.instance.SIZE_OF_TRACK_THUMBNAIL_RESET_TO_DEFAULT} ${Configuration.instance.trackThumbnailSizeinList.toInt()}',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                            ),
                                                          ));
                                                        },
                                                        icon: Icon(Icons
                                                            .restore_rounded)),
                                                    ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(Theme.of(
                                                                            context)
                                                                        .disabledColor)),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .maybePop();
                                                        },
                                                        child: Text(Language
                                                            .instance.CANCEL)),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Configuration.instance
                                                              .save(
                                                            trackThumbnailSizeinList:
                                                                double.parse(
                                                                    trackThumbnailSizeinListController
                                                                        .text),
                                                          );
                                                          Navigator.of(context)
                                                              .maybePop();
                                                        },
                                                        child: Text(Language
                                                            .instance.OK))
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          leading: Text(
                                            Language.instance
                                                .TRACK_THUMBNAIL_SIZE_IN_LIST,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black),
                                          ),
                                          trailing: Container(
                                            width: 60,
                                            alignment: Alignment.center,
                                            child: Text(
                                              "${Configuration.instance.trackThumbnailSizeinList.toInt()}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      color: Colors.grey[500]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Track Tile Height
                                  if (isMobile)
                                    AbsorbPointer(
                                      absorbing:
                                          Configuration.instance.isModernLayout
                                              ? false
                                              : true,
                                      child: Opacity(
                                        opacity: Configuration
                                                .instance.isModernLayout
                                            ? 1.0
                                            : 0.7,
                                        child: ListTile(
                                          onTap: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12.0))),
                                                  content: Container(
                                                    width: 100,
                                                    child: TextField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller:
                                                          trackListTileHeightController,
                                                      textAlign: TextAlign.left,
                                                      decoration:
                                                          InputDecoration(
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              width: 2.0),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              width: 1.0),
                                                        ),
                                                        hintText: Language
                                                            .instance.VALUE,
                                                      ),
                                                    ),
                                                  ),
                                                  actions: [
                                                    IconButton(
                                                        tooltip: Language
                                                            .instance
                                                            .RESTORE_DEFAULTS,
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .maybePop();
                                                          setState(() {
                                                            Configuration
                                                                .instance
                                                                .save(
                                                              trackListTileHeight:
                                                                  75,
                                                            );
                                                          });
                                                          setState(() {});
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            backgroundColor: Theme
                                                                    .of(context)
                                                                .scaffoldBackgroundColor,
                                                            content: Text(
                                                              '${Language.instance.TRACK_TILE_HEIGHT_RESET_TO_DEFAULT} ${Configuration.instance.trackListTileHeight.toInt()}',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                            ),
                                                          ));
                                                        },
                                                        icon: Icon(Icons
                                                            .restore_rounded)),
                                                    ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(Theme.of(
                                                                            context)
                                                                        .disabledColor)),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .maybePop();
                                                        },
                                                        child: Text(Language
                                                            .instance.CANCEL)),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Configuration.instance
                                                              .save(
                                                            trackListTileHeight:
                                                                double.parse(
                                                                    trackListTileHeightController
                                                                        .text),
                                                          );

                                                          Navigator.of(context)
                                                              .maybePop();
                                                        },
                                                        child: Text(Language
                                                            .instance.OK))
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          leading: Text(
                                            Language
                                                .instance.HEIGHT_OF_TRACK_TILE,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black),
                                          ),
                                          trailing: Container(
                                            width: 60,
                                            alignment: Alignment.center,
                                            child: Text(
                                              "${Configuration.instance.trackListTileHeight.toInt()}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      color: Colors.grey[500]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  CorrectedSwitchListTile(
                                    title: Language.instance
                                        .DISPLAY_THIRD_ITEM_IN_ROW_IN_TRACK_TILE,
                                    subtitle: Language.instance
                                        .DISPLAY_THIRD_ITEM_IN_ROW_IN_TRACK_TILE,
                                    onChanged: (_) => Configuration.instance
                                        .save(
                                          trackTileDisplayThirdItemInRows:
                                              !Configuration.instance
                                                  .trackTileDisplayThirdItemInRows,
                                        )
                                        .then((value) => setState(() {})),
                                    value: Configuration.instance
                                        .trackTileDisplayThirdItemInRows,
                                  ),
                                  CorrectedSwitchListTile(
                                    title: Language.instance
                                        .DISPLAY_THIRD_ROW_IN_TRACK_TILE,
                                    subtitle: Language.instance
                                        .DISPLAY_THIRD_ROW_IN_TRACK_TILE,
                                    onChanged: (_) => Configuration.instance
                                        .save(
                                          trackTileDisplayThirdRow:
                                              !Configuration.instance
                                                  .trackTileDisplayThirdRow,
                                        )
                                        .then((value) => setState(() {})),
                                    value: Configuration
                                        .instance.trackTileDisplayThirdRow,
                                  ),
                                  ListTile(
                                    onTap: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12.0))),
                                            content: Container(
                                              width: 100,
                                              child: TextField(
                                                controller:
                                                    trackTileSeparatorController,
                                                textAlign: TextAlign.left,
                                                decoration: InputDecoration(
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        width: 2.0),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        width: 1.0),
                                                  ),
                                                  hintText:
                                                      Language.instance.VALUE,
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              IconButton(
                                                  tooltip: Language.instance
                                                      .RESTORE_DEFAULTS,
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .maybePop();
                                                    setState(() {
                                                      Configuration.instance
                                                          .save(
                                                        trackTileSeparator: "•",
                                                      );
                                                    });
                                                    setState(() {});
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      backgroundColor: Theme.of(
                                                              context)
                                                          .scaffoldBackgroundColor,
                                                      content: Text(
                                                        '${Language.instance.TRACK_TILE_ITEMS_SEPARATOR} ${Configuration.instance.trackTileSeparator}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium,
                                                      ),
                                                    ));
                                                  },
                                                  icon: Icon(
                                                      Icons.restore_rounded)),
                                              ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Theme.of(
                                                                      context)
                                                                  .disabledColor)),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .maybePop();
                                                  },
                                                  child: Text(Language
                                                      .instance.CANCEL)),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Configuration.instance.save(
                                                      trackTileSeparator:
                                                          trackTileSeparatorController
                                                              .text,
                                                    );

                                                    Navigator.of(context)
                                                        .maybePop();
                                                  },
                                                  child: Text(
                                                      Language.instance.OK))
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    leading: Text(
                                      Language
                                          .instance.TRACK_TILE_ITEMS_SEPARATOR,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black),
                                    ),
                                    trailing: Container(
                                      width: 60,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "${Configuration.instance.trackTileSeparator}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(color: Colors.grey[500]),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Color.fromARGB(255, 248, 248, 248)
                                        : Color.fromARGB(255, 18, 18, 18),
                                    width: MediaQuery.of(context).size.width,
                                    height: Configuration
                                            .instance.trackListTileHeight *
                                        1.4,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(bottom: 4.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        const SizedBox(width: 6.0),
                                        SizedBox(
                                          width: Configuration.instance
                                              .trackThumbnailSizeinList,
                                          height: Configuration.instance
                                              .trackThumbnailSizeinList,
                                          child: Center(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12 *
                                                      Configuration.instance
                                                          .borderRadiusMultiplier),
                                              child: DropShadow(
                                                borderRadius: 8 *
                                                    Configuration.instance
                                                        .borderRadiusMultiplier,
                                                blurRadius: 2,
                                                spread: 1,
                                                offset: Offset(0, 1),
                                                child: ExtendedImage(
                                                  image: Image(
                                                    image: AssetImage(
                                                        "assets/images/default_album_art.png"),
                                                    height: 10,
                                                  ).image,
                                                  fit: BoxFit.cover,
                                                  width: Configuration.instance
                                                          .forceSquaredTrackThumbnail
                                                      ? MediaQuery.of(context)
                                                          .size
                                                          .width
                                                      : null,
                                                  height: Configuration.instance
                                                          .forceSquaredTrackThumbnail
                                                      ? MediaQuery.of(context)
                                                          .size
                                                          .width
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6.0),
                                        Flexible(
                                          flex: 15,
                                          child: FittedBox(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                FittedBox(
                                                  child: Row(
                                                    children: [
                                                      FittedBox(
                                                        child: TextButton(
                                                          style: ButtonStyle(
                                                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(8 *
                                                                      Configuration
                                                                          .instance
                                                                          .borderRadiusMultiplier))),
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all(Theme.of(
                                                                              context)
                                                                          .cardColor)),
                                                          onPressed: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialogueWithRadioList(
                                                                      context:
                                                                          context,
                                                                      valueToBeChanged: Configuration
                                                                          .instance
                                                                          .trackTileFirstRowFirstItem,
                                                                      functionToSaveTheValue:
                                                                          (e) async {
                                                                        if (e !=
                                                                            null) {
                                                                          setState(() => Configuration
                                                                              .instance
                                                                              .trackTileFirstRowFirstItem = e);

                                                                          await Configuration
                                                                              .instance
                                                                              .save(
                                                                            trackTileFirstRowFirstItem:
                                                                                Configuration.instance.trackTileFirstRowFirstItem,
                                                                          );
                                                                          Navigator.of(context, rootNavigator: true)
                                                                              .maybePop();
                                                                          setState(
                                                                              () {});
                                                                          await Future.delayed(
                                                                              const Duration(milliseconds: 500));
                                                                        }
                                                                      });
                                                                });
                                                          },
                                                          child: Text(
                                                            "${Configuration.instance.trackTileFirstRowFirstItem}",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayMedium,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 6.0),
                                                      Text(
                                                        "${Configuration.instance.trackTileSeparator}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displaySmall,
                                                      ),
                                                      SizedBox(width: 6.0),
                                                      FittedBox(
                                                        child: TextButton(
                                                          style: ButtonStyle(
                                                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(8 *
                                                                      Configuration
                                                                          .instance
                                                                          .borderRadiusMultiplier))),
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all(Theme.of(
                                                                              context)
                                                                          .cardColor)),
                                                          onPressed: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialogueWithRadioList(
                                                                      context:
                                                                          context,
                                                                      valueToBeChanged: Configuration
                                                                          .instance
                                                                          .trackTileFirstRowSecondItem,
                                                                      functionToSaveTheValue:
                                                                          (e) async {
                                                                        if (e !=
                                                                            null) {
                                                                          setState(() => Configuration
                                                                              .instance
                                                                              .trackTileFirstRowSecondItem = e);

                                                                          await Configuration
                                                                              .instance
                                                                              .save(
                                                                            trackTileFirstRowSecondItem:
                                                                                Configuration.instance.trackTileFirstRowSecondItem,
                                                                          );
                                                                          Navigator.of(context, rootNavigator: true)
                                                                              .maybePop();
                                                                          setState(
                                                                              () {});
                                                                          await Future.delayed(
                                                                              const Duration(milliseconds: 500));
                                                                        }
                                                                      });
                                                                });
                                                          },
                                                          child: Text(
                                                            "${Configuration.instance.trackTileFirstRowSecondItem}",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayMedium,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 6.0),
                                                      if (Configuration.instance
                                                          .trackTileDisplayThirdItemInRows) ...[
                                                        Text(
                                                          "${Configuration.instance.trackTileSeparator}",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .displaySmall,
                                                        ),
                                                        SizedBox(width: 6.0),
                                                        FittedBox(
                                                          child: TextButton(
                                                            style: ButtonStyle(
                                                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8 *
                                                                        Configuration
                                                                            .instance
                                                                            .borderRadiusMultiplier))),
                                                                backgroundColor:
                                                                    MaterialStateProperty.all(
                                                                        Theme.of(context)
                                                                            .cardColor)),
                                                            onPressed: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialogueWithRadioList(
                                                                        context:
                                                                            context,
                                                                        valueToBeChanged: Configuration
                                                                            .instance
                                                                            .trackTileFirstRowThirdItem,
                                                                        functionToSaveTheValue:
                                                                            (e) async {
                                                                          if (e !=
                                                                              null) {
                                                                            setState(() =>
                                                                                Configuration.instance.trackTileFirstRowThirdItem = e);

                                                                            await Configuration.instance.save(
                                                                              trackTileFirstRowThirdItem: Configuration.instance.trackTileFirstRowThirdItem,
                                                                            );
                                                                            Navigator.of(context, rootNavigator: true).maybePop();
                                                                            setState(() {});
                                                                            await Future.delayed(const Duration(milliseconds: 500));
                                                                          }
                                                                        });
                                                                  });
                                                            },
                                                            child: Text(
                                                              "${Configuration.instance.trackTileFirstRowThirdItem}",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .displayMedium,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                FittedBox(
                                                  child: Row(
                                                    children: [
                                                      FittedBox(
                                                        child: TextButton(
                                                          style: ButtonStyle(
                                                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(8 *
                                                                      Configuration
                                                                          .instance
                                                                          .borderRadiusMultiplier))),
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all(Theme.of(
                                                                              context)
                                                                          .cardColor)),
                                                          onPressed: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialogueWithRadioList(
                                                                      context:
                                                                          context,
                                                                      valueToBeChanged: Configuration
                                                                          .instance
                                                                          .trackTileSecondRowFirstItem,
                                                                      functionToSaveTheValue:
                                                                          (e) async {
                                                                        if (e !=
                                                                            null) {
                                                                          setState(() => Configuration
                                                                              .instance
                                                                              .trackTileSecondRowFirstItem = e);

                                                                          await Configuration
                                                                              .instance
                                                                              .save(
                                                                            trackTileSecondRowFirstItem:
                                                                                Configuration.instance.trackTileSecondRowFirstItem,
                                                                          );
                                                                          Navigator.of(context, rootNavigator: true)
                                                                              .maybePop();
                                                                          setState(
                                                                              () {});
                                                                          await Future.delayed(
                                                                              const Duration(milliseconds: 500));
                                                                        }
                                                                      });
                                                                });
                                                          },
                                                          child: Text(
                                                            "${Configuration.instance.trackTileSecondRowFirstItem}",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displaySmall,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 6.0),
                                                      Text(
                                                        "${Configuration.instance.trackTileSeparator}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displaySmall,
                                                      ),
                                                      SizedBox(width: 6.0),
                                                      FittedBox(
                                                        child: TextButton(
                                                          style: ButtonStyle(
                                                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(8 *
                                                                      Configuration
                                                                          .instance
                                                                          .borderRadiusMultiplier))),
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all(Theme.of(
                                                                              context)
                                                                          .cardColor)),
                                                          onPressed: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialogueWithRadioList(
                                                                      context:
                                                                          context,
                                                                      valueToBeChanged: Configuration
                                                                          .instance
                                                                          .trackTileSecondRowSecondItem,
                                                                      functionToSaveTheValue:
                                                                          (e) async {
                                                                        if (e !=
                                                                            null) {
                                                                          setState(() => Configuration
                                                                              .instance
                                                                              .trackTileSecondRowSecondItem = e);

                                                                          await Configuration
                                                                              .instance
                                                                              .save(
                                                                            trackTileSecondRowSecondItem:
                                                                                Configuration.instance.trackTileSecondRowSecondItem,
                                                                          );
                                                                          Navigator.of(context, rootNavigator: true)
                                                                              .maybePop();
                                                                          setState(
                                                                              () {});
                                                                          await Future.delayed(
                                                                              const Duration(milliseconds: 500));
                                                                        }
                                                                      });
                                                                });
                                                          },
                                                          child: Text(
                                                            "${Configuration.instance.trackTileSecondRowSecondItem}",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displaySmall,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 6.0),
                                                      if (Configuration.instance
                                                          .trackTileDisplayThirdItemInRows) ...[
                                                        Text(
                                                          "${Configuration.instance.trackTileSeparator}",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .displaySmall,
                                                        ),
                                                        SizedBox(width: 6.0),
                                                        FittedBox(
                                                          child: TextButton(
                                                            style: ButtonStyle(
                                                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8 *
                                                                        Configuration
                                                                            .instance
                                                                            .borderRadiusMultiplier))),
                                                                backgroundColor:
                                                                    MaterialStateProperty.all(
                                                                        Theme.of(context)
                                                                            .cardColor)),
                                                            onPressed: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialogueWithRadioList(
                                                                        context:
                                                                            context,
                                                                        valueToBeChanged: Configuration
                                                                            .instance
                                                                            .trackTileSecondRowThirdItem,
                                                                        functionToSaveTheValue:
                                                                            (e) async {
                                                                          if (e !=
                                                                              null) {
                                                                            setState(() =>
                                                                                Configuration.instance.trackTileSecondRowThirdItem = e);

                                                                            await Configuration.instance.save(
                                                                              trackTileSecondRowThirdItem: Configuration.instance.trackTileSecondRowThirdItem,
                                                                            );
                                                                            Navigator.of(context, rootNavigator: true).maybePop();
                                                                            setState(() {});
                                                                            await Future.delayed(const Duration(milliseconds: 500));
                                                                          }
                                                                        });
                                                                  });
                                                            },
                                                            child: Text(
                                                              "${Configuration.instance.trackTileSecondRowThirdItem}",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .displaySmall,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                if (Configuration.instance
                                                    .trackTileDisplayThirdRow)
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        FittedBox(
                                                          child: TextButton(
                                                            style: ButtonStyle(
                                                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8 *
                                                                        Configuration
                                                                            .instance
                                                                            .borderRadiusMultiplier))),
                                                                backgroundColor:
                                                                    MaterialStateProperty.all(
                                                                        Theme.of(context)
                                                                            .cardColor)),
                                                            onPressed: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialogueWithRadioList(
                                                                        context:
                                                                            context,
                                                                        valueToBeChanged: Configuration
                                                                            .instance
                                                                            .trackTileThirdRowFirstItem,
                                                                        functionToSaveTheValue:
                                                                            (e) async {
                                                                          if (e !=
                                                                              null) {
                                                                            setState(() =>
                                                                                Configuration.instance.trackTileThirdRowFirstItem = e);

                                                                            await Configuration.instance.save(
                                                                              trackTileThirdRowFirstItem: Configuration.instance.trackTileThirdRowFirstItem,
                                                                            );
                                                                            Navigator.of(context, rootNavigator: true).maybePop();
                                                                            setState(() {});
                                                                            await Future.delayed(const Duration(milliseconds: 500));
                                                                          }
                                                                        });
                                                                  });
                                                            },
                                                            child: Text(
                                                              "${Configuration.instance.trackTileThirdRowFirstItem}",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .displaySmall,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 6.0),
                                                        Text(
                                                          "${Configuration.instance.trackTileSeparator}",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .displaySmall,
                                                        ),
                                                        SizedBox(width: 6.0),
                                                        FittedBox(
                                                          child: TextButton(
                                                            style: ButtonStyle(
                                                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8 *
                                                                        Configuration
                                                                            .instance
                                                                            .borderRadiusMultiplier))),
                                                                backgroundColor:
                                                                    MaterialStateProperty.all(
                                                                        Theme.of(context)
                                                                            .cardColor)),
                                                            onPressed: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialogueWithRadioList(
                                                                        context:
                                                                            context,
                                                                        valueToBeChanged: Configuration
                                                                            .instance
                                                                            .trackTileThirdRowSecondItem,
                                                                        functionToSaveTheValue:
                                                                            (e) async {
                                                                          if (e !=
                                                                              null) {
                                                                            setState(() =>
                                                                                Configuration.instance.trackTileThirdRowSecondItem = e);

                                                                            await Configuration.instance.save(
                                                                              trackTileThirdRowSecondItem: Configuration.instance.trackTileThirdRowSecondItem,
                                                                            );
                                                                            Navigator.of(context, rootNavigator: true).maybePop();
                                                                            setState(() {});
                                                                            await Future.delayed(const Duration(milliseconds: 500));
                                                                          }
                                                                        });
                                                                  });
                                                            },
                                                            child: Text(
                                                              "${Configuration.instance.trackTileThirdRowSecondItem}",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .displaySmall,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 6.0),
                                                        if (Configuration
                                                            .instance
                                                            .trackTileDisplayThirdItemInRows) ...[
                                                          Text(
                                                            "${Configuration.instance.trackTileSeparator}",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displaySmall,
                                                          ),
                                                          SizedBox(width: 6.0),
                                                          FittedBox(
                                                            child: TextButton(
                                                              style: ButtonStyle(
                                                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(8 *
                                                                          Configuration
                                                                              .instance
                                                                              .borderRadiusMultiplier))),
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all(
                                                                          Theme.of(context)
                                                                              .cardColor)),
                                                              onPressed: () {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return AlertDialogueWithRadioList(
                                                                          context:
                                                                              context,
                                                                          valueToBeChanged: Configuration
                                                                              .instance
                                                                              .trackTileThirdRowThirdItem,
                                                                          functionToSaveTheValue:
                                                                              (e) async {
                                                                            if (e !=
                                                                                null) {
                                                                              setState(() => Configuration.instance.trackTileThirdRowThirdItem = e);

                                                                              await Configuration.instance.save(
                                                                                trackTileThirdRowThirdItem: Configuration.instance.trackTileThirdRowThirdItem,
                                                                              );
                                                                              Navigator.of(context, rootNavigator: true).maybePop();
                                                                              setState(() {});
                                                                              await Future.delayed(const Duration(milliseconds: 500));
                                                                            }
                                                                          });
                                                                    });
                                                              },
                                                              child: Text(
                                                                "${Configuration.instance.trackTileThirdRowThirdItem}",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .displaySmall,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        Flexible(
                                          flex: 5,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              FittedBox(
                                                child: TextButton(
                                                  style: ButtonStyle(
                                                      shape: MaterialStateProperty.all(
                                                          RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .circular(8 *
                                                                      Configuration
                                                                          .instance
                                                                          .borderRadiusMultiplier))),
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Theme.of(
                                                                      context)
                                                                  .cardColor)),
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialogueWithRadioList(
                                                              context: context,
                                                              valueToBeChanged:
                                                                  Configuration
                                                                      .instance
                                                                      .trackTileRightFirstItem,
                                                              functionToSaveTheValue:
                                                                  (e) async {
                                                                if (e != null) {
                                                                  setState(() =>
                                                                      Configuration
                                                                          .instance
                                                                          .trackTileRightFirstItem = e);

                                                                  await Configuration
                                                                      .instance
                                                                      .save(
                                                                    trackTileRightFirstItem:
                                                                        Configuration
                                                                            .instance
                                                                            .trackTileRightFirstItem,
                                                                  );
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .maybePop();
                                                                  setState(
                                                                      () {});
                                                                  await Future.delayed(
                                                                      const Duration(
                                                                          milliseconds:
                                                                              500));
                                                                }
                                                              });
                                                        });
                                                  },
                                                  child: Text(
                                                    "${Configuration.instance.trackTileRightFirstItem}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall,
                                                  ),
                                                ),
                                              ),
                                              FittedBox(
                                                child: TextButton(
                                                  style: ButtonStyle(
                                                      shape: MaterialStateProperty.all(
                                                          RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .circular(8 *
                                                                      Configuration
                                                                          .instance
                                                                          .borderRadiusMultiplier))),
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Theme.of(
                                                                      context)
                                                                  .cardColor)),
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialogueWithRadioList(
                                                              context: context,
                                                              valueToBeChanged:
                                                                  Configuration
                                                                      .instance
                                                                      .trackTileRightSecondItem,
                                                              functionToSaveTheValue:
                                                                  (e) async {
                                                                if (e != null) {
                                                                  setState(() =>
                                                                      Configuration
                                                                          .instance
                                                                          .trackTileRightSecondItem = e);

                                                                  await Configuration
                                                                      .instance
                                                                      .save(
                                                                    trackTileRightSecondItem:
                                                                        Configuration
                                                                            .instance
                                                                            .trackTileRightSecondItem,
                                                                  );
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .maybePop();
                                                                  setState(
                                                                      () {});
                                                                  await Future.delayed(
                                                                      const Duration(
                                                                          milliseconds:
                                                                              500));
                                                                }
                                                              });
                                                        });
                                                  },
                                                  child: Text(
                                                    "${Configuration.instance.trackTileRightSecondItem}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 46.0,
                                          height: 46.0,
                                          alignment: Alignment.center,
                                          child: IconButton(
                                            onPressed: null,
                                            icon: Icon(Icons.more_vert),
                                            iconSize: 24.0,
                                            splashRadius: 20.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ));
                    }));
              });
        });
  }
}

class ListTileAlertDialogueWithRadioList extends StatefulWidget {
  final BuildContext context;
  final String valueToBeChanged;
  final Function(String?)? functionToSaveTheValue;
  ListTileAlertDialogueWithRadioList({
    super.key,
    required this.context,
    required this.valueToBeChanged,
    required this.functionToSaveTheValue,
  });

  @override
  State<ListTileAlertDialogueWithRadioList> createState() =>
      _ListTileAlertDialogueWithRadioListState();
}

class _ListTileAlertDialogueWithRadioListState
    extends State<ListTileAlertDialogueWithRadioList> {
  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    return ListTile(
      onTap: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(
                      12.0 * Configuration.instance.borderRadiusMultiplier))),
              content: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: kDefaultTrackTileInfoChoose.entries
                          .map(
                            (e) => RadioListTile<String>(
                              groupValue: widget.valueToBeChanged,
                              value: e.key,
                              onChanged: widget.functionToSaveTheValue,
                              title: Text(
                                '${e.value}',
                                style: isDesktop
                                    ? Theme.of(context).textTheme.headlineMedium
                                    : null,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
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
        "${Configuration.instance.trackTileFirstRowFirstItem}",
        style: Theme.of(context)
            .textTheme
            .displayMedium
            ?.copyWith(color: Colors.grey[500]),
      ),
    );
  }
}

class AlertDialogueWithRadioList extends StatefulWidget {
  final BuildContext context;
  final String valueToBeChanged;
  final Function(String?)? functionToSaveTheValue;
  AlertDialogueWithRadioList({
    super.key,
    required this.context,
    required this.valueToBeChanged,
    required this.functionToSaveTheValue,
  });

  @override
  State<AlertDialogueWithRadioList> createState() =>
      _AlertDialogueWithRadioListState();
}

class _AlertDialogueWithRadioListState
    extends State<AlertDialogueWithRadioList> {
  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(
              12.0 * Configuration.instance.borderRadiusMultiplier))),
      content: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: kDefaultTrackTileInfoChoose.entries
                  .map(
                    (e) => RadioListTile<String>(
                      groupValue: widget.valueToBeChanged,
                      value: e.key,
                      onChanged: widget.functionToSaveTheValue,
                      title: Text(
                        '${e.value}',
                        style: isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : null,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

const kDefaultTrackTileInfoChoose = {
  'none': 'None',
  'trackName': 'Track Name',
  'artistNames': 'Artist Names',
  'albumName': 'Album Name',
  'albumArtistName': 'Album Artist Name',
  'genre': 'Genre',
  'duration': 'Duration',
  'year': 'Year',
  'trackNumber': 'Track Number',
  'discNumber': 'Disk Number',
  'filenamenoext': 'File Name Without Extension',
  'extension': 'Extension',
  'filename': 'File Name',
  'folder': 'Folder Name',
  'uri': 'File Full Path',
  'bitrate': 'Bitrate',
  'timeAddedDate': 'Time Added in Date',
  'timeAddedClock': 'Time Added in Hour',
  'timeAdded': 'Time Added (Date, Hour)',
};
