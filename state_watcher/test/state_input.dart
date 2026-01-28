import 'package:ff/fw.dart';

part 'state_input.state.ff.dart';

// ff-state
class $ExampleState {
  const $ExampleState({
    required String name,
    required int count,
    required bool isActive,
    required Map<String, bool> flags,
  });

  static ExampleState initial() => ExampleState.loading(
        name: '',
        count: 0,
        isActive: false,
        flags: {},
      );
}
