import 'package:ff/ff.dart';

part 'state.ff.dart';

// this class itself is not used, it just defines what properties the state will have
// ff will know to generate them when it is marked with the magic-token:
// ff-state
class ${{name.pascalCase()}}State {
  const ${{name.pascalCase()}}State({
    required bool addYourParamsHere,
  })
  
  // this is optional, but helps in creating an initial loading state
  static {{name.pascalCase()}}State initial() => ${{name.pascalCase()}}State.loading(addYourParamsHere: false);
}