import 'package:flutter/material.dart';
import 'package:hertzmobile/models/switch_models.dart' as switch_models;
import 'package:hertzmobile/services/api_service.dart';

class SwitchesProvider extends ChangeNotifier {
  final ApiService apiService;

  List<switch_models.Switch> _switches = [];
  bool _isLoading = false;
  String? _errorMessage;
  late final Map<int, bool> _updatingIds = {};

  SwitchesProvider({required this.apiService});

  List<switch_models.Switch> get switches => _switches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool isUpdating(int id) => _updatingIds[id] ?? false;

  Future<void> fetchAllSwitches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.getAllSwitches();
      if (response.success) {
        _switches = response.data;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch switches: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateSwitchStatus(int id, bool newStatus) async {
    _updatingIds[id] = true;
    notifyListeners();

    try {
      final response = await apiService.updateSwitch(id, newStatus);

      if (response.success) {
        // Update local switch
        final index = _switches.indexWhere((s) => s.id == id);
        if (index != -1) {
          _switches[index] = switch_models.Switch(
            id: id,
            status: newStatus,
            createdAt: _switches[index].createdAt,
            updatedAt: DateTime.now().toIso8601String(),
          );
        }
        _errorMessage = null;
        _updatingIds[id] = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _updatingIds[id] = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update switch: ${e.toString()}';
      _updatingIds[id] = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
