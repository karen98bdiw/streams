import 'package:rxdart/rxdart.dart';
import 'package:streams/fetch_service.dart';
import 'package:streams/player.dart';

class Managment {
  Managment._internal();

  static final Managment managment = Managment._internal();

  factory Managment() => managment;

  BehaviorSubject usualPlayerSubject = BehaviorSubject<List<Player>>();
  BehaviorSubject captainSubject = BehaviorSubject<List<Player>>();

  void closeNumberSubject() {
    usualPlayerSubject.close();
    captainSubject.close();
  }

  List<Player> updatedSubjectData(
      Player newPlayer, BehaviorSubject<List<Player>> subject) {
    var val = subject.value ?? [];

    val.add(newPlayer);
    print("lengt of value : ${val.length}");

    return val;
  }

  Future<dynamic> addPlayer(Player player) async => player.isCaptain
      ? captainSubject.add(updatedSubjectData(player, captainSubject))
      : usualPlayerSubject.add(
          updatedSubjectData(player, usualPlayerSubject),
        );
}
