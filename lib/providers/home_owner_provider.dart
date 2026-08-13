import 'package:flutter/material.dart';
import '../models/apartment_model.dart';
import '../services/home_owner_db_helper.dart';

class HomeOwnerProvider extends ChangeNotifier {
  List<ApartmentModel> _apartments = [];
  bool _isLoading = false;

  List<ApartmentModel> get apartments => _apartments;
  bool get isLoading => _isLoading;

  Future<void> loadApartments() async {
    _isLoading = true;
    notifyListeners();
    _apartments = await HomeOwnerDBHelper.instance.getAllApartments();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addApartment(ApartmentModel appt) async {
    final newAppt = await HomeOwnerDBHelper.instance.insertApartment(appt);
    _apartments.add(newAppt);
    notifyListeners();
  }

  Future<void> updateApartment(ApartmentModel appt) async {
    await HomeOwnerDBHelper.instance.updateApartment(appt);
    final index = _apartments.indexWhere((a) => a.id == appt.id);
    if (index != -1) {
      _apartments[index] = appt;
      notifyListeners();
    }
  }

  Future<void> deleteApartment(int id) async {
    await HomeOwnerDBHelper.instance.deleteApartment(id);
    _apartments.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<void> markRentPaid(int apartmentId, String monthKey) async {
    final index = _apartments.indexWhere((a) => a.id == apartmentId);
    if (index != -1) {
      final appt = _apartments[index];
      if (!appt.paidMonths.contains(monthKey)) {
        final newPaidMonths = List<String>.from(appt.paidMonths)..add(monthKey);
        final updatedAppt = appt.copyWith(paidMonths: newPaidMonths);
        await updateApartment(updatedAppt);
      }
    }
  }

  bool isRentPaidForMonth(int apartmentId, String monthKey) {
    final appt = _apartments.firstWhere((a) => a.id == apartmentId,
        orElse: () => ApartmentModel(
            name: '',
            boarderName: '',
            boarderPhone: '',
            rentAmount: 0,
            paidMonths: [],
            createdAt: ''));
    return appt.paidMonths.contains(monthKey);
  }
}
