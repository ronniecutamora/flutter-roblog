import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/content_block.dart';
import 'block_editor.dart';

/// Reusable form for creating and editing posts with block-based content.
class PostForm extends StatefulWidget {
  /// Initial title (for editing).
  final String? initialTitle;

  /// Initial content blocks (for editing).
  final List<ContentBlock> initialBlocks;

  /// Submit button label.
  final String submitLabel;

  /// Whether form is in loading state.
  final bool isLoading;

  /// Callback when form is submitted.
  ///
  /// [title] - Post title
  /// [contentBlocks] - List of content blocks
  final void Function(String title, List<ContentBlock> contentBlocks) onSubmit;

  /// Creates a [PostForm].
  const PostForm({
    super.key,
    this.initialTitle,
    this.initialBlocks = const [],
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
  List<ContentBlock> _contentBlocks = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentBlocks = List.from(widget.initialBlocks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// Submits the form.
  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Validate that there's at least some content
      final hasContent = _contentBlocks.any((block) {
        if (block is TextBlock) return block.text.trim().isNotEmpty;
        if (block is ImageBlock) return block.hasImage;
        return false;
      });

      if (!hasContent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add some content to your post')),
        );
        return;
      }

      widget.onSubmit(
        _titleController.text.trim(),
        _contentBlocks,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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

          const SizedBox(height: 24),

          // ─── Content Blocks Section ─────────────────────────────────────
          Text(
            'Content',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add text and images to your post. You can reorder blocks using the arrows.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          BlockEditor(
            initialBlocks: widget.initialBlocks,
            isLoading: widget.isLoading,
            onChanged: (blocks) {
              _contentBlocks = blocks;
            },
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