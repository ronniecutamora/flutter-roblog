import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/content_block.dart';

/// Maximum number of images allowed per post.
const int maxImagesPerPost = 5;

/// Block editor for creating/editing post content with text and images.
///
/// Allows users to add, remove, and reorder content blocks.
class BlockEditor extends StatefulWidget {
  /// Initial content blocks (for editing).
  final List<ContentBlock> initialBlocks;

  /// Whether the editor is disabled (loading state).
  final bool isLoading;

  /// Callback when blocks change.
  final void Function(List<ContentBlock> blocks) onChanged;

  const BlockEditor({
    super.key,
    this.initialBlocks = const [],
    this.isLoading = false,
    required this.onChanged,
  });

  @override
  State<BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends State<BlockEditor> {
  final _uuid = const Uuid();
  late List<_EditableBlock> _blocks;

  @override
  void initState() {
    super.initState();
    _initializeBlocks();
  }

  void _initializeBlocks() {
    if (widget.initialBlocks.isEmpty) {
      // Start with one empty text block
      _blocks = [
        _EditableBlock(
          id: _uuid.v4(),
          type: BlockType.text,
          controller: TextEditingController(),
        ),
      ];
    } else {
      _blocks = widget.initialBlocks.map((block) {
        switch (block) {
          case TextBlock():
            return _EditableBlock(
              id: block.id,
              type: BlockType.text,
              controller: TextEditingController(text: block.text),
            );
          case ImageBlock():
            return _EditableBlock(
              id: block.id,
              type: BlockType.image,
              imageUrl: block.imageUrl,
              caption: block.caption,
            );
        }
      }).toList();
    }
  }

  @override
  void dispose() {
    for (final block in _blocks) {
      block.controller?.dispose();
    }
    super.dispose();
  }

  /// Current count of image blocks.
  int get _imageCount => _blocks.where((b) => b.type == BlockType.image).length;

  /// Notifies parent of block changes.
  void _notifyChanged() {
    final contentBlocks = _blocks.asMap().entries.map((entry) {
      final index = entry.key;
      final block = entry.value;

      switch (block.type) {
        case BlockType.text:
          return TextBlock(
            id: block.id,
            order: index,
            text: block.controller?.text ?? '',
          );
        case BlockType.image:
          return ImageBlock(
            id: block.id,
            order: index,
            imageUrl: block.imageUrl,
            localPath: block.localPath,
            caption: block.caption,
          );
      }
    }).toList();

    widget.onChanged(contentBlocks);
  }

  /// Adds a new text block at the end.
  void _addTextBlock() {
    setState(() {
      _blocks.add(_EditableBlock(
        id: _uuid.v4(),
        type: BlockType.text,
        controller: TextEditingController(),
      ));
    });
    _notifyChanged();
  }

  /// Adds a new image block at the end.
  Future<void> _addImageBlock() async {
    if (_imageCount >= maxImagesPerPost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $maxImagesPerPost images allowed')),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (picked != null) {
      Uint8List? bytes;
      if (kIsWeb) {
        bytes = await picked.readAsBytes();
      }

      setState(() {
        _blocks.add(_EditableBlock(
          id: _uuid.v4(),
          type: BlockType.image,
          localPath: picked.path,
          imageBytes: bytes,
        ));
      });
      _notifyChanged();
    }
  }

  /// Removes a block at the given index.
  void _removeBlock(int index) {
    setState(() {
      final block = _blocks.removeAt(index);
      block.controller?.dispose();

      // Ensure at least one text block exists
      if (_blocks.isEmpty) {
        _blocks.add(_EditableBlock(
          id: _uuid.v4(),
          type: BlockType.text,
          controller: TextEditingController(),
        ));
      }
    });
    _notifyChanged();
  }

  /// Moves a block up in the order.
  void _moveBlockUp(int index) {
    if (index <= 0) return;
    setState(() {
      final block = _blocks.removeAt(index);
      _blocks.insert(index - 1, block);
    });
    _notifyChanged();
  }

  /// Moves a block down in the order.
  void _moveBlockDown(int index) {
    if (index >= _blocks.length - 1) return;
    setState(() {
      final block = _blocks.removeAt(index);
      _blocks.insert(index + 1, block);
    });
    _notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Block list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _blocks.length,
          itemBuilder: (context, index) {
            final block = _blocks[index];
            return _BlockTile(
              key: ValueKey(block.id),
              block: block,
              index: index,
              totalCount: _blocks.length,
              isLoading: widget.isLoading,
              onTextChanged: (_) => _notifyChanged(),
              onCaptionChanged: (caption) {
                block.caption = caption;
                _notifyChanged();
              },
              onRemove: () => _removeBlock(index),
              onMoveUp: () => _moveBlockUp(index),
              onMoveDown: () => _moveBlockDown(index),
            );
          },
        ),

        const SizedBox(height: 16),

        // Add block buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.isLoading ? null : _addTextBlock,
                icon: const Icon(Icons.text_fields),
                label: const Text('Add Text'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.isLoading || _imageCount >= maxImagesPerPost
                    ? null
                    : _addImageBlock,
                icon: const Icon(Icons.image),
                label: Text('Add Image (${_imageCount}/$maxImagesPerPost)'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Represents an editable block in the editor.
class _EditableBlock {
  final String id;
  final BlockType type;
  final TextEditingController? controller;
  String? imageUrl;
  String? localPath;
  Uint8List? imageBytes;
  String? caption;

  _EditableBlock({
    required this.id,
    required this.type,
    this.controller,
    this.imageUrl,
    this.localPath,
    this.imageBytes,
    this.caption,
  });
}

enum BlockType { text, image }

/// Widget for displaying and editing a single block.
class _BlockTile extends StatelessWidget {
  final _EditableBlock block;
  final int index;
  final int totalCount;
  final bool isLoading;
  final void Function(String) onTextChanged;
  final void Function(String) onCaptionChanged;
  final VoidCallback onRemove;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  const _BlockTile({
    super.key,
    required this.block,
    required this.index,
    required this.totalCount,
    required this.isLoading,
    required this.onTextChanged,
    required this.onCaptionChanged,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Block header with controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  block.type == BlockType.text ? Icons.text_fields : Icons.image,
                  size: 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  block.type == BlockType.text ? 'Text' : 'Image',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Move up button
                IconButton(
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  onPressed: isLoading || index == 0 ? null : onMoveUp,
                  tooltip: 'Move up',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                // Move down button
                IconButton(
                  icon: const Icon(Icons.arrow_downward, size: 18),
                  onPressed: isLoading || index == totalCount - 1 ? null : onMoveDown,
                  tooltip: 'Move down',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                // Remove button
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: isLoading ? null : onRemove,
                  tooltip: 'Remove',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),

          // Block content
          Padding(
            padding: const EdgeInsets.all(12),
            child: block.type == BlockType.text
                ? _buildTextField()
                : _buildImageBlock(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: block.controller,
      maxLines: null,
      minLines: 3,
      decoration: const InputDecoration(
        hintText: 'Enter text...',
        border: OutlineInputBorder(),
      ),
      enabled: !isLoading,
      onChanged: onTextChanged,
    );
  }

  Widget _buildImageBlock() {
    Widget imageWidget;

    if (block.imageBytes != null) {
      // Web: show from bytes
      imageWidget = Image.memory(
        block.imageBytes!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (block.imageUrl != null) {
      // Existing image from URL
      imageWidget = Image.network(
        block.imageUrl!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (block.localPath != null && !kIsWeb) {
      // Mobile: show from file using XFile
      imageWidget = FutureBuilder<Uint8List>(
        future: XFile(block.localPath!).readAsBytes(),
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
    } else {
      imageWidget = Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image, size: 48)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageWidget,
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Add a caption (optional)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          enabled: !isLoading,
          onChanged: onCaptionChanged,
          controller: TextEditingController(text: block.caption),
        ),
      ],
    );
  }
}