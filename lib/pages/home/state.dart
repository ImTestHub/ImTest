part of 'page.dart';

class HomeState {
  final msgList = signal<Map<String, List<MsgEntity>>>({});

  final content = signal("");
}
