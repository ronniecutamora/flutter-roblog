import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_roblog/core/constants/app_strings.dart';
import 'package:image_picker/image_picker.dart';


/// Input widget for adding new comments.
///
/// Provides:
/// - Text field for comment content
/// - Image picker for attaching images
/// - Submit button
class CommentInput extends StatefulWidget {
  /// Callback when comment is submitted.
  final void Function(String content, String? imagePath) onSubmit;

  const CommentInput({super.key, required this.onSubmit});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  String? _imagePath;
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imagePath = picked.path;
          _imageBytes = bytes;
        });
      } else {
        setState(() => _imagePath = picked.path);
      }
    }
  }

  void _clearImage() {
    setState(() {
      _imagePath = null;
      _imageBytes = null;
    });
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSubmit(text, _imagePath);
    _controller.clear();
    _clearImage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image preview
        if (_imagePath != null) _buildImagePreview(),
        const SizedBox(height: 8),
        // Input row
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _pickImage,
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

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: kIsWeb
              ? Image.memory(
                  _imageBytes!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(_imagePath!),
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: _clearImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}