// try to put as many widgets as possible instead of using giant ones

import 'package:flutter/material.dart';
import 'package:ff/fw.dart';

import '../cubit.dart';
import '../model.dart';

class {{name.pascalCase()}}ExampleWidget extends {{name.pascalCase()}}Widget_ {
  const {{name.pascalCase()}}ExampleWidget({super.key});

  @override
  Widget buildWidget(
    BuildContext context,
    {{name.pascalCase()}}Controller controller,
    {{name.pascalCase()}}Model viewModel,
  ) {
    return Container(color: viewModel.yourModelProperty(context) ? Colors.blue : Colors.red, height: 100, width: 100);
  }
}
