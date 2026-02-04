part of 'page.dart';

class HomeState {
  final msgList = signal<Map<String, List<MsgEntity>>>({});

  final content = signal("");

  final notifyServiceID = signal<List<String>>([]);

  final menuOpen = signal(true);
}
