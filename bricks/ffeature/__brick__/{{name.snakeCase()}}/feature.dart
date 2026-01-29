//! if this is not supposed to be a app-available feature, you can remove this file

import 'package:ff/ff.dart';

import 'controller.dart';
import 'model.dart';
import 'state.dart';
import 'views/main.dart';

// if the controller should be regenerated for every entry, use {{name.pascalCase()}}SimpleFeature
// if you plan to have the entry depend on some data, like e.g. showing a specific user from a user-id, use {{name.pascalCase()}}ReusableMultiFeature
class {{name.pascalCase()}}Feature extends {{name.pascalCase()}}ReusableFeature_ {
  @override
  {{name.pascalCase()}}Controller mkController() =>
      {{name.pascalCase()}}Controller(initialState: {{name.pascalCase()}}State.loading());

  @override
  {{name.pascalCase()}}Model mkViewModel({{name.pascalCase()}}State state) => {{name.pascalCase()}}Model(state);

  // add every entry point this feature has, in a similar manner to this
  Future<void> showEntry(BuildContext context) async {
    await show(
      context: context,
      view: const {{name.pascalCase()}}View(),
      asType: FFPresentationType.route,
    );
  }
}