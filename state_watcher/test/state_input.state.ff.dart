// generated file, do not edit

part of 'state_input.dart';

extension _FFLX<T> on _FFMd<T> {
  _FFMd<T> doLoadingIf(bool loading) => loading ? _FFMd<T>.loading(prop) : this;
}

typedef _FFMd<T> = FFPropWithMetadata<T>;

// ============================================================================
// ExampleState
// ============================================================================

abstract interface class ExampleStateGetters {
  String get name;
  int get count;
  bool get isActive;
  Map<String, bool> get flags;

  ExampleState loaded({
    String? name,
    int? count,
    bool? isActive,
    Map<String, _FFMd<bool>>? flags,
  });

  ExampleState loading({
    bool name = false,
    bool count = false,
    bool isActive = false,
    bool flags = false,
  });
}

class ExampleState implements WatchableProps<ExampleStateGetters> {
  final _FFMd<String> _name;
  final _FFMd<int> _count;
  final _FFMd<bool> _isActive;
  final _FFMd<Map<String, _FFMd<bool>>> _flags;

  //FIXME: this is a stupid workaround to make the map not be shared between the watched and unwatched state
  final Map<String, _FFMd<bool>> _flagsCopy;

  ExampleState.mixed({
    required _FFMd<String> name,
    required _FFMd<int> count,
    required _FFMd<bool> isActive,
    required _FFMd<Map<String, _FFMd<bool>>> flags,
  })  : _name = name,
        _count = count,
        _isActive = isActive,
        _flags = flags,
        _flagsCopy = {...flags.prop};

  ExampleState.loaded({
    required String name,
    required int count,
    required bool isActive,
    required Map<String, _FFMd<bool>> flags,
  })  : _name = name.fwLoaded,
        _count = count.fwLoaded,
        _isActive = isActive.fwLoaded,
        _flags = flags.fwLoaded,
        _flagsCopy = {...flags};

  ExampleState.loading({
    required String name,
    required int count,
    required bool isActive,
    required Map<String, _FFMd<bool>> flags,
  })  : _name = name.fwLoading,
        _count = count.fwLoading,
        _isActive = isActive.fwLoading,
        _flags = flags.fwLoading,
        _flagsCopy = {...flags};

  ExampleStateUnwatched get unwatched => ExampleStateUnwatched(state: this);

  ExampleStateWatched watched(BuildContext context) =>
      ExampleStateWatched(state: this, context: context);

  @override
  Iterable<Symbol> get propNames => [#ExampleState.name, #ExampleState.count, #ExampleState.isActive, #ExampleState.flags];

  @override
  FFPropWithMetadata<dynamic> getProp(Symbol propName) => switch (propName) {
    #ExampleState.name => _name,
    #ExampleState.count => _count,
    #ExampleState.isActive => _isActive,
    #ExampleState.flags => _flags,
    Symbol(nonSuffix: 'ExampleState.flags', :final suffix) =>
      _flagsCopy[suffix] ?? FFNever().fwLoading,
    _ => throw UnimplementedError('Unknown prop: $propName'),
  };
}

class ExampleStateUnwatched extends ExampleStateGetters {
  ExampleStateUnwatched({required this.state});

  final ExampleState state;

  @override
  String get name => state._name.prop;
  @override
  int get count => state._count.prop;
  @override
  bool get isActive => state._isActive.prop;
  @override
  FFDynamicallySizedPropsUnwatched<bool> get flags =>
      FFDynamicallySizedPropsUnwatched(inner: state._flags.prop);

  @override
  ExampleState loading({
    bool name = false,
    bool count = false,
    bool isActive = false,
    bool flags = false,
  }) => ExampleState.mixed(
    name: state._name.doLoadingIf(name),
    count: state._count.doLoadingIf(count),
    isActive: state._isActive.doLoadingIf(isActive),
    flags: state._flags.doLoadingIf(flags),
  );

  @override
  ExampleState loaded({
    String? name,
    int? count,
    bool? isActive,
    Map<String, _FFMd<bool>>? flags,
  }) => ExampleState.mixed(
    name: name?.fwLoaded ?? state._name,
    count: count?.fwLoaded ?? state._count,
    isActive: isActive?.fwLoaded ?? state._isActive,
    flags: flags?.fwLoaded ?? state._flags,
  );
}

class ExampleStateWatched extends ExampleStateGetters with FFWatchHelper<ExampleState> {
  ExampleStateWatched({required this.state, required this.context});

  final ExampleState state;
  final BuildContext context;

  @override
  String get name => read(#ExampleState.name, state._name);
  @override
  int get count => read(#ExampleState.count, state._count);
  @override
  bool get isActive => read(#ExampleState.isActive, state._isActive);
  @override
  Map<String, bool> get flags {
    final map = read(#ExampleState.flags, state._flags);
    return FFDynamicallySizedProps(
      inner: map,
      read: (key) => map.containsKey(key)
          ? read(Symbol('ExampleState.flags.$key'), map[key]!)
          : null,
    );
  }

  @override
  /// DO NOT USE this from watched state, use unwatched state instead
  ExampleState loaded({
    String? name,
    int? count,
    bool? isActive,
    Map<String, _FFMd<bool>>? flags,
  }) {
    debugPrint('calling changed from watched state, this shall not be done');
    return state.unwatched.loaded(name: name, count: count, isActive: isActive, flags: flags);
  }

  @override
  /// DO NOT USE this from watched state, use unwatched state instead
  ExampleState loading({
    bool name = false,
    bool count = false,
    bool isActive = false,
    bool flags = false,
  }) {
    debugPrint('calling loading from watched state, this shall not be done');
    return state.unwatched.loading(name: name, count: count, isActive: isActive, flags: flags);
  }
}

// SECTION typedef helpers

typedef ExampleStateWidget<
  Controller extends FFController<ExampleStateGetters, ExampleState>,
  ViewModel extends FFViewModel<ExampleStateGetters, ExampleState>
> = FFWidget<ExampleStateGetters, ExampleState, ViewModel, Controller>;

typedef ExampleStateView<
  Controller extends FFController<ExampleStateGetters, ExampleState>,
  ViewModel extends FFViewModel<ExampleStateGetters, ExampleState>
> = FFView<ExampleStateGetters, ExampleState, ViewModel, Controller>;

typedef ExampleStatePresenter<
  Controller extends FFController<ExampleStateGetters, ExampleState>,
  ViewModel extends FFViewModel<ExampleStateGetters, ExampleState>
> = FFPresenter<ExampleStateGetters, ExampleState, ViewModel, Controller>;

typedef ExampleStateBuilder<
  Controller extends FFController<ExampleStateGetters, ExampleState>,
  ViewModel extends FFViewModel<ExampleStateGetters, ExampleState>
> = FFBuilder<ExampleStateGetters, ExampleState, ViewModel, Controller>;

// SECTION features

typedef ExampleStateFeature<
  Controller extends FFController<ExampleStateGetters, ExampleState>,
  ViewModel extends FFViewModel<ExampleStateGetters, ExampleState>
> = FFFeature<ExampleStateGetters, ExampleState, ViewModel, Controller>;

typedef ExampleStateReusableFeature<
  Controller extends FFController<ExampleStateGetters, ExampleState>,
  ViewModel extends FFViewModel<ExampleStateGetters, ExampleState>
> = FFReusableFeature<ExampleStateGetters, ExampleState, ViewModel, Controller>;

typedef ExampleStateReusableMultiFeature<
  Param,
  Controller extends FFController<ExampleStateGetters, ExampleState>,
  ViewModel extends FFViewModel<ExampleStateGetters, ExampleState>
> =
    FFReusableMultiFeature<
      Param,
      ExampleStateGetters,
      ExampleState,
      ViewModel,
      Controller
    >;

typedef ExampleStateSimpleFeature<
  Controller extends FFController<ExampleStateGetters, ExampleState>,
  ViewModel extends FFViewModel<ExampleStateGetters, ExampleState>
> = FFSimpleFeature<ExampleStateGetters, ExampleState, ViewModel, Controller>;
// END SECTION features

// END SECTION typedef helpers

