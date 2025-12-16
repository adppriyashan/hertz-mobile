import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hertzmobile/models/voice_models.dart';
import 'package:hertzmobile/services/api_service.dart';

class VoiceProvider extends ChangeNotifier {
  final ApiService apiService;
  Function? onSwitchesNeedRefresh;
  Function(String error)? onError;
  Function(String result)? onSuccess;

  VoiceData? _currentVoice;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _resultMessage;
  Timer? _pollTimer;
  List<int>? _identifiedSwitches;

  VoiceProvider({required this.apiService});

  VoiceData? get currentVoice => _currentVoice;
  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get resultMessage => _resultMessage;
  List<int>? get identifiedSwitches => _identifiedSwitches;

  /// Submit voice recording and start polling for results
  Future<bool> submitVoiceRecording(String filePath) async {
    _isProcessing = true;
    _errorMessage = null;
    _resultMessage = null;
    _identifiedSwitches = null;
    notifyListeners();

    final response = await apiService.submitVoiceRecording(filePath);

    if (response.success && response.data != null) {
      _currentVoice = response.data;
      notifyListeners();

      // Start polling for results
      _startPolling(response.data!.id);
      return true;
    } else {
      _isProcessing = false;
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Start polling voice recording status with 2-second interval
  void _startPolling(int voiceId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final response = await apiService.getVoiceRecording(voiceId);

      if (response.success && response.data != null) {
        _currentVoice = response.data!;

        // Check if processing is complete
        if (response.data!.status == 'processed') {
          timer.cancel();
          _pollTimer = null;
          _isProcessing = false;

          // Handle result - 3 types:
          // 1. "Unauthorized" - error
          // 2. "Invalid" - error
          // 3. Relay state like "4-1" - success, need to refresh switches
          final result = response.data!.result ?? '';

          print('TESTING VOICE RESULT: $result');

          if (result == 'Unauthorized' || result == 'Invalid') {
            final errorMsg = result == 'Unauthorized'
                ? 'Voice command unauthorized'
                : 'Invalid voice command';
            _errorMessage = errorMsg;
            _isProcessing = false;
            onError?.call(errorMsg);
            notifyListeners();
          } else if (result.isNotEmpty && _isRelayState(result)) {
            // Relay state detected (e.g., "4-1") - success case
            _resultMessage = 'Voice identified successfully';
            parseIdentifiedSwitches(result);
            // Trigger switches refresh
            onSwitchesNeedRefresh?.call();
            onSuccess?.call(result);
            notifyListeners();
          } else if (result == 'Unidentified') {
            const errorMsg = 'Voice not identified';
            _errorMessage = errorMsg;
            _isProcessing = false;
            onError?.call(errorMsg);
            notifyListeners();
          } else {
            _resultMessage = 'Voice identified successfully';
            parseIdentifiedSwitches(result);
            onSuccess?.call(result);
            notifyListeners();
          }
        } else {
          notifyListeners();
        }
      } else {
        timer.cancel();
        _pollTimer = null;
        _isProcessing = false;
        _errorMessage = response.message;
        onError?.call(response.message);
        notifyListeners();
      }
    });
  }

  /// Check if result is a relay state format (e.g., "4-1", "1-0", etc.)
  bool _isRelayState(String result) {
    // Pattern: digit-digit (relay-state)
    final regExp = RegExp(r'^\d+-[01]$');
    return regExp.hasMatch(result);
  }

  /// Parse identified switches from result
  /// Result format: "Identified" -> followed by switch numbers 1-5
  void parseIdentifiedSwitches(String? result) {
    if (result == null || result == 'Identified') {
      _identifiedSwitches = null;
      return;
    }

    // Extract numbers 1-5 from result
    final switches = <int>[];
    for (int i = 1; i <= 5; i++) {
      if (result.contains(i.toString())) {
        switches.add(i);
      }
    }
    _identifiedSwitches = switches.isNotEmpty ? switches : null;
  }

  /// Clear voice data
  void clearVoiceData() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _currentVoice = null;
    _isRecording = false;
    _isProcessing = false;
    _errorMessage = null;
    _resultMessage = null;
    _identifiedSwitches = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
