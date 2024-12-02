
import 'RestAPI.dart';

class User {
  String session_token = '';
  String username = '';
  int player_id = 0000;


  Future<String> login(String username, String password) async {
    try {
      APIrequest req = APIrequest();
    
      dynamic jsonResponse = await req.postRequest('player/login', {'username' : username, 'password' : password});
      
      session_token = jsonResponse['sessionToken'];
      player_id = jsonResponse['player_id'];
      this.username = username;
      return 'User logged in successfully: $session_token, $player_id';
    } catch (e) {
      print('Error login in: $e');
    }
    return 'failed';
  }
  Future<String> createUser(String username, String password) async {
     try {
      APIrequest req = APIrequest();
    
      dynamic jsonResponse = await req.postRequest('player/generatePlayer', {'username' : username, 'password' : password});

      if(jsonResponse['output'] == 0){
         return 'User created in successfully';
      }
    } catch (e) {
      return 'Error creating user: $e';
    }
    return 'failed';
  }
  Future<String> addPlayerToActiveGame(String session_token, int player_id, int game_id) async {
    try {
      APIrequest req = APIrequest();

      dynamic jsonResponse = await req.postRequest('player/addPlayerToActiveGame', {'session_token': session_token, 'game_id': game_id, 'player_id': player_id});

      if(jsonResponse['message'] == 'Player added to the active game if there was space.'){
        return 'ok';
      }else{
        return 'not ok';
      }
    } catch(e){
      return 'error: $e';
      rethrow;
    }
  }
}
  
