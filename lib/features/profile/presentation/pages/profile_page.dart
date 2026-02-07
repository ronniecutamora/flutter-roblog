import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/di/injection.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(LoadProfileEvent()),
      child: const _ProfilePageBody(),
    );
  }
}

class _ProfilePageBody extends StatefulWidget {
  const _ProfilePageBody();

  @override
  State<_ProfilePageBody> createState() => _ProfilePageBodyState();
}

class _ProfilePageBodyState extends State<_ProfilePageBody> {
  final _displayNameController = TextEditingController();
  String? _avatarPath;
  bool _isEditing = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _avatarPath = picked.path);
    }
  }

  void _saveProfile() {
    context.read<ProfileBloc>().add(
          UpdateProfileEvent(
            displayName: _displayNameController.text.trim().isNotEmpty
                ? _displayNameController.text.trim()
                : null,
            avatarPath: _avatarPath,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            Helpers.showSnackBar(context, 'Profile updated!');
            setState(() {
              _isEditing = false;
              _avatarPath = null;
            });
          } else if (state is ProfileLoaded && !_isEditing) {
            _displayNameController.text = state.user.displayName ?? '';
          } else if (state is ProfileError) {
            Helpers.showSnackBar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state is ProfileLoaded
              ? state.user
              : state is ProfileUpdated
                  ? state.user
                  : null;

          if (user == null) {
            return const Center(child: Text('Failed to load profile'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isEditing ? _pickAvatar : null,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _avatarPath != null
                        ? FileImage(File(_avatarPath!))
                        : user.avatarUrl != null
                            ? CachedNetworkImageProvider(user.avatarUrl!)
                            : null,
                    child: _avatarPath == null && user.avatarUrl == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _pickAvatar,
                    child: const Text('Change Photo'),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                if (_isEditing) ...[
                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.displayName,
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() {
                            _isEditing = false;
                            _avatarPath = null;
                          }),
                          child: const Text(AppStrings.cancel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text(AppStrings.save),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    user.displayName ?? 'No display name set',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}