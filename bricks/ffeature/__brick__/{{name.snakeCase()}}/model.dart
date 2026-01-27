import 'package:ff/fw.dart';

import 'state.dart';

class {{name.pascalCase()}}Model extends FFViewModel<{{name.pascalCase()}}StateGetters, {{name.pascalCase()}}State> {
  const {{name.pascalCase()}}Model(super.state);

  // do it like this (or if the state.property is a map, use fromStateMap)
  bool yourModelProperty(BuildContext context) =>
      fromState(context, (state) => state.addYourParamsHere);

  @override
  String title(BuildContext context) {
    return '{{name.pascalCase()}} View';
  }
}