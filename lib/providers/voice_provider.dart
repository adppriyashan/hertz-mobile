import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hertzmobile/models/voice_models.dart';
import 'package:hertzmobile/services/api_service.dart';

class VoiceProvider extends ChangeNotifier {
  final ApiService apiService;

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

  /// Start polling voice recording status
  void _startPolling(int voiceId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final response = await apiService.getVoiceRecording(voiceId);

      if (response.success && response.data != null) {
        _currentVoice = response.data!;

        // Check if processing is complete
        if (response.data!.status == 'processed') {
          timer.cancel();
          _pollTimer = null;
          _isProcessing = false;

          // Handle result
          if (response.data!.result == 'Identified') {
            _resultMessage = 'Voice identified successfully';
            notifyListeners();
          } else if (response.data!.result == 'Unidentified') {
            _errorMessage = 'Voice not identified';
            _isProcessing = false;
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
        notifyListeners();
      }
    });
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
