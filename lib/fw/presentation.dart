part of 'ff.dart';

enum FFPresentationType { route, dialog, bottomSheet }

class FFPresentationProvider extends InheritedWidget {
  const FFPresentationProvider({
    super.key,
    required super.child,
    required this.type,
  });

  final FFPresentationType type;

  @override
  bool updateShouldNotify(covariant FFPresentationProvider oldWidget) {
    return oldWidget.type != type;
  }

  static FFPresentationProvider? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FFPresentationProvider>();
  }

  static FFPresentationProvider of(BuildContext context) {
    final result = maybeOf(context);
    if (result == null) {
      throw Exception('No FFPresentationProvider found in context');
    }
    return result;
  }
}

class FFPresenter<
  Watched,
  FFState extends WatchableProps<Watched>,
  ViewModel extends FFViewModel<Watched, FFState>,
  Controller extends FFController<Watched, FFState>
> {
  FFPresenter({
    required this.controller,
    required this.viewModel,
    required this.shallDisposeController,
  });

  final Controller controller;
  final ViewModel Function(FFState state) viewModel;
  final bool shallDisposeController;

  Widget buildWidget(
    FFWidget<Watched, FFState, ViewModel, Controller> child,
  ) => buildWidgetUnsafe(child);

  Future<void> show({
    required BuildContext context,
    required FFView<Watched, FFState, ViewModel, Controller> view,
    required FFPresentationType asType,
  }) => showUnsafe(context: context, view: view, asType: asType);

  Widget buildWidgetUnsafe(Widget child) {
    return _FFBuilder<Watched, FFState, ViewModel, Controller>(
      controller: controller,
      viewModel: viewModel,
      shallDisposeController: shallDisposeController,
      child: child,
    );
  }

  Future<void> showUnsafe({
    required BuildContext context,
    required Widget view,
    required FFPresentationType asType,
  }) {
    final child = FFPresentationProvider(
      type: asType,
      child: buildWidgetUnsafe(view),
    );
    switch (asType) {
      case FFPresentationType.route:
        return Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => child),
        );
      //TODO:
      default:
        throw UnimplementedError(
          'Presentation type $asType not implemented yet',
        );
    }
  }
}

abstract class FFWidget<
  Watched,
  FFState extends WatchableProps<Watched>,
  ViewModel extends FFViewModel<Watched, FFState>,
  Controller extends FFController<Watched, FFState>
>
    extends StatelessWidget {
  const FFWidget({super.key});

  Widget buildWidget(
    BuildContext context,
    Controller controller,
    ViewModel viewModel,
  );

  @override
  Widget build(BuildContext context) {
    return FFShimmerMan(
      child: Builder(
        builder: (context) {
          final vmAndController =
              FFVmAndControllerProvider.of<
                Watched,
                FFState,
                ViewModel,
                Controller
              >(context);
          return buildWidget(
            context,
            vmAndController.controller,
            vmAndController.viewModel,
          );
        },
      ),
    );
  }

  Widget? Function(int index) itemBuilderFor<T>(
    FFDynamicModel<T> props,
    Widget Function(BuildContext context, ViewModel viewModel, T value) builder,
  ) {
    return (index) => index >= props.allowedKeys.length
        ? null
        : FFBuilder<Watched, FFState, ViewModel, Controller>(
            builder: (context, controller, viewModel) {
              debugPrint('building item $index');
              return builder(
                context,
                viewModel,
                props.build(props.allowedKeys[index], context),
              );
            },
          );
  }

  List<Widget> iterateOver<T>(
    FFDynamicModel<T> props,
    Widget Function(BuildContext context, ViewModel viewModel, T? value)
    builder,
  ) => [
    for (var index = 0; index < props.allowedKeys.length; index++)
      itemBuilderFor(props, builder)(index)!,
  ];
}

abstract class FFView<
  Watched,
  FFState extends WatchableProps<Watched>,
  ViewModel extends FFViewModel<Watched, FFState>,
  Controller extends FFController<Watched, FFState>
>
    extends FFWidget<Watched, FFState, ViewModel, Controller> {
  const FFView({super.key});

  /// consider overriding [buildBody] if you need custom slivers
  Iterable<Widget> buildBodyChildren(
    BuildContext context,
    Controller controller,
    ViewModel viewModel,
  );

  /// if null, we dont show any footer
  Widget Function(
    BuildContext context,
    Controller controller,
    ViewModel viewModel,
  )?
  get buildFooter;

  Widget buildTitle(
    BuildContext context,
    Controller controller,
    ViewModel viewModel,
  ) => Text(
    viewModel.title(context),
  );

  /// be careful with putting to much in here, as rebuilding this, will rebuild the entire view
  /// consider using [buildTitle] instead
  PreferredSizeWidget? buildHeader(
    BuildContext context,
    Controller controller,
    ViewModel viewModel,
  ) => AppBar(
    title: FFBuilder<Watched, FFState, ViewModel, Controller>(
      builder: buildTitle,
    ),
  );

  Widget buildBody(
    BuildContext context,
    Controller controller,
    ViewModel viewModel,
  ) {
    debugPrint('building body');
    final children = buildBodyChildren(context, controller, viewModel);
    Widget wrapper(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: child,
    );
    return switch (children) {
      List<Widget> children => ListView(
        physics: const ScrollPhysics(),
        children: children.map(wrapper).toList(),
      ),
      Iterable<Widget> children => ListView.builder(
        physics: const ScrollPhysics(),
        itemBuilder: (context, index) => wrapper(children.elementAt(index)),
      ),
    };
    // the following would not help, as the context inside the builder is always the same, so we would rebuild everything anyway
    // // FFBuilder<Watched, Props, FFState, ViewModel, Controller>(
    // //   builder: (context, controller, viewModel) =>
    // //       buildBodyChild(context, controller, viewModel, index),
    // // ),
  }

  Widget buildRoute(
    BuildContext context,
    Controller controller,
    ViewModel viewModel,
  ) {
    debugPrint('building route');
    return Scaffold(
      appBar: buildHeader(context, controller, viewModel),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FFBuilder<Watched, FFState, ViewModel, Controller>(
                builder: buildBody,
              ),
            ),
            ?buildFooter.ifNotNull(
              (f) => FFBuilder<Watched, FFState, ViewModel, Controller>(
                builder: f,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildWidget(
    BuildContext context,
    Controller controller,
    ViewModel viewModel,
  ) {
    // TODO: make more inline with our stuff and add presentationType inherited widget to build dialog bottomsheet or scaffold
    final type = FFPresentationProvider.of(context).type;
    switch (type) {
      case FFPresentationType.route:
        return buildRoute(context, controller, viewModel);
      default:
        throw UnimplementedError('Presentation type $type not implemented yet');
    }
  }
}

class FFBuilder<
  Watched,
  FFState extends WatchableProps<Watched>,
  ViewModel extends FFViewModel<Watched, FFState>,
  Controller extends FFController<Watched, FFState>
>
    extends FFWidget<Watched, FFState, ViewModel, Controller> {
  const FFBuilder({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    Controller controller,
    ViewModel viewModel,
  )
  builder;

  @override
  Widget buildWidget(
    BuildContext context,
    Controller controller,
    ViewModel viewModel,
  ) {
    return builder(context, controller, viewModel);
  }
}
