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

  /// this context is only usable (set) after this controller has been attached to at least one widget
  /// it always points to the context of the newest widget the controller is used in
  /// if you want to access the context before the controller is attached to a widget, DONT
  late BuildContext context;
}
