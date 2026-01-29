part of 'ff.dart';

class FFProvider<FFState extends GetProps> extends InheritedModel<Symbol> {
  const FFProvider({super.key, required super.child, required this.state});

  final FFState state;

  @override
  bool updateShouldNotify(covariant FFProvider<FFState> oldWidget) {
    return oldWidget.state != state;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant FFProvider<FFState> oldWidget,
    Set<Symbol> dependencies,
  ) {
    final rebuilds = dependencies.any(
      (dependency) =>
          oldWidget.state.getProp(dependency) != state.getProp(dependency),
    );
    if (rebuilds) {
      debugPrint('rebuilding $dependencies');
    }
    return rebuilds;
  }
}

class FFVmAndControllerProvider<
  Watched,
  FFState extends Watchable<Watched>,
  ViewModel extends FFViewModel<Watched, FFState>,
  Controller extends FFController<Watched, FFState>
>
    extends InheritedWidget {
  const FFVmAndControllerProvider({
    super.key,
    required super.child,
    required this.controller,
    required this.viewModel,
  });

  final Controller controller;
  final ViewModel viewModel;

  static FFVmAndControllerProvider<Watched, FFState, ViewModel, Controller>?
  maybeOf<
    Watched,
    FFState extends Watchable<Watched>,
    ViewModel extends FFViewModel<Watched, FFState>,
    Controller extends FFController<Watched, FFState>
  >(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<
          FFVmAndControllerProvider<Watched, FFState, ViewModel, Controller>
        >();
  }

  static FFVmAndControllerProvider<Watched, FFState, ViewModel, Controller>
  of<
    Watched,
    FFState extends Watchable<Watched>,
    ViewModel extends FFViewModel<Watched, FFState>,
    Controller extends FFController<Watched, FFState>
  >(BuildContext context) {
    final result = maybeOf<Watched, FFState, ViewModel, Controller>(context);
    if (result == null) {
      throw Exception(
        'No FFVmAndControllerProvider<$ViewModel, $Controller> found in context',
      );
    }
    return result;
  }

  @override
  bool updateShouldNotify(
    covariant FFVmAndControllerProvider<
      Watched,
      FFState,
      ViewModel,
      Controller
    >
    oldWidget,
  ) {
    // we just want to get the initial controller and viewmodel in constant time, no need to update
    // all the widgets that need updates, will be enrolled by the viewmodel getters
    return false;
  }
}

class _FFBuilder<
  Watched,
  FFState extends WatchableProps<Watched>,
  ViewModel extends FFViewModel<Watched, FFState>,
  Controller extends FFController<Watched, FFState>
>
    extends StatefulWidget {
  const _FFBuilder({
    super.key,
    required this.controller,
    required this.viewModel,
    required this.child,
    required this.shallDisposeController,
  });

  final Controller controller;
  final ViewModel Function(FFState state) viewModel;
  final Widget child;
  final bool shallDisposeController;

  @override
  State<_FFBuilder<Watched, FFState, ViewModel, Controller>> createState() =>
      _FFBuilderState<Watched, FFState, ViewModel, Controller>();
}

class _FFBuilderState<
  Watched,
  FFState extends WatchableProps<Watched>,
  ViewModel extends FFViewModel<Watched, FFState>,
  Controller extends FFController<Watched, FFState>
>
    extends State<_FFBuilder<Watched, FFState, ViewModel, Controller>> {
  late FFState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.controller.innerState;
    widget.controller.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChanged);
    if (widget.shallDisposeController) widget.controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {
      _state = widget.controller.innerState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FFVmAndControllerProvider<
      Watched,
      FFState,
      ViewModel,
      Controller
    >(
      controller: widget.controller,
      viewModel: widget.viewModel(_state),
      child: FFProvider<FFState>(state: _state, child: widget.child),
    );
  }
}

// SECTION: Shimmer / loading

class FFShimmerMan extends StatefulWidget {
  static FFShimmerData? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FFShimmerData>();

  const FFShimmerMan({super.key, required this.child});

  final Widget child;

  @override
  FFShimmerManState createState() => FFShimmerManState();
}

class FFShimmerManState extends State<FFShimmerMan> {
  final Set<Symbol> _shimmeringProps = {};

  bool get isShimmering => _shimmeringProps.isNotEmpty;

  void onShimmeringChange(Symbol prop, bool newValue) {
    setState(() {
      if (newValue) {
        _shimmeringProps.add(prop);
      } else {
        _shimmeringProps.remove(prop);
      }
    });
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(
      DiagnosticsProperty<Set<Symbol>>("shimmeringProps", _shimmeringProps),
    );
    super.debugFillProperties(properties);
  }

  @override
  Widget build(BuildContext context) {
    // the outer is only a helper to be compatible with the other UI Components
    return FF.buildShimmer(
      isShimmering: isShimmering,
      context: context,
      child: FFShimmerData(
        isShimmering: isShimmering,
        onShimmeringChange: onShimmeringChange,
        child: widget.child,
      ),
    );
  }
}

class FFShimmerData extends InheritedWidget {
  final bool isShimmering;
  final void Function(Symbol prop, bool newValue) onShimmeringChange;

  const FFShimmerData({
    super.key,
    required this.isShimmering,
    required this.onShimmeringChange,
    required super.child,
  });

  @override
  bool updateShouldNotify(FFShimmerData oldWidget) {
    return oldWidget.isShimmering != isShimmering;
  }
}
