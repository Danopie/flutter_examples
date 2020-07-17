import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lightweight_bloc/lightweight_bloc.dart';

T useBlocBuilder<B extends Bloc<T>, T>() {
  final bloc = useContext().bloc<B>();
  return useStream(bloc, initialData: bloc.state)?.data;
}

void useBlocListener<B extends Bloc<T>, T>(
    void Function(BuildContext, T) listener) {
  final context = useContext();
  final bloc = context.bloc<B>();

  useEffect(() {
    final _sub = bloc.listen(
          (state) {
        if (listener != null) {
          listener(context, state);
        }
      },
    );
    return () {
      return _sub.cancel();
    };
  }, [bloc]);
}
