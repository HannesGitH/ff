part of 'fw.dart';

abstract class FFFeature<
  Watched,
  FFState extends WatchableProps<Watched>,
  ViewModel extends FFViewModel<Watched, FFState>,
  Controller extends FFController<Watched, FFState>
> {}

/// usage: extend this class and define every entry as a function that internally calls show
abstract class FFReusableFeature<
  Watched,
  FFState extends WatchableProps<Watched>,
  ViewModel extends FFViewModel<Watched, FFState>,
  Controller extends FFController<Watched, FFState>
>
    extends FFFeature<Watched, FFState, ViewModel, Controller> {
  FFReusableFeature();

  Controller mkController();

  ViewModel mkViewModel(FFState state);

  Controller? _controller;

  // replaces global controllers, as the features will be held by the app
  Controller get controller => _controller ??= mkController();

  void shutdown() {
    _controller?.dispose();
    _controller = null;
  }

  Future<void> show({
    required BuildContext context,
    required FFView<Watched, FFState, ViewModel, Controller> view,
    required FFPresentationType asType,
  }) => FFPresenter<Watched, FFState, ViewModel, Controller>(
      controller: controller,
      shallDisposeController: false,
      viewModel: mkViewModel,
    ).show(context: context, view: view, asType: asType);
}

/// usage: extend this class and define every entry as a function that internally calls show
/// e.g. .showForCard(cardId: cardId) where cardId is the param
abstract class FFReusableMultiFeature<
  Param,
  Watched,
  FFState extends WatchableProps<Watched>,
  ViewModel extends FFViewModel<Watched, FFState>,
  Controller extends FFController<Watched, FFState>
>
    extends FFFeature<Watched, FFState, ViewModel, Controller> {
  FFReusableMultiFeature();

  Controller mkController(Param param);

  ViewModel mkViewModel(Param param, FFState state);

  final Map<Param, Controller> _controllers = {};

  void shutdownFull() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  void shutdown(Param param) {
    _controllers.remove(param)?.dispose();
  }

  Future<void> show({
    required Param param,
    required BuildContext context,
    required FFView<Watched, FFState, ViewModel, Controller> view,
    required FFPresentationType asType,
  }) async {
    _controllers[param] ??= mkController(param);
    return FFPresenter<Watched, FFState, ViewModel, Controller>(
      controller: _controllers[param]!,
      shallDisposeController: false,
      viewModel: (state) => mkViewModel(param, state),
    ).show(context: context, view: view, asType: asType);
  }
}

// usage: here, the controller will be created for every feature entry and every time
abstract class FFSimpleFeature<
  Watched,
  FFState extends WatchableProps<Watched>,
  ViewModel extends FFViewModel<Watched, FFState>,
  Controller extends FFController<Watched, FFState>
>
    extends FFFeature<Watched, FFState, ViewModel, Controller> {
  FFSimpleFeature();

  Future<void> show({
    required BuildContext context,
    required Controller Function() mkController,
    required ViewModel Function(FFState state) mkViewModel,
    required FFView<Watched, FFState, ViewModel, Controller> view,
    required FFPresentationType asType,
  }) async {
    return FFPresenter<Watched, FFState, ViewModel, Controller>(
      controller: mkController(),
      shallDisposeController: true,
      viewModel: mkViewModel,
    ).show(context: context, view: view, asType: asType);
  }
}
