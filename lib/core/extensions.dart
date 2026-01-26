extension FFNullHelpers<T extends Object> on T? {
  bool get isNull => this == null;
  R? ifNotNull<R>(R? Function(T) then) => isNull ? null : then(this as T);
}
