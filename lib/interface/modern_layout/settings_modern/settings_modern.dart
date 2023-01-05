/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_track.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';
import 'package:harmonoid/interface/modern_layout/theme_modern.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/widgets_modern.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:window_plus/window_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/interface/modern_layout/settings_modern/customization.dart';
import 'package:harmonoid/interface/settings/about.dart';
import 'package:harmonoid/interface/settings/indexing.dart';
import 'package:harmonoid/interface/settings/language.dart';
import 'package:harmonoid/interface/settings/stats.dart';
import 'package:harmonoid/interface/settings/miscellaneous.dart';
import 'package:harmonoid/interface/settings/experimental.dart';
import 'package:harmonoid/interface/settings/theme.dart';
import 'package:harmonoid/interface/settings/android_permissions.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/constants/language.dart';

class SettingsModern extends StatelessWidget {
  Future<void> open(String url) => launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingColorPalette>(builder: (context, palette, _) {
      final colorDelightened = getAlbumColorModifiedModern(palette.palette);
      final colorsList = palette.palette;
      return Stack(
        children: [
          AnimatingBackgroundModern(
            currentColor: colorDelightened,
            currentColorsList: colorsList ?? [],
            child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                leading: IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: Icon(Icons.arrow_back),
                  splashRadius: 20.0,
                ),
                title: Text(
                  Language.instance.SETTING,
                ),
              ),
              body: NowPlayingBarScrollHideNotifier(
                child: CustomListView(children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        SettingsCardsModern(
                          child: IndexingSetting(),
                        ),
                        Divider(thickness: 1.0),
                        SettingsCardsModern(child: LanguageSetting()),
                        SettingsCardsModern(child: ThemeSettingModern()),
                        Divider(thickness: 1.0),
                        SettingsCardsModern(child: StatsSetting()),
                        if (StorageRetriever.instance.version >= 33) ...[
                          SettingsCardsModern(
                              child: AndroidPermissionsSetting()),
                          Divider(thickness: 1.0),
                        ],
                        SettingsCardsModern(
                            child: CustomizationSetting(
                          currentTrackColor: colorDelightened,
                        )),
                        SettingsCardsModern(child: MiscellaneousSetting()),
                        Divider(thickness: 1.0),
                        SettingsCardsModern(child: ExperimentalSetting()),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top - 4.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 4.0,
              child: MobileIndexingProgressIndicator(),
            ),
          ),
        ],
      );
    });
  }
}

class SettingsTileModern extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final EdgeInsets? margin;
  final List<Widget>? actions;

  const SettingsTileModern({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: isDesktop
          ? EdgeInsets.symmetric(
              horizontal: 8.0,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isDesktop)
            Padding(
              padding: EdgeInsets.only(
                top: 24.0,
                left: 16.0,
                right: 16.0,
                bottom: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontSize: 20.0),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
          if (isMobile)
            Container(
              alignment: Alignment.bottomLeft,
              height: 40.0,
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 12.0),
              child: Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).textTheme.displaySmall?.color,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          Container(
            margin: margin ?? EdgeInsets.zero,
            child: child,
          ),
          if (actions != null) ...[
            ButtonBar(
              alignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}

class MobileIndexingProgressIndicator extends StatelessWidget {
  const MobileIndexingProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionRefresh>(
      builder: (context, controller, _) {
        if (controller.progress != controller.total) {
          return LinearProgressIndicator(
            value: controller.progress == null
                ? null
                : controller.progress! / controller.total,
            backgroundColor:
                Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            valueColor:
                AlwaysStoppedAnimation(Theme.of(context).colorScheme.secondary),
          );
        } else
          return SizedBox.shrink();
      },
    );
  }
}
