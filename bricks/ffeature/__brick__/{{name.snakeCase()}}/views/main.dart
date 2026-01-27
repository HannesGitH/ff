import 'package:ff/fw.dart';

import '../widgets/example.dart';

class {{name.pascalCase()}}View extends {{name.pascalCase()}}View_ {
  const {{name.pascalCase()}}View({super.key});

  @override
  List<Widget> buildBodyChildren(context, controller, viewModel) => [
    const {{name.pascalCase()}}ExampleWidget(),
  ];
}
