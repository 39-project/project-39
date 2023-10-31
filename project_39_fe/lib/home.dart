import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:project_39_fe/adopt.dart';
import 'package:project_39_fe/rpc.dart';
import 'package:project_39_fe/src/generated/project_39/v1/project_39.pb.dart';
import 'package:project_39_fe/upload.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userId});
  final Int64 userId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";

  @override
  void initState() {
    super.initState();

    asyncInitState();
  }

  void asyncInitState() async {
    final client = newRpcClient();
    final ret =
        await client.getUserInfo(GetUserInfoRequest(userId: widget.userId));
    setState(() {
      userName = ret.userName;
    });
  }

  int _bottomNavigationBarSelectedIndex = 0;

  Widget buildHomePageBody(int bottomNavigationBarSelectedIndex) {
    final Widget child;

    switch (bottomNavigationBarSelectedIndex) {
      case 0:
        child = AdoptPage(
          userName: userName,
          userId: widget.userId,
        );
      case 1:
        child = const UploadPage();
      default:
        throw UnimplementedError();
    }

    return SafeArea(child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildHomePageBody(_bottomNavigationBarSelectedIndex),
      bottomNavigationBar: buildBottomNavigationBar(),
      floatingActionButton: buildFab(),
    );
  }

  Widget buildBottomNavigationBar() {
    return NavigationBar(
      onDestinationSelected: (selectedIndex) {
        setState(() {
          _bottomNavigationBarSelectedIndex = selectedIndex;
        });
      },
      selectedIndex: _bottomNavigationBarSelectedIndex,
      destinations: const [
        NavigationDestination(
            label: '领养',
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.cruelty_free)),
        NavigationDestination(
            label: '发布',
            icon: Icon(Icons.feed_outlined),
            selectedIcon: Icon(Icons.feed)),
        NavigationDestination(
            label: '我的',
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person)),
      ],
    );
  }

  Widget buildFab() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _bottomNavigationBarSelectedIndex = 1;
        });
      },
      child: const Icon(Icons.edit_outlined),
    );
  }
}
