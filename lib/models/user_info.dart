import 'package:im_test/api/api.dart';
import 'package:im_test/entity/service.dart';
import 'package:signals/signals_flutter.dart';

final userInfoManager = UserInfoManager();

class UserInfoManager {
  final Signal<String> _token;

  final Signal<String> _account;

  final Signal<List<ServiceEntity>> _serviceList;

  final Signal<String> _currentServiceID;

  Signal<String> get token => _token;

  Signal<List<ServiceEntity>> get serviceList => _serviceList;

  Signal<String> get currentServiceID => _currentServiceID;

  UserInfoManager()
    : _token = signal(""),
      _account = signal(""),
      _serviceList = signal([]),
      _currentServiceID = signal("") {}

  void setToken(String value) {
    _token.value = value;
  }

  void setAccount(String value) {
    _account.value = value;
  }

  void setServiceList(List<ServiceEntity> value) {
    _serviceList.value = List.unmodifiable(value);

    if (value.isNotEmpty && currentServiceID.value.isEmpty) {
      setCurrentServiceID(value.first.service_id);
    }
  }

  void setCurrentServiceID(String value) {
    _currentServiceID.value = value;
  }

  void refreshServiceList() {
    if (_account.value.isEmpty) return;

    API.serviceList(_account.value).then((res) {
      userInfoManager.setServiceList(res);
    });
  }
}
