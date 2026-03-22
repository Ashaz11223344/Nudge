import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:nudge/core/constants/colors.dart';
import 'package:nudge/data/repositories/user_repository.dart';

import 'package:nudge/shared/providers/app_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  String? _imagePath;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _continue() async {
    HapticFeedback.lightImpact();
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorText = 'Please enter your name';
      });
      return;
    }
    setState(() {
      _errorText = null;
    });

    setState(() => _isLoading = true);

    final appProvider = context.read<AppProvider>();
    final userRepo = context.read<UserRepository>();

    await appProvider.updateUserName(name);

    if (_imagePath != null) {
      await appProvider.updateProfileImage(_imagePath!);
    }

    await userRepo.setOnboardingComplete();
    await appProvider.init();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Text(
                'Welcome to Nudge',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Tell us your name and add a profile photo',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.dustGrey,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: AppColors.dustGrey.withValues(alpha: 0.3),
                  backgroundImage:
                      _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child: _imagePath == null
                      ? const Icon(Icons.camera_alt_outlined,
                          size: 32, color: AppColors.dustGrey)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to add photo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.dustGrey,
                    ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (val) {
                  if (_errorText != null) {
                    setState(() => _errorText = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  errorText: _errorText,
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _continue,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.floralWhite,
                          ),
                        )
                      : const Text('Continue'),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
