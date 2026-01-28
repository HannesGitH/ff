part of 'test.dart';

extension _FwLX<T> on _FwMd<T> {
  _FwMd<T> doLoadingIf(bool loading) => loading ? _FwMd<T>.loading(prop) : this;
}

typedef _FwMd<T> = NewFwPropWithMetadata<T>;

abstract interface class TestStateGetters {
  Color get color;
  String get text;
  Map<String, bool> get smiles;

  TestState loaded({
    Color? color,
    String? text,
    Map<String, _FwMd<bool>>? smiles,
  });

  TestState loading({
    bool color = false,
    bool text = false,
    bool smiles = false,
  });
}

class TestState implements WatchableProps<TestStateGetters> {
  final _FwMd<Color> _color;
  final _FwMd<String> _text;
  final _FwMd<Map<String, _FwMd<bool>>> _smiles;

  //FIXME: this is a stupid workaround to make the map not be shared between the watched and unwatched state
  final Map<String, _FwMd<bool>> _smilesCopy;

  TestState.mixed({
    required _FwMd<Color> color,
    required _FwMd<String> text,
    required _FwMd<Map<String, _FwMd<bool>>> smiles,
  }) : _color = color,
       _text = text,
       _smiles = smiles,
       _smilesCopy = {...smiles.prop};

  TestState.loaded({
    required Color color,
    required String text,
    required Map<String, _FwMd<bool>> smiles,
  }) : _color = color.fwLoaded,
       _text = text.fwLoaded,
       _smiles = smiles.fwLoaded,
       _smilesCopy = {...smiles};

  TestState.loading({
    required Color color,
    required String text,
    required Map<String, _FwMd<bool>> smiles,
  }) : _color = color.fwLoading,
       _text = text.fwLoading,
       _smiles = smiles.fwLoading,
       _smilesCopy = {...smiles};

  TestStateUnwatched get unwatched => TestStateUnwatched(state: this);

  TestStateWatched watched(BuildContext context) =>
      TestStateWatched(state: this, context: context);

  @override
  Iterable<Symbol> get propNames => [#TestState.color, #TestState.text];

  @override
  NewFwPropWithMetadata<dynamic> getProp(Symbol propName) => switch (propName) {
    #TestState.color => _color,
    #TestState.text => _text,
    #TestState.smiles => _smiles,
    Symbol(nonSuffix: 'TestState.smiles', :final suffix) =>
      _smilesCopy[suffix] ?? NewFwNever().fwLoading,
    _ => throw UnimplementedError('Unknown prop: $propName'),
  };
}

class TestStateUnwatched extends TestStateGetters {
  TestStateUnwatched({required this.state});

  final TestState state;

  // NewFwDynamicallySizedPropsUnwatched<bool>? _smilesWrapped;

  @override
  Color get color => state._color.prop;
  @override
  String get text => state._text.prop;
  @override
  NewFwDynamicallySizedPropsUnwatched<bool> get smiles =>
      NewFwDynamicallySizedPropsUnwatched(inner: state._smiles.prop);
  // {
  //   _smilesWrapped ??= NewFwDynamicallySizedPropsUnwatched(inner: state._smiles.prop);
  //   return _smilesWrapped!;
  // }

  @override
  TestState loading({
    bool color = false,
    bool text = false,
    bool smiles = false,
  }) => TestState.mixed(
    color: state._color.doLoadingIf(color),
    text: state._text.doLoadingIf(text),
    smiles: state._smiles.doLoadingIf(smiles),
  );

  @override
  TestState loaded({
    Color? color,
    String? text,
    Map<String, _FwMd<bool>>? smiles,
  }) => TestState.mixed(
    color: color?.fwLoaded ?? state._color,
    text: text?.fwLoaded ?? state._text,
    smiles: smiles?.fwLoaded ?? state._smiles,
  );
}

class TestStateWatched extends TestStateGetters with NewFwWatchHelper<TestState> {
  TestStateWatched({required this.state, required this.context});

  final TestState state;
  final BuildContext context;

  @override
  Color get color => read(#TestState.color, state._color);
  @override
  String get text => read(#TestState.text, state._text);
  @override
  Map<String, bool> get smiles {
    final map = read(#TestState.smiles, state._smiles);
    return NewFwDynamicallySizedProps(
      inner: map,
      read: (key) => map.containsKey(key)
          ? read(Symbol('TestState.smiles.$key'), map[key]!)
          : null,
    );
  }

  @override
  /// DO NOT USE this from watched state, use unwatched state instead
  TestState loaded({
    Color? color,
    String? text,
    Map<String, _FwMd<bool>>? smiles,
  }) {
    debugPrint('calling changed from watched state, this shall not be done');
    return state.unwatched.loaded(color: color, text: text, smiles: smiles);
  }

  @override
  /// DO NOT USE this from watched state, use unwatched state instead
  TestState loading({
    bool color = false,
    bool text = false,
    bool smiles = false,
  }) {
    debugPrint('calling loading from watched state, this shall not be done');
    return state.unwatched.loading(color: color, text: text, smiles: smiles);
  }
}

// SECTION typedef helpers

typedef TestStateWidget<
  Controller extends NewFwController<TestStateGetters, TestState>,
  ViewModel extends NewFwViewModel<TestStateGetters, TestState>
> = NewFwWidget<TestStateGetters, TestState, ViewModel, Controller>;

typedef TestStateView<
  Controller extends NewFwController<TestStateGetters, TestState>,
  ViewModel extends NewFwViewModel<TestStateGetters, TestState>
> = NewFwView<TestStateGetters, TestState, ViewModel, Controller>;

typedef TestStatePresenter<
  Controller extends NewFwController<TestStateGetters, TestState>,
  ViewModel extends NewFwViewModel<TestStateGetters, TestState>
> = NewFwPresenter<TestStateGetters, TestState, ViewModel, Controller>;

typedef TestStateBuilder<
  Controller extends NewFwController<TestStateGetters, TestState>,
  ViewModel extends NewFwViewModel<TestStateGetters, TestState>
> = NewFwBuilder<TestStateGetters, TestState, ViewModel, Controller>;

// SECTION features

typedef TestStateFeature<
  Controller extends NewFwController<TestStateGetters, TestState>,
  ViewModel extends NewFwViewModel<TestStateGetters, TestState>
> = NewFwFeature<TestStateGetters, TestState, ViewModel, Controller>;

typedef TestStateReusableFeature<
  Controller extends NewFwController<TestStateGetters, TestState>,
  ViewModel extends NewFwViewModel<TestStateGetters, TestState>
> = NewFwReusableFeature<TestStateGetters, TestState, ViewModel, Controller>;

typedef TestStateReusableMultiFeature<
  Param,
  Controller extends NewFwController<TestStateGetters, TestState>,
  ViewModel extends NewFwViewModel<TestStateGetters, TestState>
> =
    NewFwReusableMultiFeature<
      Param,
      TestStateGetters,
      TestState,
      ViewModel,
      Controller
    >;

typedef TestStateSimpleFeature<
  Controller extends NewFwController<TestStateGetters, TestState>,
  ViewModel extends NewFwViewModel<TestStateGetters, TestState>
> = NewFwSimpleFeature<TestStateGetters, TestState, ViewModel, Controller>;
// END SECTION features

// END SECTION typedef helpers
