part of 'fw.dart';


abstract class FFController<Watched, State extends Watchable<Watched>>
    extends ChangeNotifier {
  FFController({required State initialState}) : _state = initialState;

  late State _state;
  State get innerState => _state;
  Watched get state => _state.unwatched;

  void emit(State newState) {
    _state = newState;
    notifyListeners();
  }
}
