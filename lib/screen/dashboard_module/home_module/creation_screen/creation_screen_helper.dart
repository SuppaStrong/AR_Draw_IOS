import 'dart:io';

import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/creation_screen/creation_screen.dart';
import 'package:ar_draw/service/permission_service.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CreationScreenHelper {
  CreationScreenState state;
  List<File> selectedVideos = [];
  bool isAllSelected = false;

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
      final directory = await getExternalStorageDirectory();
      final moviesDir = Directory('${directory?.path}/Movies');
      if (await moviesDir.exists()) {
        videoFiles = moviesDir.listSync().where((file) => file.path.endsWith('.mp4')).map((file) => File(file.path)).toList();
        await generateThumbnails();
        groupVideosByDate();
        state.creationController?.update();
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

  Future<void> generateThumbnails() async {
    for (File videoFile in videoFiles) {
      "Generating thumbnail for ${videoFile.path}".logs();
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 25,
      );
      if (uint8list != null) {
        String thumbnailPath = '${(await getTemporaryDirectory()).path}/${videoFile.uri.pathSegments.last}.jpg';
        File(thumbnailPath).writeAsBytesSync(uint8list);
        videoThumbnails[videoFile] = thumbnailPath;
      }
    }
  }

  void groupVideosByDate() {
    todayVideos.clear();
    yesterdayVideos.clear();
    last7DaysVideos.clear();

    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

    for (File videoFile in videoFiles) {
      DateTime lastModified = videoFile.lastModifiedSync();

      if (lastModified.isAfter(now.subtract(const Duration(days: 1))) && lastModified.isBefore(now.add(const Duration(days: 1)))) {
        todayVideos.add(videoFile);
      } else if (lastModified.isAfter(sevenDaysAgo) && lastModified.isBefore(now.subtract(const Duration(days: 1)))) {
        yesterdayVideos.add(videoFile);
      } else if (lastModified.isAfter(sevenDaysAgo)) {
        last7DaysVideos.add(videoFile);
      }
    }
  }

  void deleteSelectedVideos() async {
    for (var video in selectedVideos) {
      try {
        await video.delete();
        videoFiles.remove(video);
        groupVideosByDate();
      } catch (e) {
        'Error deleting video: $e'.errorLogs();
      }
    }

    selectedVideos.clear();
    state.creationController?.update();
    Get.snackbar('Success', 'Selected videos deleted successfully');
  }
  void toggleVideoSelection(bool isSelected, File? videoFile){
    if (isSelected) {
      selectedVideos.remove(videoFile);
    } else {
      selectedVideos.add(videoFile!);
    }
    state.creationController?.update();
  }
}
