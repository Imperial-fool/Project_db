import 'dart:convert';
import 'MapManager.dart';
import 'RestAPI.dart';
void main() {
  APIrequest req = new APIrequest();
  GameMap? mapManager;
  Future<void> fetchMapInfo() async {
  try {
    // Await the postRequest and ensure the response is a Map
    dynamic jsonResponse = await req.postRequest(
      'map/get-current-map-info',
      {'session_token': '2F69FB17-AC43-49D8-8334-DAC08B76D754'},
    );
    // Ensure the response is not null
    if (jsonResponse == null) {
      throw Exception('Failed to retrieve data: Response is null');
    }

    // Create MapManager from JSON
    mapManager = GameMap.fromJson(jsonResponse);
    
    print('MapManager initialized successfully: $mapManager');
  } catch (e) {
    print('Error fetching map info: $e');
  }
  }
  fetchMapInfo();
 
}
