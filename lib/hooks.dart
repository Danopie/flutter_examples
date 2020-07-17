// ignore_for_file: omit_local_variable_types
import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:provider/provider.dart' hide Locator;

class CounterState {
  final int count;
  final String name;
  final int totalLog;

  const CounterState({
    @required this.count,
    @required this.name,
    @required this.totalLog,
  });

  CounterState copyWith({
    int count,
    String name,
    int totalLog,
  }) {
    return new CounterState(
      count: count ?? this.count,
      name: name ?? this.name,
      totalLog: totalLog ?? this.totalLog,
    );
  }
}

class CounterController extends StateNotifier<CounterState> with LocatorMixin {
  CounterController({String name})
      : super(CounterState(count: 0, name: name, totalLog: 0));

  void onIncrement() {
    state = state.copyWith(count: state.count + 1);
    read<CounterLogController>().onCounterChange(state.name, true);
  }

  void onDecrement() {
    state = state.copyWith(count: state.count - 1);
    read<CounterLogController>().onCounterChange(state.name, false);
  }

  @override
  void update(Locator watch) {
    final _logs = watch<CounterLogController>().state.log;
    state = state.copyWith(
        totalLog:
            _logs.where((element) => element.contains(state.name)).length);
  }
}

class CounterLogState {
  final List<String> log;

  const CounterLogState({
    @required this.log,
  });

  CounterLogState copyWith({
    List<String> log,
  }) {
    return new CounterLogState(
      log: log ?? this.log,
    );
  }
}

class CounterLogController extends StateNotifier<CounterLogState> {
  CounterLogController() : super(CounterLogState(log: <String>[]));

  void onCounterChange(String name, bool increase) {
    state = state.copyWith(
        log: state.log
          ..add("Counter $name ${increase ? "increase" : "decrease"}"));
  }
}

class StateNotifierWithHookExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<CounterLogController, CounterLogState>(
      create: (_) => CounterLogController(),
      child: HookBuilder(
        builder: (context) {
          final counterState = context.watch<CounterLogState>();

          useStateEffect<CounterLogController, CounterLogState>(
              (context, state) {});

          return Scaffold(
            appBar: AppBar(
              title: const Text('Custom Hook: Bloc'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CounterSection(
                        name: "Alpha",
                      ),
                      CounterSection(
                        name: "Beta",
                      ),
                      CounterSection(
                        name: "Charlie",
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return ListTile(
                          title:
                              Text(counterState.log.reversed.toList()[index]),
                          contentPadding: EdgeInsets.all(4),
                        );
                      },
                      itemCount: counterState.log.length,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CounterSection extends StatelessWidget {
  final String name;

  const CounterSection({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<CounterController, CounterState>(
      create: (_) => CounterController(name: name),
      child: HookBuilder(
        builder: (context) {
          final counterState = context.watch<CounterState>();

          useStateEffect<CounterController, CounterState>((context, state) {
            if (state.count == 10) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => StateNotifierWithHookExample()));
            }
          });

          return Column(
            children: [
              Text("$name count: ${counterState.count}"),
              Text("Total log: ${counterState.totalLog}"),
              RaisedButton(
                child: Text("Increase"),
                onPressed: () {
                  context.read<CounterController>().onIncrement();
                },
              ),
              RaisedButton(
                child: Text("Decrease"),
                onPressed: () {
                  context.read<CounterController>().onDecrement();
                },
              )
            ],
          );
        },
      ),
    );
  }
}

void useStateEffect<S extends StateNotifier<V>, V>(
    void Function(BuildContext, V) listener) {
  final context = useContext();
  final notifier = context.watch<S>();

  useEffect(() {
    final _dispose = notifier.addListener((state) {
      if (listener != null) {
        listener(context, state);
      }
    });
    return _dispose;
  }, [notifier]);
}
