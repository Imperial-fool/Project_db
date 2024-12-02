import 'dart:convert';

import 'RestAPI.dart';

class Game {
  final int gameId;
  final String mapId;
  int playerCount;
  final int gameType;
  final int maxPlayerCount;
  int? turn;
  int? currentPlayerTurn;

  Game({
    required this.gameId,
    required this.mapId,
    required this.playerCount,
    required this.gameType,
    required this.maxPlayerCount,
    required this.turn,
    required this.currentPlayerTurn,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      gameId: json['GAME_ID'],
      mapId: json['MAP_ID'],
      playerCount: json['PLAYERCOUNT'],
      gameType: json['GAMETYPE'],
      maxPlayerCount: json['MAX_PLAYER_COUNT'],
      turn: json['TURN'],
      currentPlayerTurn: json['CURRENT_PLAYER_TURN'],
    );
}
Future<Game> startGame(String session_token) async {
    var req = APIrequest();
    dynamic jsonResponse = await req.postRequest('game/start', {'session_token' : session_token});
    if(jsonResponse['message'] == "Game started successfully."){
      return await getCurrentGameInfo(session_token);
    }else{
      throw Exception('this is messed up!');
    }
}
/*'game/endTurn': {
  'player_id': int,              // ID of the player ending their turn
  'game_id': int,                // ID of the game in which the turn is being ended
  'session_token': String        // Session token of the player whose turn is ending
  }*/

  Future<bool> endTurn(String session_token) async{
    try{
      APIrequest req = APIrequest();
      dynamic jsonResponse = await req.postRequest('game/endTurn', {'session_token' : session_token});

      if(jsonResponse == null){
        throw Exception('failed to end turn');
      }
      return true;
    }catch (e){
      print('error in endturn: $e');
      rethrow;
    }
  }
  Future<Game> getCurrentGameInfo(String session_token) async {
  try {
    APIrequest req = APIrequest();
    dynamic jsonResponse = await req.postRequest(
      'game/get-current-game-info',
      {'session_token': session_token},
    );

    if (jsonResponse == null) {
      throw Exception('Failed to retrieve data: Response is null');
    }

    return Game.fromJson(jsonResponse);

  } catch (e) {
    print('Error getting current game info: $e');
    rethrow;
  }
}
  
}

class AllGames{
  List<Game> games = [];
  Future<List<Game>> getAllgames(String session_token) async {
    var req = APIrequest();

    dynamic jsonResponse = await req.postRequest('games/get-all-games', {'session_token' : session_token});

    for (var element in jsonResponse) {
      games.add(Game.fromJson(element));
    }
    return games;
  }
  Future<Game> getGame(String session_token, int game_id) async{
    List<Game> games = await AllGames().getAllgames(session_token);
    Game? game = games.firstWhere((item) => item.gameId == game_id);
    return game;
  } 
  Future<int> createGame(int playercount, int x, int y, String session_token) async{
  try{
    APIrequest req = APIrequest();
    dynamic jsonResponse = await req.postRequest('game/createGame', {'player_max_count' : playercount, 'gametype': 1, 'map_size_x': x, 'map_size_y': y, 'session_token' : session_token});

    if(jsonResponse == null){
      throw Exception('failed to create game');
    }
    return jsonResponse['gameId'];
  }catch (e){
    print('error in createGame: $e');
    rethrow;
    }
  }
  
}
