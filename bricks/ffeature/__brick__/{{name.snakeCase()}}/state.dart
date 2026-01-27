import 'package:ff/fw.dart';

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

// SECTION type-aliases

typedef {{name.pascalCase()}}Widget_ = {{name.pascalCase()}}StateWidget<{{name.pascalCase()}}Controller, {{name.pascalCase()}}Model>;
typedef {{name.pascalCase()}}View_ = {{name.pascalCase()}}StateView<{{name.pascalCase()}}Controller, {{name.pascalCase()}}Model>;
typedef {{name.pascalCase()}}Builder_ = {{name.pascalCase()}}StateBuilder<{{name.pascalCase()}}Controller, {{name.pascalCase()}}Model>;

// SECTION feature-types 
// feel free to remove this section if you don't need it

typedef {{name.pascalCase()}}ReusableFeature_ = {{name.pascalCase()}}StateReusableFeature<{{name.pascalCase()}}Controller, {{name.pascalCase()}}Model>;
typedef {{name.pascalCase()}}ReusableMultiFeature_<Param> = {{name.pascalCase()}}StateReusableMultiFeature<Param, {{name.pascalCase()}}Controller, {{name.pascalCase()}}Model>;
typedef {{name.pascalCase()}}SimpleFeature_ = {{name.pascalCase()}}StateSimpleFeature<{{name.pascalCase()}}Controller, {{name.pascalCase()}}Model>;

// END SECTION feature-types
// END SECTION type-aliases