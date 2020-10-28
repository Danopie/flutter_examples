import 'dart:collection';

import 'package:flutter/material.dart';

class TestImmutability extends StatefulWidget {
  @override
  _TestImmutabilityState createState() => _TestImmutabilityState();
}

class _TestImmutabilityState extends State<TestImmutability> {
  final Car car = Car(4);

  @override
  void initState() {
    car.run();
    car.flow();
    print('_TestImmutabilityState.initState: ${car.id}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
      ),
    );
  }
}

class Car {
  int id;

  Car(this.id);

  void run() async {
    print('Car.run: run');

    await Future.delayed(Duration.zero);

    var sum = 0;
    for (int i = 0; i < 2000000; i++) {
      sum = i;
    }

    id = 0;
    print('Car.run: end');
  }

  void flow() async {
    print('Car.flow: begin');

    await Future.delayed(Duration.zero);

    var sum = 0;
    for (int i = 0; i < 1000000; i++) {
      sum = i;
    }


    id = 1;
    print('Car.flow: end');
  }

  @override
  String toString() {
    return 'Car{id: $id}';
  }
}
