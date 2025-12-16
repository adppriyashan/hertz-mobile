import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hertzmobile/config/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hertzmobile/providers/voice_provider.dart';

class VoiceRecorderDialog extends StatefulWidget {
  const VoiceRecorderDialog({super.key});

  @override
  State<VoiceRecorderDialog> createState() => _VoiceRecorderDialogState();
}

class _VoiceRecorderDialogState extends State<VoiceRecorderDialog> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  String? _recordingPath;
  bool _recorderInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      await _recorder.openRecorder();
      setState(() {
        _recorderInitialized = true;
      });
      _requestMicrophonePermission();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing recorder: $e')),
        );
      }
    }
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (!_recorderInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recorder not initialized')),
        );
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.wav';
      final path = '${directory.path}/$fileName';

      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV,
        bitRate: 128000,
        sampleRate: 44100,
      );

      setState(() {
        _isRecording = true;
        _recordingPath = path;
        _recordingDuration = Duration.zero;
      });

      // Update duration every 100ms
      Future.doWhile(() async {
        if (_isRecording) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (_isRecording) {
            setState(() {
              _recordingDuration =
                  _recordingDuration + const Duration(milliseconds: 100);
            });
          }
          return _isRecording;
        }
        return false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error starting recording: $e')));
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      if (path != null) {
        _recordingPath = path;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error stopping recording: $e')));
      }
    }
  }

  Future<void> _submitRecording() async {
    if (_recordingPath == null) return;

    final voiceProvider = context.read<VoiceProvider>();

    // Close dialog first
    if (!mounted) return;
    Navigator.of(context).pop();

    // Show processing dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.h),
              const Text('Processing voice recording...'),
            ],
          ),
        ),
      ),
    );

    final success = await voiceProvider.submitVoiceRecording(_recordingPath!);

    if (!mounted) return;

    if (success) {
      // Provider automatically polls for results with 2-second interval
      // Listen for processing completion
      bool processingComplete = false;
      int attempts = 0;
      const maxAttempts = 150; // 5 minutes max wait (150 * 2 seconds)

      while (!processingComplete && attempts < maxAttempts) {
        await Future.delayed(const Duration(seconds: 2));
        attempts++;

        if (voiceProvider.currentVoice?.status == 'processed') {
          processingComplete = true;

          final result = voiceProvider.currentVoice?.result;

          if (result == 'Identified') {
            Navigator.of(context).pop(); // Close processing dialog

            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Voice Identified'),
                  content: const Text(
                    'Voice has been identified successfully. '
                    'Associated switches will be updated.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(); // Close recorder dialog
                        voiceProvider.clearVoiceData();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          } else if (result == 'Unidentified') {
            Navigator.of(context).pop(); // Close processing dialog

            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Voice Not Identified'),
                  content: const Text(
                    'The voice command was not recognized. Please try again.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        voiceProvider.clearVoiceData();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          }
        }
      }

      if (!processingComplete) {
        Navigator.of(context).pop(); // Close processing dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Processing Timeout'),
              content: const Text(
                'Voice processing took too long. Please try again.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    voiceProvider.clearVoiceData();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } else {
      Navigator.of(context).pop(); // Close processing dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
              voiceProvider.errorMessage ?? 'Failed to submit recording',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Record Voice Command',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 24.h),
            // Recording Status
            if (_isRecording)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.errorColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: AppColors.errorColor,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox.shrink(),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Recording...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _formatDuration(_recordingDuration),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.errorColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            else if (_recordingPath != null)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.successColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.successColor,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Recording saved',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _formatDuration(_recordingDuration),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.successColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primaryColor),
                ),
                child: Center(
                  child: Text(
                    'Ready to record',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            SizedBox(height: 24.h),
            // Microphone Icon
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: _isRecording
                    ? AppColors.errorColor.withValues(alpha: 0.15)
                    : AppColors.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic,
                size: 40.sp,
                color: _isRecording
                    ? AppColors.errorColor
                    : AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 32.h),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRecording && _recordingPath == null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startRecording,
                      icon: const Icon(Icons.mic),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  )
                else if (_isRecording)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _stopRecording,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  )
                else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _recordingPath = null;
                          _recordingDuration = Duration.zero;
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.textSecondary),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitRecording,
                      icon: const Icon(Icons.send),
                      label: const Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
