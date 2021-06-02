import 'package:rxdart/rxdart.dart' as rx;
import 'package:streams/fetch_service.dart';
import 'package:streams/player.dart';

class Managment {
  Managment._internal();

  static final Managment managment = Managment._internal();

  factory Managment() => managment;

  rx.BehaviorSubject usualPlayerSubject =rx. BehaviorSubject<List<Player>>();
  rx.BehaviorSubject captainSubject =rx. BehaviorSubject<List<Player>>();

  void closeNumberSubject() {
    usualPlayerSubject.close();
    captainSubject.close();
  }

  

  List<Player> updatedSubjectData(
      Player newPlayer,rx. BehaviorSubject<List<Player>> subject) {
    var val = subject.value ?? [];

    val.add(newPlayer);
    print("lengt of value : ${val.length}");

    return val;
  }

  void removePlayer(Player player) {
    print("remove player:managment ${player.userId}");
    List<Player> value;
    if (player.isCaptain) {
      value = captainSubject.value;
      value.removeWhere((element) => element.userId == player.userId);
      captainSubject.add(value);
    } else {
      value = usualPlayerSubject.value;
      value.removeWhere((element) => element.userId == player.userId);
      usualPlayerSubject.add(value);
    }
  }

  Future<dynamic> addPlayer(Player player) async => player.isCaptain
      ? captainSubject.add(updatedSubjectData(player, captainSubject))
      : usualPlayerSubject.add(
          updatedSubjectData(player, usualPlayerSubject),
        );

  void cancelStream() {
    usualPlayerSubject.value = <Player>[];
    captainSubject.value = <Player>[];
    usualPlayerSubject.close();
    captainSubject.close();
  }

  Stream<List<Player>> combinedStream(){
    List<Player> allPlayers = [];
    return rx.CombineLatestStream.combine2(usualPlayerSubject.stream,captainSubject
    .stream, (a, b) {
     
       allPlayers =  [
      ...a,
      ...b,
    ]
    ;

    allPlayers.sort(
      (a,b)=>int.parse(a.userId) - int.parse(b.userId));
    ;
    return allPlayers;
    }
    );
      
  }
}
