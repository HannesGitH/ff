part of 'fw.dart';


abstract class FFController<Watched, FFState extends Watchable<Watched>>
    extends ChangeNotifier {
  FFController({required FFState initialState}) : _state = initialState;

  late FFState _state;
  FFState get innerState => _state;
  Watched get state => _state.unwatched;

  void emit(FFState newState) {
    _state = newState;
    notifyListeners();
  }

  BuildContext? context;
}
