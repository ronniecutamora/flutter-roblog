import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';

/// Reusable form for creating and editing posts.
///
/// Features:
/// - Title and content input fields
/// - Image picker (gallery)
/// - Form validation
/// - Loading state handling
///
/// Used by both [CreatePostPage] and [EditPostPage].
class PostForm extends StatefulWidget {
  /// Initial title (for editing).
  final String? initialTitle;

  /// Initial content (for editing).
  final String? initialContent;

  /// Initial image URL (for editing).
  final String? initialImageUrl;

  /// Submit button label.
  final String submitLabel;

  /// Whether form is in loading state.
  final bool isLoading;

  /// Callback when form is submitted.
  ///
  /// [title] - Post title
  /// [content] - Post content
  /// [imagePath] - Local path to new image (null if unchanged)
  final void Function(String title, String content, String? imagePath) onSubmit;

  /// Creates a [PostForm].
  const PostForm({
    super.key,
    this.initialTitle,
    this.initialContent,
    this.initialImageUrl,
    required this.submitLabel,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  /// Local path to newly selected image.
  String? _imagePath;

  /// Whether user has selected a new image.
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Opens image picker to select an image.
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
        _imageChanged = true;
      });
    }
  }

  /// Removes the selected image.
  void _removeImage() {
    setState(() {
      _imagePath = null;
      _imageChanged = true;
    });
  }

  /// Submits the form.
  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _titleController.text.trim(),
        _contentController.text.trim(),
        _imageChanged ? _imagePath : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which image to show
    final hasNewImage = _imagePath != null;
    final hasExistingImage = widget.initialImageUrl != null && !_imageChanged;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Image Section ──────────────────────────────────────────────
          if (hasNewImage || hasExistingImage)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: hasNewImage
                      ? Image.file(
                          File(_imagePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          widget.initialImageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: widget.isLoading ? null : _removeImage,
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          else
            OutlinedButton.icon(
              onPressed: widget.isLoading ? null : _pickImage,
              icon: const Icon(Icons.image),
              label: const Text(AppStrings.addImage),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(100),
              ),
            ),

          const SizedBox(height: 16),

          // ─── Title Field ────────────────────────────────────────────────
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: AppStrings.title,
              prefixIcon: Icon(Icons.title),
            ),
            textInputAction: TextInputAction.next,
            validator: Validators.postTitle,
            enabled: !widget.isLoading,
          ),

          const SizedBox(height: 16),

          // ─── Content Field ──────────────────────────────────────────────
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: AppStrings.content,
              alignLabelWithHint: true,
            ),
            maxLines: 8,
            textInputAction: TextInputAction.newline,
            validator: Validators.postContent,
            enabled: !widget.isLoading,
          ),

          const SizedBox(height: 24),

          // ─── Submit Button ──────────────────────────────────────────────
          ElevatedButton(
            onPressed: widget.isLoading ? null : _submit,
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
