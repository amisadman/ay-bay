import 'package:flutter/foundation.dart';
import '../models/subscription_model.dart';
import '../services/super_module_db_helper.dart';

class SubscriptionProvider extends ChangeNotifier {
  List<SubscriptionModel> _subscriptions = [];
  bool _isLoading = false;

  List<SubscriptionModel> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;

  Future<void> fetchSubscriptions() async {
    _isLoading = true;
    notifyListeners();

    _subscriptions = await SuperModuleDBHelper.instance.getAllSubscriptions();

    // Sort by next due date
    _subscriptions.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSubscription(SubscriptionModel sub) async {
    await SuperModuleDBHelper.instance.insertSubscription(sub);
    await fetchSubscriptions();
  }

  Future<void> updateSubscription(SubscriptionModel sub) async {
    await SuperModuleDBHelper.instance.updateSubscription(sub);
    await fetchSubscriptions();
  }

  Future<void> deleteSubscription(int id) async {
    await SuperModuleDBHelper.instance.deleteSubscription(id);
    await fetchSubscriptions();
  }

  double get totalMonthlyCost {
    return _subscriptions.fold(0.0, (sum, sub) {
      if (sub.billingCycle == 'Yearly') {
        return sum + (sub.cost / 12);
      }
      return sum + sub.cost;
    });
  }
}
