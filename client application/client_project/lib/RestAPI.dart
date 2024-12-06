import 'package:http/http.dart' as http;
import 'dart:convert';
class APIrequest{
  final String baseUrl = 'http://localhost:3000';

  final Map<String, Map<String, Type>> endpoints = {
 // Endpoint: /game/createGame
'game/createGame': {
  'player_max_count': int,        // Maximum number of players in the game
  'gametype': int,               // Type of game being created
  'map_size_x': int,             // Width of the map
  'map_size_y': int,             // Height of the map
  'session_token': String        // Session token of the creator
},

// Endpoint: /player/generatePlayer
'player/generatePlayer': {
  'password': String,            // Password for the new player
  'username': String             // Username for the new player
},

// Endpoint: /player/login
'player/login': {
  'username': String,            // Username for the player
  'password': String             // Password for the player
},

// Endpoint: /player/addPlayerToActiveGame
'player/addPlayerToActiveGame': {
  'player_id': int,              // ID of the player to add
  'game_id': int,                // ID of the game to add the player to
  'session_token' : String       
},

// Endpoint: /map/get-current-map-info
'map/get-current-map-info': {
  'session_token': String        // Session token of the player requesting map info
}
,
'games/get-all-games': {
  'session_token': String
},
'game/start':{
  'session_token' : String
},
'unit/get-info':{
  'session_token' : String,
  'TILE_ID' : String
},
'unit/move': {
  'origin_x': int,
  'origin_y': int,
  'target_x': int,
  'target_y': int,
  'map_id': String,
  'session_token': String
},
// Endpoint: /game/executeAbility
'unit/executeAbility': {
  'x': int,                      // X coordinate on the map
  'y': int,                      // Y coordinate on the map
  'map_id': String,              // Map ID where the ability is being executed
  'session_token': String       // Session token of the player executing the ability
  },

// Endpoint: /game/endTurn
'game/endTurn': {
  'session_token': String        // Session token of the player whose turn is ending
  },
  'game/get-current-game-info': {
    'session_token' : String
  }
}
;
  Future<dynamic> postRequest(String endpoint, Map<String, dynamic> params) async {
    if(!endpoints.containsKey(endpoint)){
      throw Exception('endpoint not defined: $endpoint');
    }
    final requireParams = endpoints[endpoint];
    for (var param in requireParams!.entries) {
      if (!params.containsKey(param.key)) {
        throw Exception('Missing required parameter: ${param.key}');
      }
      if (params[param.key].runtimeType != param.value) {
        throw Exception('Invalid type for parameter: ${param.key}. Expected ${param.value}');
      }
    }

    // Build the full URL
    final url = Uri.parse('$baseUrl/$endpoint');

    try {
      // Send the POST request with headers and body
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(params),
      );
      
      // Check if the response is successful
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error in POST request: $error');
      return null;
    }
  }
}
