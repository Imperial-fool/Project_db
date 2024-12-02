import 'package:client_project/Game.dart';
import 'package:client_project/RestAPI.dart';

class GameMap {
  List<Tile> tiles;

  GameMap({required this.tiles});

  // Factory method to create a MapManager from JSON
  factory GameMap.fromJson(List<dynamic> json) {
    return GameMap(
      tiles: json.map((tileJson) => Tile.fromJson(tileJson)).toList(),
    );
  }

  // Example method to get a tile by coordinates
  Tile? getTileAt(int x, int y) {
    return tiles.firstWhere(
      (tile) => tile.x == x && tile.y == y,
    );
  }
  Tile getTileById(String id){
    Tile? first = tiles.firstWhere((tile) => tile.tileId == id);
    if(first == null) throw 'tile not found';
    return first;
  }
}
class MapManager {
  late GameMap map;

  MapManager();

  Future<GameMap> initialize(String sessionToken) async {
    try {
      map = await fetchMapInfo(sessionToken);
      return map;
    } catch (e) {
      print('Error initializing map: $e');
      rethrow;
    }
  }
  /*'game/createGame': {
  'player_max_count': int,        // Maximum number of players in the game
  'gametype': int,               // Type of game being created
  'map_size_x': int,             // Width of the map
  'map_size_y': int,             // Height of the map
  'session_token': String        // Session token of the creator
},*/


  Future<GameMap> fetchMapInfo(String sessionToken) async {
    try {
      APIrequest req = APIrequest();
      dynamic jsonResponse = await req.postRequest(
        'map/get-current-map-info',
        {'session_token': sessionToken},
      );

      if (jsonResponse == null) {
        throw Exception('Failed to retrieve data: Response is null');
      }

      return GameMap.fromJson(jsonResponse);

    } catch (e) {
      print('Error fetching map info: $e');
      rethrow; 
    }
  }
  /*'game/executeAbility': {
  'x': int,                      // X coordinate on the map
  'y': int,                      // Y coordinate on the map
  'map_id': String,              // Map ID where the ability is being executed
  'session_token': String       // Session token of the player executing the ability
  }*/
  Future<bool> executeAbility(String tileId,String map_id, String session_token) async {
    Tile ref = map.getTileById(tileId);
    int x = ref.x;
    int y = ref.y;
    
    try{
        APIrequest req = APIrequest();
        dynamic jsonResponse = await req.postRequest('unit/executeAbility', {'x' : x, 'y' : y, 'map_id' : map_id, 'session_token' : session_token});

        if (jsonResponse == null){
            throw Exception('failed to activate ability');
        }
        this.map = await fetchMapInfo(session_token);

        return true;
    }catch(e){
        print('error in executeAbility function');
        rethrow;
    }
  }
}

class Tile {
  final String tileId;
  final int playerControlId;
  final String? occupied;
  final int tileType;
  final bool isCity;
  final int cityId;
  final int x;
  final int y;

  Tile({
    required this.tileId,
    required this.playerControlId,
    this.occupied,
    required this.tileType,
    required this.isCity,
    required this.cityId,
    required this.x,
    required this.y,
  });

  factory Tile.fromJson(Map<String, dynamic> json) {
    return Tile(
      tileId: json['TILE_ID'],
      playerControlId: json['PLAYER_CONTROL_ID'],
      occupied: json['OCCUPIED'],
      tileType: json['TILE_TYPE'],
      isCity: json['is_CITY'],
      cityId: json['CITY_ID'],
      x: json['x'],
      y: json['y'],
    );
  }
}
