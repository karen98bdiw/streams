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
  List<Player> players = [];
  Timer timer;

  @override
  void dispose() {
    controller.dispose();
    timer.cancel();

    super.dispose();
  }

  @override
  void initState() {
    playersStream = MergeStream([
      Managment().captainSubject.stream,
      Managment().usualPlayerSubject.stream,
    ]);

    timer = Timer.periodic(Duration(seconds: 4), (timer) {
      print("timer${timer.tick}");
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
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder(
              stream: playersStream.asBroadcastStream(),
              builder: (c, s) {
                print(s.data);
                if (!s.hasData) return CircularProgressIndicator();

                players.add((s.data as List).last);
                return playersListView(
                  players,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget playersListView(List<Player> data) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        child: ListView.separated(
            itemBuilder: (c, i) => playerItemView(data[i]),
            separatorBuilder: (c, i) => SizedBox(
                  height: 20,
                ),
            itemCount: data.length),
      );

  Widget playerItemView(Player player) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 40,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(34),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(player.image ??
                      "https://avatars.githubusercontent.com/u/40992581?v=4"),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: player.userName,
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        WidgetSpan(
                          child: SizedBox(
                            width: 10,
                          ),
                        ),
                        TextSpan(
                          text: player.isCaptain
                              ? """will automatically become the captain if you don’t accept the request within 59 seconds."""
                              : "\nwant to join your team",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.not_interested_outlined,
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    onPressed: () {
                      Managment().removePlayer(player);
                      players.removeWhere(
                          (element) => element.userId == player.userId);
                    },
                    child: Text(
                      "Reject",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: RaisedButton(
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Accept",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
