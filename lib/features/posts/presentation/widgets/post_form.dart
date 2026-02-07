import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';

/// Reusable form for creating and editing posts.
///
/// Handles both web and mobile platforms for image picking.
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

  /// Local path to newly selected image (mobile).
  String? _imagePath;

  /// Image bytes for web preview.
  Uint8List? _imageBytes;

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
      if (kIsWeb) {
        // For web, read bytes for preview
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imagePath = picked.path; // XFile path works for upload
          _imageChanged = true;
        });
      } else {
        // For mobile, use file path
        setState(() {
          _imagePath = picked.path;
          _imageChanged = true;
        });
      }
    }
  }

  /// Removes the selected image.
  void _removeImage() {
    setState(() {
      _imagePath = null;
      _imageBytes = null;
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
    final hasNewImage = _imagePath != null || _imageBytes != null;
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
                  child: _buildSelectedImage(hasNewImage),
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

  /// Builds the appropriate image widget based on source.
  Widget _buildSelectedImage(bool hasNewImage) {
    if (hasNewImage) {
      if (kIsWeb && _imageBytes != null) {
        // Web: use memory image
        return Image.memory(
          _imageBytes!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else if (!kIsWeb && _imagePath != null) {
        // Mobile: use file image
        // Import conditionally to avoid web issues
        return _MobileFileImage(path: _imagePath!);
      }
    }

    // Existing image URL
    if (widget.initialImageUrl != null) {
      return Image.network(
        widget.initialImageUrl!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return const SizedBox.shrink();
  }
}

/// Separate widget for mobile file image to avoid web compilation issues.
class _MobileFileImage extends StatelessWidget {
  final String path;

  const _MobileFileImage({required this.path});

  @override
  Widget build(BuildContext context) {
    // Use conditional import pattern
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    // For non-web, dynamically load the image
    return FutureBuilder<Uint8List>(
      future: _loadImage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        }
        return Container(
          height: 200,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Future<Uint8List> _loadImage() async {
    final xFile = XFile(path);
    return await xFile.readAsBytes();
  }
}
