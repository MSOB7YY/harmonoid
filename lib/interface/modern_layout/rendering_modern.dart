/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:media_library/media_library.dart';
import 'package:media_engine/media_engine.dart' hide Media;
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/interface/file_info_screen.dart';
import 'package:harmonoid/interface/collection/playlist.dart';
import 'package:harmonoid/interface/edit_details_screen.dart';
import 'package:harmonoid/interface/directory_picker_screen.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_album.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/utils/widgets.dart';
export 'package:harmonoid/utils/extensions.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/constants/language.dart';

Future<void> showAddToPlaylistDialogModern(
  BuildContext context,
  List<Track> tracks, {
  bool elevated = false,
}) {
  final playlists = Collection.instance.playlists.toList();
  if (isDesktop) {
    return showDialog(
      context: context,
      builder: (subContext) => AlertDialog(
        contentPadding: EdgeInsets.only(top: 20.0),
        title: Text(Language.instance.PLAYLIST_ADD_DIALOG_TITLE),
        content: Container(
          height: 480.0,
          width: 512.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                height: 1.0,
              ),
              Expanded(
                child: CustomListViewBuilder(
                  itemExtents: List.generate(
                    playlists.length,
                    (index) => 64.0 + 9.0,
                  ),
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, i) => PlaylistTile(
                    playlist: playlists[i],
                    onTap: () async {
                      await Collection.instance.playlistAddTracks(
                        playlists[i],
                        tracks,
                      );
                      Navigator.of(subContext).pop();
                    },
                  ),
                ),
              ),
              Divider(
                height: 1.0,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(subContext).pop,
            child: Text(Language.instance.CANCEL),
          ),
        ],
      ),
    );
  } else {
    if (elevated) {
      return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (context) => Card(
          margin: EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            bottom: kBottomNavigationBarHeight + 8.0,
          ),
          elevation: kDefaultHeavyElevation,
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.8,
            expand: false,
            builder: (context, controller) => ListView.builder(
              padding: EdgeInsets.zero,
              controller: controller,
              shrinkWrap: true,
              itemCount: playlists.length,
              itemBuilder: (context, i) {
                return PlaylistTile(
                  playlist: playlists[i],
                  onTap: () async {
                    await Collection.instance.playlistAddTracks(
                      playlists[i],
                      tracks,
                    );
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ),
      );
    }
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, controller) => ListView.builder(
          padding: EdgeInsets.zero,
          controller: controller,
          shrinkWrap: true,
          itemCount: playlists.length,
          itemBuilder: (context, i) {
            return PlaylistTile(
              playlist: playlists[i],
              onTap: () async {
                await Collection.instance.playlistAddTracks(
                  playlists[i],
                  tracks,
                );
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }
}

// Simple method to get total album duration in seconds
int getTotalTracksDuration({Album? album, required List<Track> tracks}) {
  int totalAlbumDuration = 0;
  for (int j = 0; j < tracks.length; j++) {
    totalAlbumDuration += tracks[j].duration!.inSeconds;
  }
  return totalAlbumDuration;
}

String getTotalTracksDurationFormatted(
    {Album? album, required List<Track> tracks}) {
  int totalAlbumDuration = getTotalTracksDuration(tracks: tracks);
  String formattedTotalAlbumDuration =
      "${Duration(seconds: totalAlbumDuration).inHours == 0 ? "" : "${Duration(seconds: totalAlbumDuration).inHours} h "}${Duration(seconds: totalAlbumDuration).inMinutes.remainder(60) == 0 ? "" : "${Duration(seconds: totalAlbumDuration).inMinutes.remainder(60) + 1} min"}";
  return formattedTotalAlbumDuration;
}

// Simple method to get all artists inside an album
List<String> getArtistsInsideAlbum(
    {required Album album, required List<Track> tracks}) {
  List<String> allArtistsInsideAlbum = [];

  for (int j = 0; j < tracks.length; j++) {
    allArtistsInsideAlbum += tracks[j].trackArtistNames;
  }
  List<String> allArtistsInsideAlbumNoDuplicate =
      allArtistsInsideAlbum.toSet().toList();
  return allArtistsInsideAlbumNoDuplicate;
}

Future<Iterable<Color>?> getAlbumColorModern(
    {required Media media, context}) async {
  Iterable<Color>? palette;
  final ImageProvider<Object> resizedImage = ResizeImage(
      getAlbumArt(
        media,
        // small: true,
        // cacheWidth: MediaQuery.of(context).devicePixelRatio ~/ 1,
      ),
      height: 10,
      width: null);

  final result = await PaletteGenerator.fromImageProvider(
    resizedImage,
  ).then((result) {
    palette = result.colors;
    return palette;
  });

  return result;
}

Future<Color?> getAlbumColorSingleModern(
    {required Media media, context}) async {
  Color? palette;
  final ImageProvider<Object> resizedImage = ResizeImage(
      getAlbumArt(
        media,
        // small: true,
        // cacheWidth: MediaQuery.of(context).devicePixelRatio ~/ 1,
      ),
      height: 10,
      width: null);

  final result = await PaletteGenerator.fromImageProvider(
    resizedImage,
  ).then((result) {
    palette = result.vibrantColor?.color ??
        result.darkMutedColor?.color ??
        result.mutedColor?.color;
    return palette;
  });

  return result;
}

Color getAlbumColorModifiedModern(List<Color>? value) {
  final Color color;
  if ((value?.length ?? 0) > 9) {
    color = Color.alphaBlend(
        value?.first.withAlpha(140) ?? Colors.transparent,
        Color.alphaBlend(
            value?.elementAt(7).withAlpha(155) ?? Colors.transparent,
            value?.elementAt(9) ?? Colors.transparent));
  } else {
    color = Color.alphaBlend(value?.last.withAlpha(50) ?? Colors.transparent,
        value?.first ?? Colors.transparent);
  }
  HSLColor hslColor = HSLColor.fromColor(color);
  Color colorDelightened;
  if (hslColor.lightness > 0.65) {
    hslColor = hslColor.withLightness(0.55);
    colorDelightened = hslColor.toColor();
  } else {
    colorDelightened = color;
  }
  colorDelightened =
      Color.alphaBlend(Colors.white.withAlpha(20), colorDelightened);
  return colorDelightened;
}

// Method to Get All Album Images Height for StaggeredGridView

// Future<int> getAllAlbumsImageHeight({required List<Album> albums}) async {
//   int imagesHeight = 0;

//   for (int j = 0; j < albums.length; j++) {
//     Completer<ImageInfo> completer = Completer();
//     Image albumImage = Image(
//       image: getAlbumArt(albums[j]),
//     );
//     albumImage.image
//         .resolve(new ImageConfiguration())
//         .addListener(ImageStreamListener((ImageInfo info, bool _) {
//       completer.complete(info);
//     }));
//     ImageInfo imageInfo = await completer.future;
//     int finalheight = imageInfo.image.height;
//     imagesHeight += finalheight;
//   }
//   print("images height: ${imagesHeight}");
//   // print("length: ${albums.length}");

//   int averageImagesHeight = imagesHeight ~/ (albums.length * 2) ~/ 2.1;
//   print("length: ${averageImagesHeight}");
//   return Future.value(averageImagesHeight);
// }

List<PopupMenuItem<int>> albumPopupMenuItemsModern(
  Album album,
  BuildContext context,
) {
  return [
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 0,
      child: ListTile(
        leading: Icon(
          Platform.isWindows ? FluentIcons.play_24_regular : Icons.play_circle,
        ),
        title: Text(
          Language.instance.PLAY,
          style: isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 1,
      child: ListTile(
        leading: Icon(
          Platform.isWindows
              ? FluentIcons.arrow_shuffle_24_regular
              : Icons.shuffle,
        ),
        title: Text(
          Language.instance.SHUFFLE,
          style: isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 2,
      child: ListTile(
        leading: Icon(
          Platform.isWindows ? FluentIcons.delete_16_regular : Icons.delete,
        ),
        title: Text(
          Language.instance.DELETE,
          style: isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 3,
      child: ListTile(
        leading: Icon(
          Platform.isWindows
              ? FluentIcons.music_note_2_16_regular
              : Icons.queue_music,
        ),
        title: Text(
          Language.instance.ADD_TO_NOW_PLAYING,
          style: isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 4,
      child: ListTile(
        leading: Platform.isWindows
            ? Icon(FluentIcons.next_16_filled)
            : SvgPicture.asset(
                "assets/modern_icons/next.svg",
                color: Theme.of(context).iconTheme.color,
              ),
        title: Text(
          "Queue Next",
          style: isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
        ),
      ),
    ),
    if (!isDesktop && !MobileNowPlayingController.instance.isHidden)
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        child: SizedBox(height: kMobileNowPlayingBarHeight),
      ),
  ];
}

Future<void> albumPopupMenuHandleModern(
  BuildContext context,
  Album album,
  int? result,
) async {
  final tracks = album.tracks.toList();
  tracks.sort(
    (first, second) =>
        first.discNumber.compareTo(second.discNumber) * 100000000 +
        first.trackNumber.compareTo(second.trackNumber) * 1000000 +
        first.trackName.compareTo(second.trackName) * 10000 +
        first.trackArtistNames
                .join()
                .compareTo(second.trackArtistNames.join()) *
            100 +
        first.uri.toString().compareTo(second.uri.toString()),
  );
  if (result != null) {
    switch (result) {
      case 0:
        await Playback.instance.open(tracks);
        break;
      case 1:
        tracks.shuffle();
        await Playback.instance.open(tracks);
        break;
      case 2:
        if (Platform.isAndroid) {
          final sdk = StorageRetriever.instance.version;
          if (sdk >= 30) {
            // No [AlertDialog] required for confirmation.
            // Android 11 or higher (API level 30) will ask for permissions from the user before deletion.
            await Collection.instance.delete(album);
            while (Navigator.of(context).canPop()) {
              await Navigator.of(context).maybePop();
            }
            if (floatingSearchBarController.isOpen) {
              floatingSearchBarController.close();
            }
            return;
          }
        }
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              Language.instance.COLLECTION_ALBUM_DELETE_DIALOG_HEADER,
            ),
            content: Text(
              Language.instance.COLLECTION_ALBUM_DELETE_DIALOG_BODY.replaceAll(
                'NAME',
                album.albumName,
              ),
              style: Theme.of(ctx).textTheme.displaySmall,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Collection.instance.delete(album);
                  await Navigator.of(ctx).maybePop();
                  while (Navigator.of(context).canPop()) {
                    await Navigator.of(context).maybePop();
                  }
                  if (floatingSearchBarController.isOpen) {
                    floatingSearchBarController.close();
                  }
                },
                child: Text(Language.instance.YES),
              ),
              TextButton(
                onPressed: Navigator.of(ctx).pop,
                child: Text(Language.instance.NO),
              ),
            ],
          ),
        );
        break;
      case 3:
        await Playback.instance.add(tracks);
        break;
      case 4:
        await Playback.instance.insertAt(tracks, Playback.instance.index + 1);
        break;
    }
  }
}

void showTrackDialog(BuildContext context, Track track,
    [Widget? leading]) async {
  int? result;
  Iterable<Color>? palette;
  final colors = await PaletteGenerator.fromImageProvider(
    getAlbumArt(track, small: true),
  );
  palette = colors.colors;
  final colorDelightened = getAlbumColorModifiedModern(palette!.toList());
  await showDialog(
    context: context,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
      child: Dialog(
        clipBehavior: Clip.antiAlias,
        backgroundColor: Color.alphaBlend(colorDelightened.withAlpha(20),
            Theme.of(context).popupMenuTheme.color!),
        insetPadding: EdgeInsets.all(30),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(
                20.0 * Configuration.instance.borderRadiusMultiplier))),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                highlightColor: Color.fromARGB(60, 0, 0, 0),
                splashColor: Colors.transparent,
                onTap: () async {
                  Iterable<Color>? palette;
                  late final Album album;
                  for (final item in Collection.instance.albums) {
                    if ((item.albumName == track.albumName &&
                            item.year == track.year) ||
                        (item.albumName == track.albumName &&
                            item.albumArtistName == track.albumArtistName)) {
                      album = item;
                      break;
                    }
                  }
                  if (isMobile) {
                    final result = await PaletteGenerator.fromImageProvider(
                      getAlbumArt(album, small: true),
                    );
                    palette = result.colors;
                  }
                  Playback.instance.interceptPositionChangeRebuilds = true;
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FadeThroughTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        child: AlbumScreenModern(
                          album: album,
                          palette: palette,
                        ),
                      ),
                    ),
                  );
                  Timer(
                    const Duration(milliseconds: 400),
                    () {
                      Playback.instance.interceptPositionChangeRebuilds = false;
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 16.0),
                      leading ??
                          CustomTrackThumbnailModern(
                            scale: 1,
                            borderRadius: 8,
                            blur: 2,
                            track: track,
                          ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(track.trackArtistNames.take(5).join(', '),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                      fontSize: 17,
                                      color: Color.alphaBlend(
                                          colorDelightened.withAlpha(40),
                                          Theme.of(context)
                                              .textTheme
                                              .displayLarge!
                                              .color!),
                                    )),
                            const SizedBox(
                              height: 1.0,
                            ),
                            Text(
                              track.trackName.overflow,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                    fontSize: 14,
                                    color: Color.alphaBlend(
                                        colorDelightened.withAlpha(80),
                                        Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .color!),
                                  ),
                            ),
                            const SizedBox(
                              height: 1.0,
                            ),
                            Text(
                              track.albumName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                    fontSize: 13,
                                    color: Color.alphaBlend(
                                        colorDelightened.withAlpha(40),
                                        Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .color!),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 16.0,
                      ),
                      SvgPicture.asset(
                        "assets/modern_icons/arrow-right-3.svg",
                        color: Color.alphaBlend(colorDelightened.withAlpha(150),
                            Theme.of(context).iconTheme.color!),
                      ),
                      const SizedBox(
                        width: 16.0,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: Theme.of(context).dividerColor.withAlpha(40),
                thickness: 1,
                height: 0,
              ),
              const SizedBox(height: 6.0),
              Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    trackPopupMenuItemsModern(track, context, colorDelightened)
                        .map((item) {
                  return PopupMenuItem<int>(
                    value: item.value,
                    onTap: () {
                      result = item.value;
                    },
                    child: item.child,
                  );
                }).toList(),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    ),
  );
  await trackPopupMenuHandleModern(
    context,
    track,
    result,
    // Only used in [SearchTab].
    recursivelyPopNavigatorOnDeleteIf: () => true,
  );
}

List<PopupMenuItem<int>> trackPopupMenuItemsModern(
  Track track,
  BuildContext context,
  Color trackColor,
) {
  String iconsDir = "assets/modern_icons";
  trackColor = Color.alphaBlend(
      trackColor.withAlpha(150), Theme.of(context).iconTheme.color!);
  final TextStyle textStyle = Theme.of(context)
      .textTheme
      .displayMedium!
      .copyWith(
          color: Color.alphaBlend(trackColor.withAlpha(80),
              Theme.of(context).textTheme.displayMedium!.color!));
  return [
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 0,
      child: ListTile(
        leading: Platform.isWindows
            ? Icon(FluentIcons.delete_16_regular)
            : SvgPicture.asset("$iconsDir/music-square-remove.svg",
                color: trackColor),
        title: Text(
          Language.instance.DELETE,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    if (Platform.isAndroid || Platform.isIOS)
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 1,
        child: ListTile(
          leading: Platform.isWindows
              ? Icon(FluentIcons.share_16_regular)
              : SvgPicture.asset("$iconsDir/share.svg", color: trackColor),
          title: Text(
            Language.instance.SHARE,
            style: isDesktop
                ? Theme.of(context).textTheme.headlineMedium
                : textStyle,
          ),
        ),
      ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 10,
      child: ListTile(
        leading: Platform.isWindows
            ? Icon(FluentIcons.music_note_2_16_regular)
            : SvgPicture.asset(
                "assets/modern_icons/next.svg",
                color: trackColor,
              ),
        title: Text(
          "Queue Next",
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 3,
      child: ListTile(
        leading: Platform.isWindows
            ? Icon(FluentIcons.music_note_2_16_regular)
            : Icon(
                Iconsax.play_add,
                color: trackColor,
              ),
        title: Text(
          Language.instance.ADD_TO_NOW_PLAYING,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 2,
      child: ListTile(
        leading: Platform.isWindows
            ? Icon(FluentIcons.list_16_regular)
            : SvgPicture.asset("$iconsDir/music-playlist.svg",
                color: trackColor),
        title: Text(
          Language.instance.ADD_TO_PLAYLIST,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    // TODO: Add Android support.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 5,
        child: ListTile(
          leading: Icon(Platform.isWindows
              ? FluentIcons.folder_24_regular
              : Icons.folder),
          title: Text(
            Language.instance.SHOW_IN_FILE_MANAGER,
            style: isDesktop
                ? Theme.of(context).textTheme.headlineMedium
                : textStyle,
          ),
        ),
      ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 6,
      child: ListTile(
        leading: Platform.isWindows
            ? Icon(FluentIcons.edit_24_regular)
            : SvgPicture.asset("$iconsDir/edit.svg", color: trackColor),
        title: Text(
          Language.instance.EDIT_DETAILS,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 4,
      child: ListTile(
        leading: Platform.isWindows
            ? Icon(FluentIcons.album_24_regular)
            : SvgPicture.asset("$iconsDir/music-dashboard.svg",
                color: trackColor),
        title: Text(
          Language.instance.SHOW_ALBUM,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 7,
      child: ListTile(
        leading: Platform.isWindows
            ? Icon(FluentIcons.info_24_regular)
            : SvgPicture.asset("$iconsDir/info-circle.svg", color: trackColor),
        title: Text(
          Language.instance.FILE_INFORMATION,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    if (Lyrics.instance.hasLRCFile(track))
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 9,
        child: ListTile(
          leading: Platform.isWindows
              ? Icon(FluentIcons.clear_formatting_24_regular)
              : SvgPicture.asset("$iconsDir/note-remove.svg",
                  color: trackColor),
          title: Text(
            Language.instance.CLEAR_LRC_FILE,
            style: isDesktop
                ? Theme.of(context).textTheme.headlineMedium
                : textStyle,
          ),
        ),
      )
    else
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 8,
        child: ListTile(
          leading: Platform.isWindows
              ? Icon(FluentIcons.text_font_24_regular)
              : SvgPicture.asset("$iconsDir/note-2.svg", color: trackColor),
          title: Text(
            Language.instance.SET_LRC_FILE,
            style: isDesktop
                ? Theme.of(context).textTheme.headlineMedium
                : textStyle,
          ),
        ),
      ),
  ];
}

Future<void> trackPopupMenuHandleModern(
  BuildContext context,
  Track track,
  int? result, {
  bool Function()? recursivelyPopNavigatorOnDeleteIf,
}) async {
  if (result != null) {
    switch (result) {
      case 0:
        if (Platform.isAndroid) {
          final sdk = StorageRetriever.instance.version;
          if (sdk >= 30) {
            // No [AlertDialog] required for confirmation.
            // Android 11 or higher (API level 30) will ask for permissions from the user before deletion.
            await Collection.instance.delete(track);
            if (recursivelyPopNavigatorOnDeleteIf != null) {
              if (recursivelyPopNavigatorOnDeleteIf()) {
                while (Navigator.of(context).canPop()) {
                  await Navigator.of(context).maybePop();
                }
                if (floatingSearchBarController.isOpen) {
                  floatingSearchBarController.close();
                }
              }
            }
            return;
          }
        }
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              Language.instance.COLLECTION_TRACK_DELETE_DIALOG_HEADER,
            ),
            content: Text(
              Language.instance.COLLECTION_TRACK_DELETE_DIALOG_BODY.replaceAll(
                'NAME',
                track.trackName,
              ),
              style: Theme.of(ctx).textTheme.displaySmall,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Collection.instance.delete(track);
                  await Navigator.of(ctx).maybePop();
                  if (recursivelyPopNavigatorOnDeleteIf != null) {
                    if (recursivelyPopNavigatorOnDeleteIf()) {
                      while (Navigator.of(context).canPop()) {
                        await Navigator.of(context).maybePop();
                      }
                      if (floatingSearchBarController.isOpen) {
                        floatingSearchBarController.close();
                      }
                    }
                  }
                },
                child: Text(Language.instance.YES),
              ),
              TextButton(
                onPressed: Navigator.of(ctx).pop,
                child: Text(Language.instance.NO),
              ),
            ],
          ),
        );
        break;
      case 1:
        if (track.uri.isScheme('FILE')) {
          await Share.shareFiles(
            [track.uri.toFilePath()],
            subject: '${track.trackName} • ${[
              '',
              kUnknownArtist,
            ].contains(track.albumArtistName) ? track.trackArtistNames.take(2).join(', ') : track.albumArtistName}',
          );
        } else {
          await Share.share(
            '${track.trackName} • ${[
              '',
              kUnknownArtist,
            ].contains(track.albumArtistName) ? track.trackArtistNames.take(2).join(', ') : track.albumArtistName} • ${track.uri.toString()}',
          );
        }
        break;
      case 2:
        await showAddToPlaylistDialogModern(context, [track]);
        break;
      case 10:
        Playback.instance.insertAt([track], Playback.instance.index + 1);
        break;
      case 3:
        Playback.instance.add([track]);
        break;
      case 4:
        {
          Iterable<Color>? palette;
          late final Album album;
          for (final item in Collection.instance.albums) {
            // one more check for cases when album and the track are not in the same year
            if ((item.albumName == track.albumName &&
                    item.year == track.year) ||
                (item.albumName == track.albumName &&
                    item.albumArtistName == track.albumArtistName)) {
              album = item;
              break;
            }
          }
          if (isMobile) {
            final result = await PaletteGenerator.fromImageProvider(
              getAlbumArt(album, small: true),
            );
            palette = result.colors;
          }
          Playback.instance.interceptPositionChangeRebuilds = true;
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: AlbumScreenModern(
                  album: album,
                  palette: palette,
                ),
              ),
            ),
          );
          Timer(
            const Duration(milliseconds: 400),
            () {
              Playback.instance.interceptPositionChangeRebuilds = false;
            },
          );
          break;
        }
      case 5:
        File(track.uri.toFilePath()).explore_();
        break;
      case 6:
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: EditDetailsScreen(track: track),
            ),
          ),
        );
        break;
      case 7:
        await FileInfoScreen.show(
          context,
          uri: track.uri,
        );
        break;
      case 8:
        final file = await pickFile(
          label: 'LRC',
          // Compatiblitity issues with Android 5.0. SDK 21.
          extensions: Platform.isAndroid ? null : ['lrc'],
        );
        if (file != null) {
          final added = await Lyrics.instance.addLRCFile(
            track,
            file,
          );
          if (!added) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).cardTheme.color,
                title: Text(
                  Language.instance.ERROR,
                ),
                content: Text(
                  Language.instance.CORRUPT_LRC_FILE,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                actions: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(Language.instance.OK),
                  ),
                ],
              ),
            );
          }
        }
        break;
      case 9:
        Lyrics.instance.removeLRCFile(track);
        break;
    }
  }
}

class CustomTrackThumbnailModern extends StatelessWidget {
  CustomTrackThumbnailModern(
      {super.key,
      this.child,
      this.scale = 1.0,
      this.borderRadius = 0.0,
      this.blur = 0.0,
      required this.track});

  final Widget? child;
  final double scale;
  final double borderRadius;
  final double blur;
  final Track track;
  @override
  Widget build(BuildContext context) {
    final extImageChild = ExtendedImage(
      image: Image(image: getAlbumArt(track, small: true)).image,
      fit: BoxFit.cover,
      width: Configuration.instance.forceSquaredTrackThumbnail
          ? MediaQuery.of(context).size.width
          : null,
      height: Configuration.instance.forceSquaredTrackThumbnail
          ? MediaQuery.of(context).size.width
          : null,
    );

    return Configuration.instance.enableGlowEffect
        ? SizedBox(
            width: Configuration.instance.trackThumbnailSizeinList * scale,
            height: Configuration.instance.trackThumbnailSizeinList * scale,
            child: Center(
              child: Configuration.instance.borderRadiusMultiplier == 0.0
                  ? DropShadow(
                      borderRadius: borderRadius *
                          Configuration.instance.borderRadiusMultiplier,
                      blurRadius: blur,
                      spread: 0.8,
                      offset: Offset(0, 1),
                      child: child ?? extImageChild,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius *
                          Configuration.instance.borderRadiusMultiplier),
                      child: DropShadow(
                        borderRadius: borderRadius *
                            Configuration.instance.borderRadiusMultiplier,
                        blurRadius: blur,
                        spread: 0.8,
                        offset: Offset(0, 1),
                        child: child ?? extImageChild,
                      ),
                    ),
            ),
          )
        : SizedBox(
            width: Configuration.instance.trackThumbnailSizeinList * scale,
            height: Configuration.instance.trackThumbnailSizeinList * scale,
            child: Center(
              child: Configuration.instance.borderRadiusMultiplier == 0.0
                  ? child ?? extImageChild
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius *
                          Configuration.instance.borderRadiusMultiplier),
                      child: child ?? extImageChild,
                    ),
            ),
          );
  }
}

class CustomSmallBlurryBoxModern extends StatelessWidget {
  final Widget? child;
  final double height;
  final double width;
  const CustomSmallBlurryBoxModern(
      {super.key, this.child, this.height = 20.0, this.width = 25.0});

  @override
  Widget build(BuildContext context) {
    return BlurryContainer(
        height: height,
        width: width,
        blur: Configuration.instance.enableBlurEffect ? 5 : 0,
        padding: EdgeInsets.symmetric(horizontal: 6),
        borderRadius: BorderRadius.circular(
            6 * Configuration.instance.borderRadiusMultiplier),
        color: Configuration.instance.enableBlurEffect
            ? Theme.of(context).brightness == Brightness.dark
                ? Colors.black12
                : Colors.white24
            : Theme.of(context).brightness == Brightness.dark
                ? Colors.black54
                : Colors.white70,
        child: Center(
          child: child,
        ));
  }
}
