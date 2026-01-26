import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ff/core/extensions.dart';

part 'controller.dart';
part 'state.dart';
part 'viewmodel.dart';
part 'presentation.dart';
part 'provider.dart';
part 'feature.dart';

class FF {
  static Widget buildShimmer({
    required Widget child,
    required bool isShimmering,
    required BuildContext context,
  }) {
    return child;
  }
}
