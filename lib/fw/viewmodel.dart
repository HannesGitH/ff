part of 'fw.dart';

abstract class FFViewModel<Watched, State extends Watchable<Watched>> {
  final State _state;
  const FFViewModel(State state) : _state = state;
  T fromState<T>(BuildContext context, T Function(Watched state) builder) =>
      builder(_state.watched(context));

  FFDynamicModel<Model> fromStateMap<Model, Prop>(
    BuildContext context,
    Map<String, Prop> Function(Watched state) stateMap,
    Model Function(Prop prop) build,
  ) => FFDynamicModel(
    allowedKeys: stateMap(_state.watched(context)).keys.toList(),
    build: (key, context) => build(stateMap(_state.watched(context))[key] as Prop),
  );

  String title(BuildContext context);
}

class FFDynamicModel<T> {
  final List<String> allowedKeys;
  final T Function(String key, BuildContext context) build;
  FFDynamicModel({required this.allowedKeys, required this.build});
}
