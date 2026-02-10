import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_roblog/core/constants/app_strings.dart';
import 'package:flutter_roblog/features/comments/domain/entities/comment.dart';
import 'package:image_picker/image_picker.dart';

/// Represents a picked image with its path and optional bytes (for web).
class _PickedImage {
  final String path;
  final Uint8List? bytes;

  _PickedImage({required this.path, this.bytes});
}

/// Input widget for adding new comments with multi-image support.
///
/// Provides:
/// - Text field for comment content
/// - Image picker for attaching up to 5 images
/// - Submit button
class CommentInput extends StatefulWidget {
  /// Callback when comment is submitted.
  final void Function(String content, List<String> imagePaths) onSubmit;

  const CommentInput({super.key, required this.onSubmit});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  final List<_PickedImage> _images = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= maxImagesPerComment) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $maxImagesPerComment images allowed')),
      );
      return;
    }

    final remaining = maxImagesPerComment - _images.length;
    final picker = ImagePicker();

    // Pick multiple images
    final picked = await picker.pickMultiImage(
      maxWidth: 800,
      imageQuality: 80,
    );

    if (picked.isEmpty) return;

    // Limit to remaining slots
    final toAdd = picked.take(remaining).toList();

    for (final xFile in toAdd) {
      if (kIsWeb) {
        final bytes = await xFile.readAsBytes();
        setState(() {
          _images.add(_PickedImage(path: xFile.path, bytes: bytes));
        });
      } else {
        setState(() {
          _images.add(_PickedImage(path: xFile.path));
        });
      }
    }

    if (picked.length > remaining) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Only $remaining more image(s) allowed. Some images were not added.',
            ),
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _clearImages() {
    setState(() {
      _images.clear();
    });
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSubmit(text, _images.map((i) => i.path).toList());
    _controller.clear();
    _clearImages();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image previews
        if (_images.isNotEmpty) ...[
          _buildImagePreviews(),
          const SizedBox(height: 8),
        ],
        // Input row
        Row(
          children: [
            // Image picker button with count badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImages,
                  tooltip: 'Add images (${_images.length}/$maxImagesPerComment)',
                ),
                if (_images.isNotEmpty)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: AppStrings.createComment,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submit,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreviews() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final image = _images[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: kIsWeb && image.bytes != null
                        ? Image.memory(
                            image.bytes!,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}