/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';
import 'dart:ui';
import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:desktop/desktop.dart' as desktop;
import 'package:path/path.dart' as path;
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/interface/collection/artist.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_album.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';
import 'package:harmonoid/utils/palette_generator.dart';

class TrackTabModern extends StatefulWidget {
  TrackTabModern({Key? key}) : super(key: key);

  @override
  _TrackTabModernState createState() => _TrackTabModernState();
}

class _TrackTabModernState extends State<TrackTabModern> {
  double _lastOffset = 0.0;
  final hover = ValueNotifier<bool>(true);
  final controller = ScrollController();
  final selectedTracksController = ScrollController();
  late List<Track> selectedTracks;
  bool isSelectedTracksMenuMinimized = true;
  bool isSelectedTracksExpanded = false;

  void listener() {
    if (this.controller.offset > _lastOffset) {
      this.hover.value = false;
    } else if (this.controller.offset < _lastOffset) {
      this.hover.value = true;
    }
    _lastOffset = this.controller.offset;
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
    selectedTracks = [];
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget selectedTracksMenuRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              selectedTracks = [];
              isSelectedTracksMenuMinimized = true;
            });
          },
          icon: SvgPicture.asset(
            "assets/modern_icons/close-circle.svg",
            color: Theme.of(context).iconTheme.color,
          ),
          splashRadius: 20.0,
        ),
        Container(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedTracks.length} Track${selectedTracks.length == 1 ? "" : "s"}',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(fontSize: 26.0),
              ),
              if (!isSelectedTracksMenuMinimized)
                Text(
                  "  ${getTotalTracksDurationFormatted(tracks: selectedTracks)}",
                  style: Theme.of(context).textTheme.displayMedium,
                )
            ],
          ),
        ),
        SizedBox(
          width: 32,
        ),
        IconButton(
          onPressed: () => Playback.instance
              .insertAt(selectedTracks, Playback.instance.index + 1),
          tooltip: "Queue Next",
          icon: SvgPicture.asset(
            "assets/modern_icons/next.svg",
            color: Theme.of(context).iconTheme.color,
          ),
          splashRadius: 20.0,
        ),
        IconButton(
          onPressed: () => Playback.instance.add(selectedTracks),
          tooltip: Language.instance.ADD_TO_NOW_PLAYING,
          icon: Icon(
            Iconsax.play_add,
            color: Theme.of(context).iconTheme.color,
          ),
          splashRadius: 20.0,
        ),
        IconButton(
          onPressed: () {
            Playback.instance.open([
              ...selectedTracks,
              if (Configuration.instance.seamlessPlayback)
                ...[...Collection.instance.tracks]..shuffle(),
            ]);
          },
          tooltip: Language.instance.PLAY_ALL,
          icon: SvgPicture.asset(
            "assets/modern_icons/play-circle.svg",
            color: Theme.of(context).iconTheme.color,
          ),
          splashRadius: 20.0,
        ),
        IconButton(
          onPressed: () {
            Playback.instance.open(
              [...selectedTracks]..shuffle(),
            );
          },
          tooltip: Language.instance.SHUFFLE,
          icon: SvgPicture.asset(
            "assets/modern_icons/shuffle.svg",
            color: Theme.of(context).iconTheme.color,
          ),
          splashRadius: 20.0,
        ),
        IconButton(
          onPressed: () {
            showAddToPlaylistDialogModern(context, selectedTracks);
          },
          tooltip: Language.instance.PLAYLIST_ADD_DIALOG_TITLE,
          icon: SvgPicture.asset(
            "assets/modern_icons/music-playlist.svg",
            color: Theme.of(context).iconTheme.color,
          ),
          splashRadius: 20.0,
        ),
        IconButton(
          onPressed: () {
            setState(() {
              selectedTracks = [];
              selectedTracks.addAll(Collection.instance.tracks);
            });
          },
          icon: SvgPicture.asset(
            "assets/modern_icons/category.svg",
            color: Theme.of(context).iconTheme.color,
          ),
          splashRadius: 20.0,
        ),
        isSelectedTracksMenuMinimized
            ? SvgPicture.asset(
                "assets/modern_icons/arrow-up-3.svg",
                color: Theme.of(context).iconTheme.color,
              )
            : SvgPicture.asset(
                "assets/modern_icons/arrow-down-2.svg",
                color: Theme.of(context).iconTheme.color,
              ),
      ],
    );
    return Consumer<Collection>(
      builder: (context, collection, _) => isDesktop
          ? collection.tracks.isNotEmpty
              ? desktop.ListTableTheme(
                  data: desktop.ListTableThemeData(
                    borderColor: Theme.of(context).dividerTheme.color,
                    highlightColor: Theme.of(context)
                            .dividerTheme
                            .color
                            ?.withOpacity(0.4) ??
                        Theme.of(context).dividerColor.withOpacity(0.4),
                    hoverColor: Theme.of(context)
                            .dividerTheme
                            .color
                            ?.withOpacity(0.2) ??
                        Theme.of(context).dividerColor.withOpacity(0.4),
                    borderHighlightColor: Theme.of(context).primaryColor,
                    borderIndicatorColor: Theme.of(context).primaryColor,
                    borderHoverColor: Theme.of(context).primaryColor,
                  ),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      desktop.ListTable(
                        controller: controller,
                        onPressed: (i, _) {
                          if (Configuration.instance
                              .addLibraryToPlaylistWhenPlayingFromTracksTab) {
                            Playback.instance.open(
                              collection.tracks,
                              index: i,
                            );
                          } else {
                            Playback.instance.open(
                              [
                                collection.tracks[i],
                              ],
                              index: 0,
                            );
                          }
                        },
                        onSecondaryPress: (index, position) async {
                          final result = await showMenu(
                            context: context,
                            constraints: BoxConstraints(
                              maxWidth: double.infinity,
                            ),
                            position: RelativeRect.fromLTRB(
                              position.left,
                              position.top,
                              MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.width,
                            ),
                            items: trackPopupMenuItems(
                              collection.tracks[index],
                              context,
                            ),
                          );
                          await trackPopupMenuHandle(
                            context,
                            collection.tracks[index],
                            result,
                          );
                        },
                        colCount: 5,
                        headerColumnBorder: BorderSide(
                          color: Theme.of(context).dividerTheme.color ??
                              Theme.of(context).dividerColor,
                          width: 1.0,
                        ),
                        tableBorder: desktop.TableBorder(
                          verticalInside: BorderSide(
                            color: Theme.of(context).dividerTheme.color ??
                                Theme.of(context).dividerColor,
                          ),
                          top: BorderSide(
                            color: Theme.of(context).dividerTheme.color ??
                                Theme.of(context).dividerColor,
                          ),
                        ),
                        itemCount: collection.tracks.length,
                        itemExtent: 32.0,
                        colFraction: {
                          0: 0.04,
                          1: 0.36,
                          4: 0.12,
                        },
                        tableHeaderBuilder: (context, index, constraints) =>
                            Container(
                          alignment: Alignment.center,
                          child: Transform.translate(
                            offset: Offset(4.0, 0.0),
                            child: Text(
                              [
                                '#',
                                Language.instance.TRACK_SINGLE,
                                Language.instance.ARTIST,
                                Language.instance.ALBUM_SINGLE,
                                Language.instance.YEAR
                              ][index],
                              style: Theme.of(context).textTheme.displayMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        tableRowBuilder:
                            (context, index, property, constraints) =>
                                Container(
                          constraints: constraints,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          alignment: property == 0
                              ? Alignment.center
                              : Alignment.centerLeft,
                          child: () {
                            if ([0, 1, 4].contains(property)) {
                              return Text(
                                [
                                  '${collection.tracks[index].trackNumber}',
                                  collection.tracks[index].trackName,
                                  collection.tracks[index].trackArtistNames
                                      .join(', '),
                                  collection.tracks[index].albumName,
                                  collection.tracks[index].year.toString(),
                                ][property],
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              );
                            } else if (property == 2) {
                              final elements = <TextSpan>[];
                              collection.tracks[index].trackArtistNames
                                  .map(
                                (e) => TextSpan(
                                  text: e,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Playback.instance
                                              .interceptPositionChangeRebuilds =
                                          true;
                                      navigatorKey.currentState?.push(
                                        PageRouteBuilder(
                                          pageBuilder: ((context, animation,
                                                  secondaryAnimation) =>
                                              FadeThroughTransition(
                                                animation: animation,
                                                secondaryAnimation:
                                                    secondaryAnimation,
                                                child: ArtistScreen(
                                                  artist: Collection
                                                      .instance.artistsSet
                                                      .lookup(Artist(
                                                          artistName: e))!,
                                                ),
                                              )),
                                        ),
                                      );
                                      Timer(const Duration(milliseconds: 400),
                                          () {
                                        Playback.instance
                                                .interceptPositionChangeRebuilds =
                                            false;
                                      });
                                    },
                                ),
                              )
                                  .forEach((element) {
                                elements.add(element);
                                elements.add(TextSpan(text: ', '));
                              });
                              elements.removeLast();
                              return HyperLink(
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                                text: TextSpan(
                                  children: elements,
                                ),
                              );
                            } else if (property == 3) {
                              return HyperLink(
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: collection.tracks[index].albumName,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Playback.instance
                                                  .interceptPositionChangeRebuilds =
                                              true;
                                          navigatorKey.currentState?.push(
                                            PageRouteBuilder(
                                              pageBuilder: ((context, animation,
                                                      secondaryAnimation) =>
                                                  FadeThroughTransition(
                                                    animation: animation,
                                                    secondaryAnimation:
                                                        secondaryAnimation,
                                                    child: AlbumScreen(
                                                      album: Collection
                                                          .instance.albumsSet
                                                          .lookup(
                                                        Album(
                                                          albumName: collection
                                                              .tracks[index]
                                                              .albumName,
                                                          year: collection
                                                              .tracks[index]
                                                              .year,
                                                          albumArtistName:
                                                              collection
                                                                  .tracks[index]
                                                                  .albumArtistName,
                                                          albumHashCodeParameters:
                                                              Collection
                                                                  .instance
                                                                  .albumHashCodeParameters,
                                                        ),
                                                      )!,
                                                    ),
                                                  )),
                                            ),
                                          );
                                          Timer(
                                              const Duration(milliseconds: 400),
                                              () {
                                            Playback.instance
                                                    .interceptPositionChangeRebuilds =
                                                false;
                                          });
                                        },
                                    ),
                                  ],
                                ),
                              );
                            }
                          }(),
                        ),
                      ),
                      SortBar(
                        tab: 1,
                        fixed: false,
                        hover: hover,
                      ),
                    ],
                  ),
                )
              : Center(
                  child: ExceptionWidget(
                    title: Language.instance.NO_COLLECTION_TITLE,
                    subtitle: Language.instance.NO_COLLECTION_SUBTITLE,
                  ),
                )
          : Stack(
              children: [
                Consumer<Collection>(
                  builder: (context, collection, _) => collection
                          .tracks.isNotEmpty
                      ? DraggableScrollbar.semicircle(
                          heightScrollThumb: 56.0,
                          labelConstraints: BoxConstraints.tightFor(
                            width: 120.0,
                            height: 32.0,
                          ),
                          labelTextBuilder: (offset) {
                            final index = (offset -
                                    (kMobileSearchBarHeight +
                                        2 * tileMargin +
                                        MediaQuery.of(context).padding.top)) ~/
                                (Configuration.instance.trackListTileHeight +
                                    8);
                            final track = collection.tracks[index.clamp(
                              0,
                              collection.tracks.length - 1,
                            )];
                            switch (collection.tracksSort) {
                              case TracksSort.aToZ:
                                {
                                  return Text(
                                    track.trackName[0].toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                  );
                                }
                              case TracksSort.dateAdded:
                                {
                                  return Text(
                                    '${track.timeAdded.label}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  );
                                }
                              case TracksSort.year:
                                {
                                  return Text(
                                    '${track.year}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  );
                                }
                              default:
                                return Text(
                                  '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                );
                            }
                          },
                          backgroundColor: Theme.of(context).cardTheme.color ??
                              Theme.of(context).cardColor,
                          controller: controller,
                          child: ListView(
                            controller: controller,
                            itemExtent:
                                Configuration.instance.trackListTileHeight + 8,
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top +
                                  kMobileSearchBarHeight +
                                  2 * tileMargin,
                              bottom: Configuration.instance.stickyMiniplayer
                                  ? kMobileNowPlayingBarHeight
                                  : kMobileBottomPaddingSmall,
                            ),
                            children: collection.tracks
                                .asMap()
                                .entries
                                .map(
                                  (track) => GestureDetector(
                                    onLongPress: () {
                                      setState(() {
                                        if (selectedTracks
                                            .contains(track.value)) {
                                          selectedTracks.remove(track.value);
                                        } else {
                                          selectedTracks.add(track.value);
                                        }
                                      });
                                    },
                                    child: Configuration.instance
                                            .addLibraryToPlaylistWhenPlayingFromTracksTab
                                        ? TrackTileModern(
                                            index: track.key,
                                            track: track.value,
                                            onPressed: selectedTracks.length > 0
                                                ? () {
                                                    setState(() {
                                                      if (selectedTracks
                                                          .contains(
                                                              track.value)) {
                                                        selectedTracks.remove(
                                                            track.value);
                                                      } else {
                                                        selectedTracks
                                                            .add(track.value);
                                                      }
                                                    });
                                                  }
                                                : null,
                                            selectedColor: selectedTracks
                                                    .contains(track.value)
                                                ? Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Color.fromARGB(
                                                        255, 222, 222, 222)
                                                    : Color.fromARGB(
                                                        255, 40, 40, 40)
                                                : null)
                                        : TrackTileModern(
                                            index: 0,
                                            track: track.value,
                                            group: [
                                              track.value,
                                            ],
                                            onPressed: selectedTracks.length > 0
                                                ? () {
                                                    setState(() {
                                                      if (selectedTracks
                                                          .contains(
                                                              track.value)) {
                                                        selectedTracks.remove(
                                                            track.value);
                                                      } else {
                                                        selectedTracks
                                                            .add(track.value);
                                                      }
                                                    });
                                                  }
                                                : null,
                                            selectedColor: selectedTracks
                                                    .contains(track.value)
                                                ? Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Color.fromARGB(
                                                        255, 222, 222, 222)
                                                    : Color.fromARGB(
                                                        255, 33, 33, 33)
                                                : null),
                                  ),
                                )
                                .toList(),
                          ),
                        )
                      : Container(
                          // padding: EdgeInsets.only(
                          //   top: MediaQuery.of(context).padding.top +
                          //       kMobileSearchBarHeight +
                          //       2 * tileMargin,
                          // ),
                          child: Center(
                            child: ExceptionWidget(
                              title: Language.instance.NO_COLLECTION_TITLE,
                              subtitle:
                                  Language.instance.NO_COLLECTION_SUBTITLE,
                            ),
                          ),
                        ),
                ),
                if (selectedTracks.length > 0)
                  Positioned(
                    bottom:
                        kMobileNowPlayingBarHeight + kMobileBottomPaddingSmall,
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 300,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSelectedTracksMenuMinimized =
                                      !isSelectedTracksMenuMinimized;
                                });
                              },
                              onTapDown: (value) {
                                setState(() {
                                  isSelectedTracksExpanded = true;
                                });
                              },
                              onTapUp: (value) {
                                setState(() {
                                  isSelectedTracksExpanded = false;
                                });
                              },
                              onTapCancel: () {
                                isSelectedTracksExpanded =
                                    !isSelectedTracksExpanded;
                              },
                              // dragging upwards or downwards
                              onPanEnd: (details) {
                                if (details.velocity.pixelsPerSecond.dy < 0) {
                                  setState(() {
                                    isSelectedTracksMenuMinimized = false;
                                  });
                                } else if (details.velocity.pixelsPerSecond.dy >
                                    0) {
                                  setState(() {
                                    isSelectedTracksMenuMinimized = true;
                                  });
                                }
                              },
                              child: AnimatedContainer(
                                clipBehavior: Clip.antiAlias,
                                duration: Duration(seconds: 1),
                                curve: Curves.fastLinearToSlowEaseIn,
                                height: isSelectedTracksMenuMinimized
                                    ? isSelectedTracksExpanded
                                        ? 80
                                        : 85
                                    : isSelectedTracksExpanded
                                        ? 425
                                        : 430,
                                width: isSelectedTracksExpanded ? 375 : 380,
                                decoration: BoxDecoration(
                                  color: Color.alphaBlend(
                                      Color.fromARGB(15, 128, 128, 128),
                                      Theme.of(context).cardTheme.color ??
                                          Colors.transparent),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor,
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(15),
                                child: isSelectedTracksMenuMinimized
                                    ? FittedBox(child: selectedTracksMenuRow)
                                    : Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          FittedBox(
                                              child: selectedTracksMenuRow),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Expanded(
                                            child: Container(
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child:
                                                  ReorderableListView.builder(
                                                onReorder:
                                                    (oldIndex, newIndex) {
                                                  setState(() {
                                                    if (newIndex > oldIndex) {
                                                      newIndex -= 1;
                                                    }
                                                    final item = selectedTracks
                                                        .removeAt(oldIndex);

                                                    selectedTracks.insert(
                                                        newIndex, item);
                                                  });
                                                },
                                                physics:
                                                    BouncingScrollPhysics(),
                                                padding: EdgeInsets.zero,
                                                itemCount:
                                                    selectedTracks.length,
                                                itemBuilder: (context, i) {
                                                  return Builder(
                                                    key: ValueKey(
                                                        selectedTracks[i].uri),
                                                    builder: (context) =>
                                                        Dismissible(
                                                      key: ValueKey(
                                                          selectedTracks[i]
                                                              .uri),
                                                      onDismissed: (direction) {
                                                        setState(() {
                                                          selectedTracks
                                                              .removeAt(i);
                                                        });
                                                      },
                                                      child: TrackTileModern(
                                                        displayDragHandler:
                                                            true,
                                                        track:
                                                            selectedTracks[i],
                                                        index: i,
                                                        disableContextMenu:
                                                            true,
                                                        disableSeparator: true,
                                                        onPressed: () {
                                                          Playback.instance.open(
                                                              selectedTracks,
                                                              index: i);
                                                        },
                                                        title: Text(
                                                          selectedTracks[i]
                                                              .trackName,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .displayMedium
                                                                  ?.copyWith(
                                                                    color: i <
                                                                            Playback
                                                                                .instance.index
                                                                        ? Theme.of(context)
                                                                            .textTheme
                                                                            .displaySmall
                                                                            ?.color
                                                                        : null,
                                                                  ),
                                                        ),
                                                        subtitle: Text(
                                                          selectedTracks[i]
                                                              .trackArtistNames
                                                              .take(1)
                                                              .join(', '),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .displaySmall,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class TrackTileModern extends StatefulWidget {
  final Track track;
  final int index;
  final void Function()? onPressed;
  final Widget? leading;
  final List<Track>? group;
  final Widget? title;
  final Widget? subtitle;
  final Color? selectedColor;
  final bool disableSeparator;
  final bool disableContextMenu;
  final bool displayDragHandler;
  const TrackTileModern({
    Key? key,
    required this.track,
    this.index = 0,
    this.onPressed,
    this.leading,
    this.group,
    this.title,
    this.subtitle,
    this.selectedColor,
    this.disableSeparator = false,
    this.disableContextMenu = false,
    this.displayDragHandler = false,
  });

  TrackTileModernState createState() => TrackTileModernState();
}

class TrackTileModernState extends State<TrackTileModern> {
  bool hovered = false;
  bool reactToSecondaryPress = false;
  bool displayDragHandler = false;
// Declare a ValueNotifier to store the selected items
  final ValueNotifier<List<Track>> selectedTracks = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    final group = widget.group ?? Collection.instance.tracks;
    final formatDate = DateFormat('${Configuration.instance.dateTimeFormat}');
    final formatClock = Configuration.instance.hourFormat12
        ? DateFormat('hh:mm aa')
        : DateFormat('HH:mm');
    Future<Color?> albumColor;
    albumColor =
        getAlbumColorSingleModern(media: widget.track, context: context);
    String getChoosenTrackTileItem(String trackItemPlace) {
      String fileUri = path.prettyUri("${widget.track.uri}");
      String dateTimeAddedNotFormatted =
          "${widget.track.timeAdded.year}${widget.track.timeAdded.month.toString().padLeft(2, '0')}${widget.track.timeAdded.day.toString().padLeft(2, '0')}";
      // String clockTimeAddedNotFormatted =
      //     "${Configuration.instance.hourFormat12 ? formatClock.format(widget.track.timeAdded) : widget.track.timeAdded.hour.toString().padLeft(2, '0')}:${widget.track.timeAdded.minute.toString().padLeft(2, '0')}";
      String clockTimeAddedFormatted =
          "${formatClock.format(widget.track.timeAdded)}";

      String trackItemPlaceV = [
        if (trackItemPlace == "none") "",
        if (trackItemPlace == "trackName")
          widget.track.trackName.replaceAll(' ', '\u00A0'),
        if (trackItemPlace == "artistNames")
          widget.track.trackArtistNames.take(2).join(', '),
        if (trackItemPlace == "albumName") widget.track.albumName,
        if (trackItemPlace == "albumArtistName") widget.track.albumArtistName,
        if (trackItemPlace == "genre") widget.track.genre,
        if (trackItemPlace == "duration")
          widget.track.duration?.label ?? Duration.zero.label,
        if (trackItemPlace == "year")
          widget.track.year.length == 8
              ? formatDate.format(DateTime.parse(widget.track.year))
              : widget.track.year,
        if (trackItemPlace == "trackNumber") widget.track.trackNumber,
        if (trackItemPlace == "discNumber") widget.track.discNumber,
        if (trackItemPlace == "filenamenoext")
          path.basenameWithoutExtension(fileUri),
        if (trackItemPlace == "extension") path.extension(fileUri).substring(1),
        if (trackItemPlace == "filename") path.basename(fileUri),
        if (trackItemPlace == "folder")
          // path.dirname(path.fromUri("${widget.track.uri}")),
          path.dirname(fileUri).split('/').last,
        if (trackItemPlace == "uri") fileUri,
        if (trackItemPlace == "bitrate")
          "${(widget.track.bitrate! / 1000).round()} kps",
        if (trackItemPlace == "timeAddedDate")
          formatDate.format(DateTime.parse(dateTimeAddedNotFormatted)),
        if (trackItemPlace == "timeAddedClock") clockTimeAddedFormatted,
        if (trackItemPlace == "timeAdded")
          "${formatDate.format(DateTime.parse(dateTimeAddedNotFormatted))}, $clockTimeAddedFormatted",
      ].join('');

      return trackItemPlaceV;
    }

    final subtitle = [
      if (!widget.track.hasNoAvailableArtists)
        widget.track.trackArtistNames.take(2).join(', '),
      if (!widget.track.hasNoAvailableAlbum) widget.track.albumName.overflow
    ].join(' • ');
    return isDesktop
        ? MouseRegion(
            onEnter: (e) {
              setState(() {
                hovered = true;
              });
            },
            onExit: (e) {
              setState(() {
                hovered = false;
              });
            },
            child: Listener(
              onPointerDown: (e) {
                reactToSecondaryPress = e.kind == PointerDeviceKind.mouse &&
                    e.buttons == kSecondaryMouseButton;
              },
              onPointerUp: (e) async {
                if (widget.disableContextMenu) return;
                if (!reactToSecondaryPress) return;
                var result = await showMenu(
                  context: context,
                  constraints: BoxConstraints(
                    maxWidth: double.infinity,
                  ),
                  position: RelativeRect.fromLTRB(
                    e.position.dx,
                    e.position.dy,
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.width,
                  ),
                  items: trackPopupMenuItems(
                    widget.track,
                    context,
                  ),
                );
                await trackPopupMenuHandle(
                  context,
                  widget.track,
                  result,
                  // Only used in [SearchTab].
                  recursivelyPopNavigatorOnDeleteIf: () => true,
                );
              },
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (widget.onPressed != null) {
                      widget.onPressed?.call();
                      return;
                    }
                    Playback.instance.open(
                      group,
                      index: widget.index,
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 64.0,
                        height: 48.0,
                        padding: EdgeInsets.only(right: 8.0),
                        alignment: Alignment.center,
                        child: hovered
                            ? IconButton(
                                onPressed: () {
                                  if (widget.onPressed != null) {
                                    widget.onPressed?.call();
                                    return;
                                  }
                                  Playback.instance.open(
                                    group,
                                    index: widget.index,
                                  );
                                },
                                icon: Icon(Icons.play_arrow),
                                splashRadius: 20.0,
                              )
                            : widget.leading ??
                                Text(
                                  '${widget.track.trackNumber}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                      ),
                      Expanded(
                        child: Container(
                          height: 48.0,
                          padding: EdgeInsets.only(right: 16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.track.trackName,
                            style: Theme.of(context).textTheme.headlineMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 48.0,
                          padding: EdgeInsets.only(right: 16.0),
                          alignment: Alignment.centerLeft,
                          child: () {
                            final elements = <TextSpan>[];
                            widget.track.trackArtistNames
                                .map(
                              (e) => TextSpan(
                                text: e,
                                recognizer: widget.track.uri.isScheme('FILE')
                                    ? (TapGestureRecognizer()
                                      ..onTap = () {
                                        DesktopNowPlayingController.instance
                                            .hide();
                                        navigatorKey.currentState?.push(
                                          PageRouteBuilder(
                                            pageBuilder: ((context, animation,
                                                    secondaryAnimation) =>
                                                FadeThroughTransition(
                                                  animation: animation,
                                                  secondaryAnimation:
                                                      secondaryAnimation,
                                                  child: ArtistScreen(
                                                    artist: Collection
                                                        .instance.artistsSet
                                                        .lookup(Artist(
                                                            artistName: e))!,
                                                  ),
                                                )),
                                          ),
                                        );
                                      })
                                    : null,
                              ),
                            )
                                .forEach((element) {
                              elements.add(element);
                              elements.add(TextSpan(text: ', '));
                            });
                            elements.removeLast();
                            return HyperLink(
                              style: Theme.of(context).textTheme.headlineMedium,
                              text: TextSpan(
                                children: elements,
                              ),
                            );
                          }(),
                        ),
                      ),
                      if (!widget.disableContextMenu)
                        Container(
                          height: 48.0,
                          width: 120.0,
                          padding: EdgeInsets.only(right: 32.0),
                          alignment: Alignment.centerRight,
                          child: Text(
                            widget.track.year.toString(),
                            style: Theme.of(context).textTheme.headlineMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (!widget.disableContextMenu)
                        Container(
                          width: 64.0,
                          height: 56.0,
                          alignment: Alignment.center,
                          child: ContextMenuButton<int>(
                            onSelected: (result) {
                              trackPopupMenuHandle(
                                context,
                                widget.track,
                                result,
                                // Only used in [SearchTab].
                                recursivelyPopNavigatorOnDeleteIf: () => true,
                              );
                            },
                            color: Theme.of(context).iconTheme.color,
                            itemBuilder: (_) => trackPopupMenuItems(
                              widget.track,
                              context,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Playback.instance.tracks.isNotEmpty &&
                Playback.instance.tracks[Playback.instance.index] ==
                    widget.track
            ? Consumer<NowPlayingColorPalette>(builder: (context, palette, _) {
                final colorDelightened =
                    getAlbumColorModifiedModern(palette.palette);
                return Material(
                  color: colorDelightened,
                  child: InkWell(
                    highlightColor: Color.fromARGB(60, 0, 0, 0),
                    splashColor: Colors.transparent,
                    onTap: widget.onPressed ??
                        () => Playback.instance.playOrPause(),
                    // onLongPress:
                    //     widget.disableContextMenu ? null : showTrackDialog,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!widget.disableSeparator)
                          Divider(
                            height: 1.0,
                          ),
                        Container(
                          height: Configuration.instance.trackListTileHeight,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 4.0),
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 12.0),
                              widget.leading ??
                                  CustomTrackThumbnailModern(
                                    scale: 1,
                                    borderRadius: 8,
                                    blur: 2,
                                    track: widget.track,
                                  ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // check if first row isnt empty
                                    if (Configuration.instance
                                                .trackTileFirstRowFirstItem !=
                                            "none" ||
                                        Configuration.instance
                                                .trackTileFirstRowSecondItem !=
                                            "none" ||
                                        Configuration.instance
                                                .trackTileFirstRowThirdItem !=
                                            "none")
                                      Text(
                                        // widget.track.trackName.overflow,
                                        [
                                          if (Configuration.instance
                                                  .trackTileFirstRowFirstItem !=
                                              "none")
                                            getChoosenTrackTileItem(Configuration
                                                .instance
                                                .trackTileFirstRowFirstItem),
                                          if (Configuration.instance
                                                  .trackTileFirstRowSecondItem !=
                                              "none")
                                            getChoosenTrackTileItem(Configuration
                                                .instance
                                                .trackTileFirstRowSecondItem),
                                          if (Configuration.instance
                                                      .trackTileFirstRowThirdItem !=
                                                  "none" &&
                                              Configuration.instance
                                                  .trackTileDisplayThirdItemInRows)
                                            getChoosenTrackTileItem(
                                                Configuration.instance
                                                    .trackTileFirstRowThirdItem)
                                        ].join(
                                            ' ${Configuration.instance.trackTileSeparator} '),
                                        overflow: TextOverflow.ellipsis,

                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              fontSize: Configuration.instance
                                                      .trackListTileHeight *
                                                  0.2,
                                              color:
                                                  Colors.white.withAlpha(170),
                                            ),
                                      ),
                                    // check if second row isnt empty
                                    if (Configuration.instance
                                                .trackTileSecondRowFirstItem !=
                                            "none" ||
                                        Configuration.instance
                                                .trackTileSecondRowSecondItem !=
                                            "none" ||
                                        Configuration.instance
                                                .trackTileSecondRowThirdItem !=
                                            "none")
                                      Text(
                                        [
                                          if (Configuration.instance
                                                  .trackTileSecondRowFirstItem !=
                                              "none")
                                            getChoosenTrackTileItem(Configuration
                                                .instance
                                                .trackTileSecondRowFirstItem),
                                          if (Configuration.instance
                                                  .trackTileSecondRowSecondItem !=
                                              "none")
                                            getChoosenTrackTileItem(Configuration
                                                .instance
                                                .trackTileSecondRowSecondItem),
                                          if (Configuration.instance
                                                      .trackTileSecondRowThirdItem !=
                                                  "none" &&
                                              Configuration.instance
                                                  .trackTileDisplayThirdItemInRows)
                                            getChoosenTrackTileItem(Configuration
                                                .instance
                                                .trackTileSecondRowThirdItem)
                                        ].join(
                                            ' ${Configuration.instance.trackTileSeparator} '),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .copyWith(
                                              fontSize: Configuration.instance
                                                      .trackListTileHeight *
                                                  0.18,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  Colors.white.withAlpha(140),
                                            ),
                                      ),
                                    // check if third row isnt empty
                                    if (Configuration
                                            .instance.trackTileDisplayThirdRow &&
                                        (Configuration.instance
                                                    .trackTileThirdRowFirstItem !=
                                                "none" ||
                                            Configuration.instance
                                                    .trackTileThirdRowSecondItem !=
                                                "none" ||
                                            Configuration.instance
                                                    .trackTileThirdRowThirdItem !=
                                                "none"))
                                      Text(
                                        [
                                          if (Configuration.instance
                                                  .trackTileThirdRowFirstItem !=
                                              "none")
                                            getChoosenTrackTileItem(Configuration
                                                .instance
                                                .trackTileThirdRowFirstItem),
                                          if (Configuration.instance
                                                  .trackTileThirdRowSecondItem !=
                                              "none")
                                            getChoosenTrackTileItem(Configuration
                                                .instance
                                                .trackTileThirdRowSecondItem),
                                          if (Configuration.instance
                                                      .trackTileThirdRowThirdItem !=
                                                  "none" &&
                                              Configuration.instance
                                                  .trackTileDisplayThirdItemInRows)
                                            getChoosenTrackTileItem(
                                                Configuration.instance
                                                    .trackTileThirdRowThirdItem)
                                        ].join(
                                            ' ${Configuration.instance.trackTileSeparator} '),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .copyWith(
                                              fontSize: Configuration.instance
                                                      .trackListTileHeight *
                                                  0.165,
                                              color:
                                                  Colors.white.withAlpha(120),
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              if (Configuration
                                          .instance.trackTileRightFirstItem !=
                                      "none" ||
                                  Configuration
                                          .instance.trackTileRightSecondItem !=
                                      "none")
                                const SizedBox(width: 12.0),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (Configuration
                                          .instance.trackTileRightFirstItem !=
                                      "none")
                                    Text(
                                      getChoosenTrackTileItem(Configuration
                                          .instance.trackTileRightFirstItem),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(
                                            fontSize: Configuration.instance
                                                    .trackListTileHeight *
                                                0.18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withAlpha(160),
                                          ),
                                    ),
                                  if (Configuration.instance
                                              .trackTileRightFirstItem !=
                                          "none" &&
                                      Configuration.instance
                                              .trackTileRightSecondItem !=
                                          "none")
                                    const SizedBox(height: 4.0),
                                  if (Configuration
                                          .instance.trackTileRightSecondItem !=
                                      "none")
                                    Text(
                                      getChoosenTrackTileItem(Configuration
                                          .instance.trackTileRightSecondItem),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(
                                            fontSize: Configuration.instance
                                                    .trackListTileHeight *
                                                0.18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withAlpha(160),
                                          ),
                                    ),
                                ],
                              ),
                              if (!widget.disableContextMenu)
                                Container(
                                  width: 46.0,
                                  height: 46.0,
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    onPressed: () => showTrackDialog(
                                        context, widget.track, widget.leading),
                                    icon: Icon(Icons.more_vert),
                                    iconSize: 24.0,
                                    splashRadius: 20.0,
                                    color: Colors.white.withAlpha(160),
                                  ),
                                ),
                              if (widget.displayDragHandler)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: 12,
                                    ),
                                    ReorderableDragStartListener(
                                      index: widget.index,
                                      child: Container(
                                        width: 22.0,
                                        alignment: Alignment.center,
                                        child: SvgPicture.asset(
                                          "assets/modern_icons/menu-1.svg",
                                          color: Colors.white.withAlpha(160),
                                          width: 22.0,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 36.0,
                                      alignment: Alignment.center,
                                      child: RotatedBox(
                                          quarterTurns: 1,
                                          child: IconButton(
                                            onPressed: () => showTrackDialog(
                                                context,
                                                widget.track,
                                                widget.leading),
                                            icon: SvgPicture.asset(
                                              "assets/modern_icons/more.svg",
                                              color:
                                                  Colors.white.withAlpha(160),
                                              width: 22.0,
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
            : Material(
                color: Color.alphaBlend(
                  widget.selectedColor ?? Colors.transparent,
                  Theme.of(context).cardTheme.color!,
                ),
                child: InkWell(
                  highlightColor: Color.fromARGB(60, 0, 0, 0),
                  splashColor: Colors.transparent,
                  onTap: widget.onPressed ??
                      () => Playback.instance.open(
                            group,
                            index: widget.index,
                          ),
                  // onLongPress:
                  //     widget.disableContextMenu ? null : showTrackDialog,
                  // onLongPress: () {
                  //   setState(() {
                  //     if (selectedTracks.value.contains(widget.track)) {
                  //       selectedTracks.value.remove(widget.track);
                  //     } else {
                  //       selectedTracks.value.add(widget.track);
                  //     }
                  //     print(widget.track.trackName);
                  //     print(selectedTracks.value.length);
                  //   });
                  // },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!widget.disableSeparator)
                        Divider(
                          height: 1.0,
                        ),
                      Container(
                        height: Configuration.instance.trackListTileHeight,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 4.0),
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 12.0),
                            widget.leading ??
                                SizedBox(
                                  width: Configuration
                                      .instance.trackThumbnailSizeinList,
                                  height: Configuration
                                      .instance.trackThumbnailSizeinList,
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8 *
                                          Configuration
                                              .instance.borderRadiusMultiplier),
                                      child: DropShadow(
                                        borderRadius: 8 *
                                            Configuration.instance
                                                .borderRadiusMultiplier,
                                        blurRadius: Configuration
                                                .instance.enableGlowEffect
                                            ? 2
                                            : 0,
                                        spread: Configuration
                                                .instance.enableGlowEffect
                                            ? 0.8
                                            : 0,
                                        offset: Offset(0, 1),
                                        child: ExtendedImage(
                                          image: Image(
                                                  image: getAlbumArt(
                                                      widget.track,
                                                      small: true))
                                              .image,
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
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // check if first row isnt empty
                                  if (Configuration.instance
                                              .trackTileFirstRowFirstItem !=
                                          "none" ||
                                      Configuration.instance
                                              .trackTileFirstRowSecondItem !=
                                          "none" ||
                                      Configuration.instance
                                              .trackTileFirstRowThirdItem !=
                                          "none")
                                    Text(
                                      // widget.track.trackName.overflow,
                                      [
                                        if (Configuration.instance
                                                .trackTileFirstRowFirstItem !=
                                            "none")
                                          getChoosenTrackTileItem(Configuration
                                              .instance
                                              .trackTileFirstRowFirstItem),
                                        if (Configuration.instance
                                                .trackTileFirstRowSecondItem !=
                                            "none")
                                          getChoosenTrackTileItem(Configuration
                                              .instance
                                              .trackTileFirstRowSecondItem),
                                        if (Configuration.instance
                                                    .trackTileFirstRowThirdItem !=
                                                "none" &&
                                            Configuration.instance
                                                .trackTileDisplayThirdItemInRows)
                                          getChoosenTrackTileItem(Configuration
                                              .instance
                                              .trackTileFirstRowThirdItem)
                                      ].join(
                                          ' ${Configuration.instance.trackTileSeparator} '),
                                      overflow: TextOverflow.ellipsis,

                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                              fontSize: Configuration.instance
                                                      .trackListTileHeight *
                                                  0.2),
                                    ),
                                  // check if second row isnt empty
                                  if (Configuration.instance
                                              .trackTileSecondRowFirstItem !=
                                          "none" ||
                                      Configuration.instance
                                              .trackTileSecondRowSecondItem !=
                                          "none" ||
                                      Configuration.instance
                                              .trackTileSecondRowThirdItem !=
                                          "none")
                                    Text(
                                      [
                                        if (Configuration.instance
                                                .trackTileSecondRowFirstItem !=
                                            "none")
                                          getChoosenTrackTileItem(Configuration
                                              .instance
                                              .trackTileSecondRowFirstItem),
                                        if (Configuration.instance
                                                .trackTileSecondRowSecondItem !=
                                            "none")
                                          getChoosenTrackTileItem(Configuration
                                              .instance
                                              .trackTileSecondRowSecondItem),
                                        if (Configuration.instance
                                                    .trackTileSecondRowThirdItem !=
                                                "none" &&
                                            Configuration.instance
                                                .trackTileDisplayThirdItemInRows)
                                          getChoosenTrackTileItem(Configuration
                                              .instance
                                              .trackTileSecondRowThirdItem)
                                      ].join(
                                          ' ${Configuration.instance.trackTileSeparator} '),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(
                                              fontSize: Configuration.instance
                                                      .trackListTileHeight *
                                                  0.18,
                                              fontWeight: FontWeight.w500),
                                    ),
                                  // check if third row isnt empty
                                  if (Configuration
                                          .instance.trackTileDisplayThirdRow &&
                                      (Configuration.instance
                                                  .trackTileThirdRowFirstItem !=
                                              "none" ||
                                          Configuration.instance
                                                  .trackTileThirdRowSecondItem !=
                                              "none" ||
                                          Configuration.instance
                                                  .trackTileThirdRowThirdItem !=
                                              "none"))
                                    Text(
                                      [
                                        if (Configuration.instance
                                                .trackTileThirdRowFirstItem !=
                                            "none")
                                          getChoosenTrackTileItem(Configuration
                                              .instance
                                              .trackTileThirdRowFirstItem),
                                        if (Configuration.instance
                                                .trackTileThirdRowSecondItem !=
                                            "none")
                                          getChoosenTrackTileItem(Configuration
                                              .instance
                                              .trackTileThirdRowSecondItem),
                                        if (Configuration.instance
                                                    .trackTileThirdRowThirdItem !=
                                                "none" &&
                                            Configuration.instance
                                                .trackTileDisplayThirdItemInRows)
                                          getChoosenTrackTileItem(Configuration
                                              .instance
                                              .trackTileThirdRowThirdItem)
                                      ].join(
                                          ' ${Configuration.instance.trackTileSeparator} '),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(
                                              fontSize: Configuration.instance
                                                      .trackListTileHeight *
                                                  0.165),
                                    ),
                                ],
                              ),
                            ),
                            if (Configuration
                                        .instance.trackTileRightFirstItem !=
                                    "none" ||
                                Configuration
                                        .instance.trackTileRightSecondItem !=
                                    "none")
                              const SizedBox(width: 12.0),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (Configuration
                                        .instance.trackTileRightFirstItem !=
                                    "none")
                                  Text(
                                    getChoosenTrackTileItem(Configuration
                                        .instance.trackTileRightFirstItem),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(
                                          fontSize: Configuration.instance
                                                  .trackListTileHeight *
                                              0.18,
                                        ),
                                  ),
                                if (Configuration
                                            .instance.trackTileRightFirstItem !=
                                        "none" &&
                                    Configuration.instance
                                            .trackTileRightSecondItem !=
                                        "none")
                                  const SizedBox(height: 4.0),
                                if (Configuration
                                        .instance.trackTileRightSecondItem !=
                                    "none")
                                  Text(
                                    getChoosenTrackTileItem(Configuration
                                        .instance.trackTileRightSecondItem),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(
                                          fontSize: Configuration.instance
                                                  .trackListTileHeight *
                                              0.18,
                                        ),
                                  ),
                              ],
                            ),
                            if (!widget.disableContextMenu)
                              Container(
                                width: 46.0,
                                height: 46.0,
                                alignment: Alignment.center,
                                child: IconButton(
                                  onPressed: () => showTrackDialog(
                                      context, widget.track, widget.leading),
                                  icon: Icon(Icons.more_vert),
                                  iconSize: 24.0,
                                  splashRadius: 20.0,
                                ),
                              ),
                            if (displayDragHandler)
                              Container(
                                width: 46.0,
                                height: 46.0,
                                alignment: Alignment.center,
                                child: IconButton(
                                  onPressed: () => showTrackDialog(
                                      context, widget.track, widget.leading),
                                  icon: Icon(Icons.more_vert),
                                  iconSize: 24.0,
                                  splashRadius: 20.0,
                                ),
                              ),
                            if (widget.displayDragHandler)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: 12,
                                  ),
                                  ReorderableDragStartListener(
                                    index: widget.index,
                                    child: Container(
                                      width: 22.0,
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        "assets/modern_icons/menu-1.svg",
                                        color: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .color,
                                        width: 22.0,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 36.0,
                                    alignment: Alignment.center,
                                    child: RotatedBox(
                                        quarterTurns: 1,
                                        child: IconButton(
                                          onPressed: () => showTrackDialog(
                                              context,
                                              widget.track,
                                              widget.leading),
                                          icon: SvgPicture.asset(
                                            "assets/modern_icons/more.svg",
                                            color: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .color,
                                            width: Configuration.instance
                                                    .trackListTileHeight *
                                                0.18,
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }
}

Color changeColorSaturation(Color color) =>
    HSLColor.fromColor(color).withSaturation(0.22).toColor();

Color changeColorLightness(Color color) =>
    HSLColor.fromColor(color).withLightness(0.08).toColor();
