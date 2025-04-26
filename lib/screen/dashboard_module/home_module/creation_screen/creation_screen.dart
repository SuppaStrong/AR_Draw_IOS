import 'dart:io';

import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/creation_controller.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/video_player_screen/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';

import 'creation_screen_helper.dart';

class CreationScreen extends StatefulWidget {
  const CreationScreen({super.key});

  @override
  State<CreationScreen> createState() => CreationScreenState();
}

class CreationScreenState extends State<CreationScreen>
    with SingleTickerProviderStateMixin {
  CreationScreenHelper? creationScreenHelper;
  CreationController? creationController;
  late AnimationController _animationController;
  late Animation<double> _selectionAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _selectionAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    creationScreenHelper = CreationScreenHelper(this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void playVideo(File videoFile, String thumbnailPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoFile: videoFile,
          thumbnailPath: thumbnailPath,
        ),
      ),
    );
  }

  void updateSelectionAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (creationScreenHelper!.selectedVideos.isNotEmpty) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    "Current screen --> $runtimeType".logs();

    updateSelectionAnimation();

    return GetBuilder(
        init: CreationController(),
        builder: (CreationController controller) {
          creationController = controller;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(),
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: buildVideoList(),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomBar(),
                ),
              ],
            ),
          );
        });
  }

  PreferredSizeWidget _buildAppBar() {
    final bool isSelectionMode =
        creationScreenHelper!.selectedVideos.isNotEmpty;
    final int selectedCount = creationScreenHelper!.selectedVideos.length;
    final int totalCount = creationScreenHelper?.videoFiles.length ?? 0;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      leading: isSelectionMode
          ? IconButton(
              icon: const Icon(Icons.close),
              color: Colors.black87,
              onPressed: () {
                creationScreenHelper!.clearSelection();
              },
            )
          : null,
      title: isSelectionMode
          ? Text(
              "$selectedCount selected",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            )
          : const Text(
              AppStringConstant.creation,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
      actions: [
        if (isSelectionMode)
          TextButton(
            onPressed: () => creationScreenHelper!.selectAllVideos(),
            child: Text(
              creationScreenHelper!.isAllSelected
                  ? AppStringConstant.deselectAll
                  : AppStringConstant.selectAll,
              style: const TextStyle(
                color: AppColorConstant.appDeepPurple,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (!isSelectionMode && totalCount > 0)
          IconButton(
            icon: Icon(
              creationScreenHelper!.isGridView
                  ? CupertinoIcons.list_bullet
                  : CupertinoIcons.square_grid_2x2,
              color: AppColorConstant.appDeepPurple,
            ),
            onPressed: () {
              creationScreenHelper!.toggleViewMode();
            },
          ),
      ],
    );
  }

  Widget buildVideoList() {
    if (creationScreenHelper?.videoFiles.isEmpty ?? true) {
      return _buildEmptyState();
    } else {
      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          if (creationScreenHelper?.todayVideos.isNotEmpty == true)
            buildCategoryView(
                creationScreenHelper?.todayVideos, AppStringConstant.today),
          if (creationScreenHelper?.yesterdayVideos.isNotEmpty == true)
            buildCategoryView(creationScreenHelper?.yesterdayVideos,
                AppStringConstant.yesterday),
          if (creationScreenHelper?.last7DaysVideos.isNotEmpty == true)
            buildCategoryView(creationScreenHelper?.last7DaysVideos,
                AppStringConstant.last7Days),
        ],
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColorConstant.appLightPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: AppImageAsset(
                image: AppAsset.icNoData,
                width: 60,
                height: 60,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const AppText(
            AppStringConstant.noVideos,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: const Text(
              "Your AR drawing recordings will appear here",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black38,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () {
              RouteHelper.instance.gotoBack();
            },
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColorConstant.appDeepPurple,
            ),
            label: const Text(
              "Create New Recording",
              style: TextStyle(
                color: AppColorConstant.appDeepPurple,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: AppColorConstant.appLightPurple.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryView(List<File>? videos, String title) {
    if (videos == null || videos.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColorConstant.appLightPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getCategoryIcon(title),
                    size: 14,
                    color: AppColorConstant.appDeepPurple,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Text(
                  "${videos.length} videos",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          creationScreenHelper!.isGridView
              ? _buildGridVideos(videos)
              : _buildListVideos(videos),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildGridVideos(List<File> videos) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (context, index) {
        File videoFile = videos[index];
        String? thumbnailPath =
            creationScreenHelper!.videoThumbnails[videoFile];

        if (thumbnailPath == null) return const SizedBox.shrink();

        bool isSelected =
            creationScreenHelper?.selectedVideos.contains(videoFile) ?? false;

        return _buildVideoTile(videoFile, thumbnailPath, isSelected);
      },
    );
  }

  Widget _buildListVideos(List<File> videos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        File videoFile = videos[index];
        String? thumbnailPath =
            creationScreenHelper!.videoThumbnails[videoFile];

        if (thumbnailPath == null) return const SizedBox.shrink();

        bool isSelected =
            creationScreenHelper?.selectedVideos.contains(videoFile) ?? false;

        return _buildVideoListTile(videoFile, thumbnailPath, isSelected);
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category == AppStringConstant.today) {
      return Icons.today;
    } else if (category == AppStringConstant.yesterday) {
      return Icons.history;
    } else {
      return Icons.date_range;
    }
  }

  Widget _buildVideoTile(
      File videoFile, String thumbnailPath, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (creationScreenHelper!.selectedVideos.isNotEmpty) {
          creationScreenHelper?.toggleVideoSelection(isSelected, videoFile);
        } else {
          playVideo(videoFile, thumbnailPath);
        }
      },
      onLongPress: () {
        if (creationScreenHelper!.selectedVideos.isEmpty) {
          creationScreenHelper?.toggleVideoSelection(isSelected, videoFile);

          updateSelectionAnimation();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    width: isSelected ? 2 : 1,
                    color: isSelected
                        ? AppColorConstant.appDeepPurple
                        : Colors.transparent,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: AppImageAsset(
                      image: thumbnailPath,
                      isFile: true,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColorConstant.appDeepPurple.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              if (creationScreenHelper!.selectedVideos.isEmpty)
                Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                top: 10,
                right: 10,
                child: AnimatedOpacity(
                  opacity:
                      creationScreenHelper!.selectedVideos.isNotEmpty ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColorConstant.appDeepPurple
                          : Colors.white,
                      border: Border.all(
                        width: 2,
                        color: isSelected
                            ? AppColorConstant.appDeepPurple
                            : Colors.grey.shade300,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        creationScreenHelper!.getVideoDuration(videoFile),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.volume_up,
                        color: Colors.white.withOpacity(0.8),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoListTile(
      File videoFile, String thumbnailPath, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColorConstant.appDeepPurple
              : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? AppColorConstant.appLightPurple.withOpacity(0.1)
            : Colors.white,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (creationScreenHelper!.selectedVideos.isNotEmpty) {
            creationScreenHelper?.toggleVideoSelection(isSelected, videoFile);
          } else {
            playVideo(videoFile, thumbnailPath);
          }
        },
        onLongPress: () {
          if (creationScreenHelper!.selectedVideos.isEmpty) {
            creationScreenHelper?.toggleVideoSelection(isSelected, videoFile);

            updateSelectionAnimation();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: AppImageAsset(
                        image: thumbnailPath,
                        isFile: true,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (creationScreenHelper!.selectedVideos.isEmpty)
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AR Drawing ${videoFile.path.split('/').last}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Duration: ${creationScreenHelper!.getVideoDuration(videoFile)}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Created on: ${_getFormattedDate(videoFile.lastModifiedSync())}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (creationScreenHelper!.selectedVideos.isNotEmpty)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColorConstant.appDeepPurple
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? AppColorConstant.appDeepPurple
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildBottomBar() {
    return AnimatedBuilder(
      animation: _selectionAnimation,
      builder: (context, child) {
        return Visibility(
          visible: creationScreenHelper!.selectedVideos.isNotEmpty,
          child: SizeTransition(
            sizeFactor: _selectionAnimation,
            axisAlignment: -1.0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, -3),
                    spreadRadius: 1,
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColorConstant.appLightPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "${creationScreenHelper!.selectedVideos.length} videos selected",
                      style: const TextStyle(
                        color: AppColorConstant.appDeepPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.share_rounded,
                          label: "Share",
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4776E6),
                              Color(0xFF8E54E9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: () {
                            if (creationScreenHelper!
                                .selectedVideos.isNotEmpty) {
                              shareSelectedVideos();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.save_alt_rounded,
                          label: "Save",
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF11998E),
                              Color(0xFF38EF7D),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: () {
                            if (creationScreenHelper!
                                .selectedVideos.isNotEmpty) {
                              saveSelectedVideosToGallery();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.delete_outline_rounded,
                          label: "Delete",
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF416C),
                              Color(0xFFFF4B2B),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: () {
                            if (creationScreenHelper!
                                .selectedVideos.isNotEmpty) {
                              deleteDialog();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withOpacity(0.1),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.last.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void shareSelectedVideos() async {
    if (creationScreenHelper!.selectedVideos.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColorConstant.appDeepPurple,
        ),
      ),
    );

    try {
      final List<XFile> files = creationScreenHelper!.selectedVideos
          .map((file) => XFile(file.path))
          .toList();

      await Share.shareXFiles(
        files,
        text: 'Check out my new ${files.length} AR Drawing videos',
        subject: 'AR Drawing Videos',
      );
    } catch (e) {
      'Error sharing videos: $e'.errorLogs();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error sharing videos'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> saveSelectedVideosToGallery() async {
    if (creationScreenHelper!.selectedVideos.isEmpty) return;

    final int totalVideos = creationScreenHelper!.selectedVideos.length;
    int savedCount = 0;
    int failedCount = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Saving Videos'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (savedCount + failedCount) / totalVideos,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColorConstant.appDeepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Saving video ${savedCount + failedCount + 1} of $totalVideos',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    for (int i = 0; i < totalVideos; i++) {
      try {
        final File videoFile = creationScreenHelper!.selectedVideos[i];
        final result = await ImageGallerySaver.saveFile(
          videoFile.path,
          name: 'AR_Drawing_${DateTime.now().millisecondsSinceEpoch}_$i',
        );

        final bool success = result != null &&
            (result['isSuccess'] == true || result['isSuccess'] == 'true');

        if (success) {
          savedCount++;
        } else {
          failedCount++;
        }

        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        'Error saving video: $e'.errorLogs();
        failedCount++;
      }
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    String message;
    Color backgroundColor;

    if (failedCount == 0) {
      message = 'All $savedCount videos saved to gallery successfully';
      backgroundColor = Colors.green;
    } else if (savedCount == 0) {
      message = 'Failed to save any videos to gallery';
      backgroundColor = Colors.red;
    } else {
      message = '$savedCount videos saved, $failedCount failed';
      backgroundColor = Colors.orange;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void deleteDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFFF3B30),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Delete Selected Videos?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to delete ${creationScreenHelper!.selectedVideos.length} video${creationScreenHelper!.selectedVideos.length > 1 ? 's' : ''}? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.grey.shade200,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        creationScreenHelper?.deleteSelectedVideos();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
