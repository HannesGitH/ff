import 'controller.dart';
import 'model.dart';
import 'state.dart';



typedef {{name.pascalCase()}}Widget_ = {{name.pascalCase()}}StateWidget<{{name.pascalCase()}}Controller, {{name.pascalCase()}}Model>;
typedef {{name.pascalCase()}}View_ = {{name.pascalCase()}}StateView<{{name.pascalCase()}}Controller, {{name.pascalCase()}}Model>;
typedef {{name.pascalCase()}}Builder_ = {{name.pascalCase()}}StateBuilder<{{name.pascalCase()}}Controller, {{name.pascalCase()}}Model>;

// SECTION feature-types 
// feel free to remove this section if you don't need it

typedef {{name.pascalCase()}}ReusableFeature_ = {{name.pascalCase()}}StateReusableFeature<{{name.pascalCase()}}Controller, {{name.pascalCase()}}Model>;
typedef {{name.pascalCase()}}ReusableMultiFeature_<Param> = {{name.pascalCase()}}StateReusableMultiFeature<Param, {{name.pascalCase()}}Controller, {{name.pascalCase()}}Model>;
typedef {{name.pascalCase()}}SimpleFeature_ = {{name.pascalCase()}}StateSimpleFeature<{{name.pascalCase()}}Controller, {{name.pascalCase()}}Model>;

// END SECTION feature-types