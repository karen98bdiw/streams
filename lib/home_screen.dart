import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streams/fetch_service.dart';
import 'package:streams/managment.dart';
import 'package:streams/player.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();

  MergeStream playersStream;

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  void initState() {
    playersStream = MergeStream([
      Managment().captainSubject.stream,
      Managment().usualPlayerSubject.stream,
    ]);

    Timer.periodic(Duration(seconds: 4), (timer) {
      Managment().addPlayer(
        Player(
          userName: timer.tick.toString(),
          isCaptain: timer.tick.isEven,
          userId: timer.tick.toString(),
        ),
      );
    });

    // playersStream.listen((event) {
    //   print("${event}");
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RaisedButton(
                onPressed: () {
                  print("onButtonPress");
                },
                child: Text("Fetch"),
              ),
              SizedBox(
                height: 20,
              ),
              // playerItemView(
              //   Player(isCaptain: true, userId: "1", userName: "somebody"),
              // ),
              StreamBuilder(
                stream: playersStream.asBroadcastStream(),
                builder: (c, s) {
                  print(s.data);
                  if (!s.hasData) return CircularProgressIndicator();

                  return playersListView(
                    [
                      ...Managment().captainSubject.value ?? [],
                      ...Managment().usualPlayerSubject.value ?? [],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget playersListView(List<Player> data) => Container(
        height: 300,
        child: ListView.separated(
            itemBuilder: (c, i) =>
                Text("isCaptain:${data[i].isCaptain}:id:${data[i].userId}"),
            separatorBuilder: (c, i) => SizedBox(
                  height: 20,
                ),
            itemCount: data.length),
      );

  Widget playerItemView(Player player) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(player.image ??
                "https://avatars.githubusercontent.com/u/40992581?v=4"),
            backgroundColor: Colors.green,
          ),
        ),
      );
}
