import 'package:flutter/material.dart';

class SliverExample extends StatefulWidget {
  @override
  _SliverExampleState createState() => _SliverExampleState();
}

class _SliverExampleState extends State<SliverExample> with TickerProviderStateMixin<SliverExample>{
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text("My App Bar"),
            leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {}),
            pinned: true,
            expandedHeight: 200,
            backgroundColor: Colors.red,
            bottom: ,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                "https://cdn.dribbble.com/users/605515/screenshots/5912128/vietnam.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(children: buildTabBarViews(), controller: _tabController,),
          )
        ],
      ),
    );
  }

  buildTabBarViews() {

  }
}
