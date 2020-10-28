import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JourneyDemo extends StatefulWidget {
  @override
  _JourneyDemoState createState() => _JourneyDemoState();
}

class _JourneyDemoState extends State<JourneyDemo> {
  String username;
  String password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (username != null && password != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(username),
                  Text(password),
                  RaisedButton(
                    child: Text("Clear"),
                    onPressed: () {
                      setState(() {
                        username = password = null;
                      });
                    },
                  )
                ],
              ),
            );
          } else {
            return Center(
              child: RaisedButton(
                child: Text("Sign In"),
                onPressed: () async {
                  final userInfo = await Navigator.of(context).push<UserInfo>(
                      buildSwipeRoute<UserInfo>(SignInJourney()));
                  if (userInfo != null) {
                    setState(() {
                      username = userInfo.username;
                      password = userInfo.password;
                    });
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}

buildRoute<T>(Widget widget) => MaterialPageRoute<T>(
      builder: (context) => widget,
    );

buildSwipeRoute<T>(Widget widget) => CupertinoPageRoute<T>(
      builder: (context) => widget,
    );

class SignInJourneyManager extends ChangeNotifier {
  String username;
  String password;
  bool done = false;

  void onUserInputUsername(String text) {
    username = text;
    notifyListeners();
  }

  void onUserInputPassword(String text) {
    password = text;
    done = true;
    notifyListeners();
  }
}

class UserInfo {
  String username;
  String password;

  UserInfo(this.username, this.password);
}

class SignInJourney extends StatefulWidget {
  @override
  _SignInJourneyState createState() => _SignInJourneyState();
}

class _SignInJourneyState extends State<SignInJourney> {
  final manager = SignInJourneyManager();

  @override
  void initState() {
    manager.addListener(() {
      if (manager.done == true) {
        Navigator.of(context).pop(UserInfo(manager.username, manager.password));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInJourneyManager>.value(
      value: manager,
      child: Navigator(
        onGenerateRoute: (settings) {
          if (settings.name == "/home")
            return buildSwipeRoute(EnterUserNamePage());
          else
            return null;
        },
        initialRoute: "/home",
      ),
    );
  }
}

class EnterUserNamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: TextField(
          decoration: InputDecoration(hintText: "Username"),
          onSubmitted: (text) {
            Navigator.of(context)
                .push(buildSwipeRoute(EnterUserPasswordPage()));

            Provider.of<SignInJourneyManager>(context, listen: false)
                .onUserInputUsername(text);
          },
        ),
      ),
    );
  }
}

class EnterUserPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: TextField(
          decoration: InputDecoration(hintText: "Password"),
          onSubmitted: (text) {
            Provider.of<SignInJourneyManager>(context, listen: false)
                .onUserInputPassword(text);
          },
        ),
      ),
    );
  }
}
