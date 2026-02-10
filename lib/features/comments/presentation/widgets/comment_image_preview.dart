import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Maximum number of visible images in the preview row.
const int _maxVisibleImages = 3;

/// Widget for displaying comment images in a row with overflow indicator.
///
/// Shows up to 3 images in a row. If there are more than 3 images,
/// the third slot shows a blurred image with "+N" overlay indicating
/// how many more images are available.
class CommentImagesPreview extends StatelessWidget {
  /// List of image URLs to display.
  final List<String> imageUrls;

  /// Height of each image thumbnail.
  final double imageHeight;

  /// Called when an image is tapped.
  final void Function(int index)? onImageTap;

  const CommentImagesPreview({
    super.key,
    required this.imageUrls,
    this.imageHeight = 80,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final visibleCount = imageUrls.length > _maxVisibleImages
        ? _maxVisibleImages
        : imageUrls.length;
    final overflowCount = imageUrls.length - _maxVisibleImages;

    return SizedBox(
      height: imageHeight,
      child: Row(
        children: List.generate(visibleCount, (index) {
          final isLastVisible = index == _maxVisibleImages - 1;
          final showOverflow = isLastVisible && overflowCount > 0;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < visibleCount - 1 ? 4 : 0),
              child: GestureDetector(
                onTap: () => onImageTap?.call(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: showOverflow
                      ? _buildOverflowImage(imageUrls[index], overflowCount)
                      : _buildImage(imageUrls[index]),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      height: imageHeight,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        height: imageHeight,
        color: Colors.grey[200],
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        height: imageHeight,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 24),
      ),
    );
  }

  Widget _buildOverflowImage(String url, int overflowCount) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred background image
        CachedNetworkImage(
          imageUrl: url,
          height: imageHeight,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: Colors.grey[300]),
          errorWidget: (_, __, ___) => Container(color: Colors.grey[300]),
        ),
        // Blur overlay
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              color: Colors.black.withOpacity(0.4),
              alignment: Alignment.center,
              child: Text(
                '+$overflowCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-screen image gallery viewer.
///
/// Shows images in a PageView with swipe navigation.
class ImageGalleryViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageGalleryViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  /// Shows the gallery as a full-screen dialog.
  static void show(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImageGalleryViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  State<ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends State<ImageGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} / ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}