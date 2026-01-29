part of 'fw.dart';

enum FFPropLoadingStateType { loading, loaded }

extension ToFFLoadedObjectWrapperHelper<T> on T {
  FFPropWithMetadata<T> get ffLoaded => FFPropWithMetadata.loaded(this);
  FFPropWithMetadata<T> get ffLoading => FFPropWithMetadata.loading(this);
}

class FFPropWithMetadata<Prop> {
  final Prop prop;
  final FFPropLoadingStateType state;

  const FFPropWithMetadata({required this.prop, required this.state});

  const FFPropWithMetadata.loading(this.prop)
    : state = FFPropLoadingStateType.loading;
  const FFPropWithMetadata.loaded(this.prop)
    : state = FFPropLoadingStateType.loaded;

  FFPropWithMetadata<Prop> Function({
    Prop? prop,
    FFPropLoadingStateType? state,
  })
  get copyWith =>
      ({Object? prop = Never, Object? state = Never}) => FFPropWithMetadata(
        prop: prop._or(this.prop),
        state: state._or(this.state),
      );

  FFPropWithMetadata<Prop> loading() => FFPropWithMetadata.loading(prop);

  bool get isLoading => state == FFPropLoadingStateType.loading;
  bool get isLoaded => state == FFPropLoadingStateType.loaded;

  @override
  int get hashCode => prop.hashCode ^ state.hashCode;

  @override
  bool operator ==(covariant FFPropWithMetadata<Prop> other) {
    return prop == other.prop && state == other.state;
  }
}

extension on Object? {
  // T? _as<T>() => this is T ? this as T : null;
  // ignore: unused_element
  T _or<T>(T other) => this is T ? this as T : other;
}

extension FFSymbolHelpers on Symbol {
  String get name => toString().substring(8, toString().length - 2);
  List<String> get nameParts => name.split('.');
  int get namePartsLength => nameParts.length;

  String get suffix => nameParts.last;
  String get nonSuffix => nameParts.sublist(0, namePartsLength - 1).join('.');
  String get prefix => nameParts.first;
}

abstract interface class GetProps {
  Iterable<Symbol> get propNames;
  FFPropWithMetadata<dynamic> getProp(Symbol propName);
}

abstract interface class Watchable<T> {
  T watched(BuildContext context);
  T get unwatched;
}

abstract interface class WatchableProps<T> implements GetProps, Watchable<T> {}

class FFError extends Error {
  final String message;
  FFError(this.message);
  @override
  String toString() => 'FFError: $message';
}

class FFWatchedMappedIllegalOperation extends FFError {
  FFWatchedMappedIllegalOperation(String operation)
    : super(
        'illegal operation for a watched map: "$operation", use view.iterateOver or view.itemBuilderFor instead',
      );
}

class FFDynamicallySizedPropsUnwatched<T> implements Map<String, T> {
  final Map<String, FFPropWithMetadata<T>> inner;
  const FFDynamicallySizedPropsUnwatched({required this.inner});

  @override
  T? operator [](Object? key) {
    return inner[key]?.prop;
  }

  void loaded(String key, T value) {
    inner[key] = value.ffLoaded;
  }

  void loading(String key, T value) {
    inner[key] = value.ffLoading;
  }

  @override
  void operator []=(String key, T value) {
    final old = inner[key];
    inner[key] = old?.copyWith(prop: value) ?? value.ffLoaded;
  }

  @override
  void addAll(Map<String, T> other) {
    other.forEach((key, value) => this[key] = value);
  }

  @override
  void addEntries(Iterable<MapEntry<String, T>> newEntries) {
    for (var entry in newEntries) {
      this[entry.key] = entry.value;
    }
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    return inner.cast<RK, RV>();
  }

  @override
  void clear() {
    inner.clear();
  }

  @override
  bool containsKey(Object? key) {
    return inner.containsKey(key);
  }

  @override
  bool containsValue(Object? value) {
    return inner.containsValue(value) ||
        inner.values.any((element) => element.prop == value);
  }

  @override
  Iterable<MapEntry<String, T>> get entries =>
      inner.entries.map((entry) => MapEntry(entry.key, entry.value.prop));

  @override
  void forEach(void Function(String key, T value) action) {
    inner.forEach((key, value) => action(key, value.prop));
  }

  @override
  bool get isEmpty => inner.isEmpty;

  @override
  bool get isNotEmpty => inner.isNotEmpty;

  @override
  Iterable<String> get keys => inner.keys;

  @override
  int get length => inner.length;

  @override
  Map<K2, V2> map<K2, V2>(
    MapEntry<K2, V2> Function(String key, T value) convert,
  ) {
    return inner.map(
      (key, value) => MapEntry(
        convert(key, value.prop).key,
        convert(key, value.prop).value,
      ),
    );
  }

  @override
  T putIfAbsent(String key, T Function() ifAbsent) {
    return inner.putIfAbsent(key, () => ifAbsent().ffLoaded).prop;
  }

  @override
  T? remove(Object? key) {
    return inner.remove(key)?.prop;
  }

  @override
  void removeWhere(bool Function(String key, T value) test) {
    inner.removeWhere((key, value) => test(key, value.prop));
  }

  @override
  T update(String key, T Function(T value) update, {T Function()? ifAbsent}) {
    return inner.update(key, (value) => update(value.prop).ffLoaded).prop;
  }

  @override
  void updateAll(T Function(String key, T value) update) {
    inner.updateAll((key, value) => update(key, value.prop).ffLoaded);
  }

  @override
  Iterable<T> get values => inner.values.map((value) => value.prop);

  Map<String, FFPropWithMetadata<T>> get ffAllLoaded {
    for (final key in keys) {
      inner[key] = this[key]!.ffLoaded;
    }
    return inner;
  }

  Map<String, FFPropWithMetadata<T>> get ffAllLoading {
    for (final key in keys) {
      inner[key] = this[key]!.ffLoading;
    }
    return inner;
  }
}

class FFDynamicallySizedProps<T> implements Map<String, T> {
  final Map<String, FFPropWithMetadata<T>> inner;
  final T? Function(String key) read;
  FFDynamicallySizedProps({required this.inner, required this.read});

  Iterable<String>? _keys;

  @override
  Iterable<String> get keys => _keys ??= inner.keys;

  T? get(String key) => read(key);
  T? getIndex(int index) => read(inner.keys.elementAt(index));

  @override
  operator ==(Object other) => inner == other;

  @override
  int get hashCode => inner.hashCode;

  @override
  int get length => inner.length;
  @override
  T? operator [](covariant String key) => get(key);

  @override
  void operator []=(String key, T value) =>
      throw FFWatchedMappedIllegalOperation('set ([]=)');

  @override
  void addAll(Map<String, T> other) =>
      throw FFWatchedMappedIllegalOperation('addAll');

  @override
  void addEntries(Iterable<MapEntry<String, T>> newEntries) =>
      throw FFWatchedMappedIllegalOperation('addEntries');

  @override
  Map<RK, RV> cast<RK, RV>() {
    throw FFWatchedMappedIllegalOperation('cast');
  }

  @override
  void clear() {
    throw FFWatchedMappedIllegalOperation('clear');
  }

  @override
  bool containsKey(Object? key) => inner.containsKey(key);

  @override
  bool containsValue(Object? value) => inner.containsValue(value);

  @override
  Iterable<MapEntry<String, T>> get entries =>
      inner.entries.map((entry) => MapEntry(entry.key, entry.value.prop));

  @override
  void forEach(void Function(String key, T value) action) =>
      inner.forEach((key, value) => action(key, value.prop));

  @override
  bool get isEmpty => inner.isEmpty;

  @override
  bool get isNotEmpty => inner.isNotEmpty;

  @override
  Map<K2, V2> map<K2, V2>(
    MapEntry<K2, V2> Function(String key, T value) convert,
  ) => inner.map(
    (key, value) =>
        MapEntry(convert(key, value.prop).key, convert(key, value.prop).value),
  );
  @override
  T putIfAbsent(String key, T Function() ifAbsent) {
    throw FFWatchedMappedIllegalOperation('putIfAbsent');
  }

  @override
  T? remove(Object? key) {
    throw FFWatchedMappedIllegalOperation('remove');
  }

  @override
  void removeWhere(bool Function(String key, T value) test) {
    throw FFWatchedMappedIllegalOperation('removeWhere');
  }

  @override
  T update(String key, T Function(T value) update, {T Function()? ifAbsent}) {
    throw FFWatchedMappedIllegalOperation('update');
  }

  @override
  void updateAll(T Function(String key, T value) update) {
    throw FFWatchedMappedIllegalOperation('updateAll');
  }

  @override
  Iterable<T> get values => inner.values.map((value) => value.prop);
}

extension FFPropWithMetadataMapHelpers<T> on Map<String, T> {
  Map<String, FFPropWithMetadata<T>> get ffAllLoaded {
    if (this case FFDynamicallySizedPropsUnwatched<T> wrapped) {
      return wrapped.ffAllLoaded;
    }
    return map((key, value) => MapEntry(key, value.ffLoaded));
  }

  Map<String, FFPropWithMetadata<T>> get ffAllLoading {
    if (this case FFDynamicallySizedPropsUnwatched<T> wrapped) {
      return wrapped.ffAllLoading;
    }
    return map((key, value) => MapEntry(key, value.ffLoading));
  }

  void loaded(String key, T value) {
    if (this case FFDynamicallySizedPropsUnwatched<T> wrapped) {
      wrapped.loaded(key, value);
    }
  }

  void loading(String key, T value) {
    if (this case FFDynamicallySizedPropsUnwatched<T> wrapped) {
      wrapped.loading(key, value);
    }
  }
}

class FFNever {
  @override
  bool operator ==(Object other) => false;
  @override
  int get hashCode => 0;
}

mixin FFWatchHelper<FFState extends GetProps> {
  BuildContext get context;

  T read<T>(Symbol prop, FFPropWithMetadata<T> data) {
    _addStateDependentListeners(prop);
    _updateShimmerIfNecessary(prop, data);
    return data.prop;
  }

  void _addStateDependentListeners(Symbol prop) {
    InheritedModel.inheritFrom<FFProvider<FFState>>(context, aspect: prop);
  }

  void _updateShimmerIfNecessary(Symbol prop, FFPropWithMetadata data) {
    // FIXME: wir wollen den shimmer ungern post-frame updaten
    context.widget.debugFillProperties(
      DiagnosticPropertiesBuilder()
        ..add(DiagnosticsProperty<bool>("shimmer", data.isLoading)),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      FFShimmerMan.of(context)?.onShimmeringChange(prop, data.isLoading);
    });
  }
}
