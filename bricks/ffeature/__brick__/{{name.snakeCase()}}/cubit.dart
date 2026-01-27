import 'package:ff/fw.dart';

import 'state.dart';

class {{name.pascalCase()}}Controller extends FFController<{{name.pascalCase()}}StateGetters, {{name.pascalCase()}}State> {
  {{name.pascalCase()}}Controller({required super.initialState});

  void yourControllerMethod() {
    emit(state.loaded(addYourParamsHere: !state.addYourParamsHere));
  }
}