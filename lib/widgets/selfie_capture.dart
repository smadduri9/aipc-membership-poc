import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// Live front-camera capture for the membership photo.
/// When no camera is available (for example the plain iOS Simulator), it shows a demo
/// capture button so the flow never blocks. The returned value is the image path, or
/// [demoSelfie] for the demo capture.
const demoSelfie = 'demo-selfie';

class SelfieCapture extends StatefulWidget {
  const SelfieCapture({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  State<SelfieCapture> createState() => _SelfieCaptureState();
}

class _SelfieCaptureState extends State<SelfieCapture> {
  CameraController? _controller;
  bool _checked = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      // The simulator can leave these calls pending forever, so give up after a short wait.
      final cameras = await availableCameras().timeout(
        const Duration(seconds: 3),
      );
      if (cameras.isEmpty) return;
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize().timeout(const Duration(seconds: 5));
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (_) {
      // No camera or no permission: fall back to the demo capture.
    } finally {
      if (mounted) setState(() => _checked = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _take() async {
    final controller = _controller;
    if (controller == null) {
      widget.onChanged(demoSelfie);
      return;
    }
    setState(() => _busy = true);
    final shot = await controller.takePicture();
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onChanged(shot.path);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value != null) return _preview();
    if (!_checked) {
      return const SizedBox(
        height: 260,
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    final controller = _controller;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 260,
            width: double.infinity,
            child: controller == null
                ? const ColoredBox(
                    color: Color(0xFFE5EEF9),
                    child: Icon(
                      CupertinoIcons.person_crop_circle,
                      size: 120,
                      color: AppColors.navy,
                    ),
                  )
                : CameraPreview(controller),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _busy ? null : _take,
          icon: const Icon(CupertinoIcons.camera_fill),
          label: Text(controller == null ? 'Take photo (demo)' : 'Take photo'),
        ),
      ],
    );
  }

  Widget _preview() {
    final isDemo = widget.value == demoSelfie;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 260,
            width: double.infinity,
            color: const Color(0xFFE5EEF9),
            alignment: Alignment.center,
            child: isDemo
                ? const Icon(
                    CupertinoIcons.person_crop_circle,
                    size: 120,
                    color: AppColors.navy,
                  )
                : Image.file(File(widget.value!), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => widget.onChanged(null),
          child: const Text('Retake'),
        ),
      ],
    );
  }
}
