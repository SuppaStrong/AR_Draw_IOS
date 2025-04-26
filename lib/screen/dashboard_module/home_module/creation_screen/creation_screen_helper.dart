import 'dart:io';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/creation_screen/creation_screen.dart';
import 'package:ar_draw/service/permission_service.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';

class CreationScreenHelper {
  CreationScreenState state;
  List<File> selectedVideos = [];
  bool isAllSelected = false;
  bool isGridView = true;

  final Map<File, Duration> _videoDurations = {};

  final Map<File, String> _formattedDurations = {};

  final Set<String> _processingVideos = {};

  CreationScreenHelper(this.state) {
    loadVideos();
  }

  List<File> videoFiles = [];
  Map<File, String> videoThumbnails = {};
  List<File> todayVideos = [];
  List<File> yesterdayVideos = [];
  List<File> last7DaysVideos = [];

  Future<void> loadVideos() async {
    if (await PermissionService.instance.requestStorageOrMediaPermission()) {
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();
      final moviesDir = Directory('${directory?.path}/Movies');

      if (await moviesDir.exists()) {
        videoFiles = moviesDir
            .listSync()
            .where((file) => file.path.endsWith('.mp4'))
            .map((file) => File(file.path))
            .toList();

        await generateThumbnails();

        _preloadAllVideoDurations();

        groupVideosByDate();
        state.creationController?.update();
      } else {
        try {
          await moviesDir.create(recursive: true);
          'Created movies directory'.logs();
        } catch (e) {
          'Error creating directory: $e'.errorLogs();
        }
      }
    } else {
      'Storage permission denied'.logs();
    }
  }

  void selectAllVideos() {
    if (selectedVideos.length == videoFiles.length) {
      isAllSelected = false;
      selectedVideos.clear();
    } else {
      selectedVideos = List.from(videoFiles);
      isAllSelected = true;
    }
    state.creationController?.update();
  }

  void clearSelection() {
    selectedVideos.clear();
    isAllSelected = false;
    state.creationController?.update();
  }

  Future<void> generateThumbnails() async {
    for (File videoFile in videoFiles) {
      if (videoThumbnails.containsKey(videoFile)) continue;

      "Generating thumbnail for ${videoFile.path}".logs();
      try {
        final uint8list = await VideoThumbnail.thumbnailData(
          video: videoFile.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128,
          quality: 25,
        );

        if (uint8list != null) {
          String thumbnailPath =
              '${(await getTemporaryDirectory()).path}/${videoFile.uri.pathSegments.last}.jpg';
          await File(thumbnailPath).writeAsBytes(uint8list);
          videoThumbnails[videoFile] = thumbnailPath;
        }
      } catch (e) {
        'Error generating thumbnail: $e'.errorLogs();
      }
    }
  }

  void groupVideosByDate() {
    todayVideos.clear();
    yesterdayVideos.clear();
    last7DaysVideos.clear();

    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

    for (File videoFile in videoFiles) {
      try {
        DateTime lastModified = videoFile.lastModifiedSync();
        DateTime fileDate = DateTime(
          lastModified.year,
          lastModified.month,
          lastModified.day,
        );
        DateTime today = DateTime(now.year, now.month, now.day);

        if (fileDate.isAtSameMomentAs(today)) {
          todayVideos.add(videoFile);
        } else if (fileDate.isAtSameMomentAs(yesterday)) {
          yesterdayVideos.add(videoFile);
        } else if (lastModified.isAfter(sevenDaysAgo)) {
          last7DaysVideos.add(videoFile);
        }
      } catch (e) {
        'Error processing video date: $e'.errorLogs();
      }
    }
  }

  Future<void> deleteSelectedVideos() async {
    List<File> deletedVideos = [];

    for (var video in selectedVideos) {
      try {
        await video.delete();
        deletedVideos.add(video);
        'Video deleted: ${video.path}'.logs();
      } catch (e) {
        'Error deleting video: $e'.errorLogs();
      }
    }

    for (var video in deletedVideos) {
      videoFiles.remove(video);
      todayVideos.remove(video);
      yesterdayVideos.remove(video);
      last7DaysVideos.remove(video);
      videoThumbnails.remove(video);
      _videoDurations.remove(video);
      _formattedDurations.remove(video);
    }

    selectedVideos.clear();
    isAllSelected = false;

    state.creationController?.update();
    Get.snackbar(
      'Success',
      '${deletedVideos.length} video${deletedVideos.length != 1 ? 's' : ''} deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void toggleVideoSelection(bool isSelected, File? videoFile) {
    if (videoFile == null) return;

    if (isSelected) {
      selectedVideos.remove(videoFile);
    } else {
      selectedVideos.add(videoFile);
    }

    isAllSelected =
        selectedVideos.length == videoFiles.length && videoFiles.isNotEmpty;
    state.creationController?.update();
  }

  void handleVideoTap(File videoFile) {
    if (selectedVideos.isNotEmpty) {
      bool isSelected = selectedVideos.contains(videoFile);
      toggleVideoSelection(isSelected, videoFile);
    } else {
      if (videoThumbnails.containsKey(videoFile)) {
        state.playVideo(videoFile, videoThumbnails[videoFile]!);
      }
    }
  }

  void handleVideoLongPress(File videoFile) {
    if (selectedVideos.isEmpty) {
      toggleVideoSelection(false, videoFile);
    }
  }

  void toggleViewMode() {
    isGridView = !isGridView;
    state.creationController?.update();
  }

  Future<void> _preloadAllVideoDurations() async {
    for (final videoFile in videoFiles) {
      _loadVideoDuration(videoFile);
    }
  }

  Future<void> _loadVideoDuration(File videoFile) async {
    if (_videoDurations.containsKey(videoFile) ||
        _processingVideos.contains(videoFile.path)) {
      return;
    }

    _processingVideos.add(videoFile.path);

    try {
      final VideoPlayerController controller =
          VideoPlayerController.file(videoFile);
      await controller.initialize();
      final Duration duration = controller.value.duration;

      _videoDurations[videoFile] = duration;
      _formattedDurations[videoFile] = _formatDuration(duration);

      state.creationController?.update();

      await controller.dispose();
    } catch (e) {
      'Error getting video duration for ${videoFile.path}: $e'.errorLogs();

      _videoDurations[videoFile] = const Duration(seconds: 0);
      _formattedDurations[videoFile] = "00:00";
    } finally {
      _processingVideos.remove(videoFile.path);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  String getVideoDuration(File videoFile) {
    if (_formattedDurations.containsKey(videoFile)) {
      return _formattedDurations[videoFile]!;
    }

    if (_videoDurations.containsKey(videoFile)) {
      final formatted = _formatDuration(_videoDurations[videoFile]!);
      _formattedDurations[videoFile] = formatted;
      return formatted;
    }

    if (!_processingVideos.contains(videoFile.path)) {
      _loadVideoDuration(videoFile);
    }

    return "00:00";
  }
}
