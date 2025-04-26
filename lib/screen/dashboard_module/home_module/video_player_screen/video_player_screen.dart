import 'dart:io';
import 'dart:ui';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class VideoPlayerScreen extends StatefulWidget {
  final File videoFile;
  final String thumbnailPath;

  const VideoPlayerScreen({
    super.key,
    required this.videoFile,
    required this.thumbnailPath,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isBuffering = false;
  bool _showControls = true;
  bool _isSaving = false;
  bool _isSharing = false;
  double _currentPosition = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideoPlayer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_isPlaying) {
        _controller.pause();
      }
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.file(widget.videoFile);

    try {
      await _controller.initialize();
      _controller.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _controller.play();
          _isPlaying = true;
        });
      }
    } catch (e) {
      'Video player initialization error: $e'.errorLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error playing video'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _videoListener() {
    if (_controller.value.isBuffering && !_isBuffering) {
      setState(() {
        _isBuffering = true;
      });
    } else if (!_controller.value.isBuffering && _isBuffering) {
      setState(() {
        _isBuffering = false;
      });
    }

    final position = _controller.value.position.inMilliseconds.toDouble();
    final duration = _controller.value.duration.inMilliseconds.toDouble();

    if (position > 0 &&
        duration > 0 &&
        (position / duration) != _currentPosition) {
      setState(() {
        _currentPosition = position / duration;
      });
    }

    if (_controller.value.isCompleted && _isPlaying) {
      setState(() {
        _isPlaying = false;
        _showControls = true;
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });

    HapticFeedback.lightImpact();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    HapticFeedback.selectionClick();
  }

  Future<void> _shareVideo() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    HapticFeedback.mediumImpact();

    try {
      await Share.shareXFiles([XFile(widget.videoFile.path)],
          text: 'Check out my AR drawing!');
    } catch (e) {
      'Error sharing video: $e'.errorLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error sharing video'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isSharing = false;
      });
    }
  }

  Future<void> _saveVideoToGallery() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    HapticFeedback.mediumImpact();

    try {
      final result = await ImageGallerySaver.saveFile(
        widget.videoFile.path,
        name: 'AR_Drawing_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        final bool success = result != null &&
            (result['isSuccess'] == true || result['isSuccess'] == 'true');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Video saved to gallery' : 'Failed to save video',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            backgroundColor:
                success ? Colors.green.shade700 : Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: success
                ? SnackBarAction(
                    label: 'Great!',
                    textColor: Colors.white,
                    onPressed: () {},
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      'Error saving video: $e'.errorLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error saving video to gallery'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.removeListener(_videoListener);
      _controller.dispose();
    }

    _animationController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: child,
        );
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.black.withOpacity(0.3),
                centerTitle: true,
                title: const Text(
                  "Video Preview",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(CupertinoIcons.back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(CupertinoIcons.info, color: Colors.white),
                    ),
                    onPressed: () {
                      final duration = _isInitialized
                          ? _formatDuration(_controller.value.duration)
                          : '00:00';
                      final size =
                          (widget.videoFile.lengthSync() / (1024 * 1024))
                              .toStringAsFixed(2);

                      showDialog(
                        context: context,
                        builder: (context) => BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: AlertDialog(
                            title: const Text('Video Details'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Duration', duration),
                                const SizedBox(height: 8),
                                _buildInfoRow('Size', '$size MB'),
                                const SizedBox(height: 8),
                                _buildInfoRow('Format', 'MP4'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _buildVideoPlayer(),
            _buildGradientOverlays(),
            _buildControlsOverlay(),
            if (!_isInitialized || _isBuffering) _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _toggleControls,
      child: Center(
        child: Container(
          color: Colors.black,
          child: _isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Image.file(
                  File(widget.thumbnailPath),
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlays() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsOverlay() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(
        ignoring: !_showControls,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            if (_isInitialized)
                              Text(
                                _formatDuration(_controller.value.position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 8),
                                    overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 16),
                                    overlayColor: AppColorConstant.appDeepPurple
                                        .withOpacity(0.3),
                                    activeTrackColor:
                                        AppColorConstant.appDeepPurple,
                                    inactiveTrackColor:
                                        Colors.white.withOpacity(0.3),
                                    thumbColor: Colors.white,
                                  ),
                                  child: Slider(
                                    value: _currentPosition,
                                    onChanged: _isInitialized
                                        ? (value) {
                                            final duration = _controller
                                                .value.duration.inMilliseconds;
                                            final position =
                                                (value * duration).toInt();
                                            _controller.seekTo(Duration(
                                                milliseconds: position));

                                            HapticFeedback.selectionClick();
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            if (_isInitialized)
                              Text(
                                _formatDuration(_controller.value.duration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildControlButton(
                              onTap: _isInitialized ? _togglePlayPause : null,
                              icon: _isPlaying
                                  ? CupertinoIcons.pause_fill
                                  : CupertinoIcons.play_fill,
                              label: _isPlaying ? 'Pause' : 'Play',
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF9C27B0),
                                  Color(0xFF673AB7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            _buildActionButton(
                              onTap: _saveVideoToGallery,
                              icon: CupertinoIcons.arrow_down_to_line,
                              label: 'Save',
                              isLoading: _isSaving,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade700,
                                  Colors.blue.shade500,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            _buildActionButton(
                              onTap: _shareVideo,
                              icon: CupertinoIcons.share,
                              label: 'Share',
                              isLoading: _isSharing,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade700,
                                  Colors.green.shade500,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColorConstant.appDeepPurple,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                _isBuffering ? "Buffering..." : "Loading video...",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onTap,
    required IconData icon,
    required String label,
    required Gradient gradient,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: onTap == null ? 0.6 : 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 110,
              height: 50,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColorConstant.appDeepPurple.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isLoading,
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 110,
        height: 50,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
