import 'RestAPI.dart';

class UnitInfo {
  final String entityId;
  final String tileId;
  final int currentHp;
  final bool hasMoved;
  final bool hasUsedAbility;
  final int ownerId;
  final int unitTypeId;
  final String name;
  final int maxHp;
  final int attackDamage;
  final int defense;
  final int movementSpeed;
  final String abilityProcedure;

  UnitInfo({
    this.entityId = '',
    this.tileId = '',
    this.currentHp = 0,
    this.hasMoved = false,
    this.hasUsedAbility = false,
    this.ownerId = 0,
    this.unitTypeId = 0,
    this.name = '',
    this.maxHp = 0,
    this.attackDamage = 0,
    this.defense = 0,
    this.movementSpeed = 0,
    this.abilityProcedure = '',
  });

  factory UnitInfo.fromJson(Map<String, dynamic> json) {
    return UnitInfo(
      entityId: json['ENTITY_ID'],
      tileId: json['TILE_ID'],
      currentHp: json['CURRENT_HP'],
      hasMoved: json['HAS_MOVED'],
      hasUsedAbility: json['HAS_USED_ABILITY'],
      ownerId: json['OWNER_ID'],
      unitTypeId: (json['UNIT_TYPE_ID'] is List && json['UNIT_TYPE_ID'].isNotEmpty)
          ? json['UNIT_TYPE_ID'][0] 
          : 0,  
      name: json['NAME'],
      maxHp: json['MAX_HP'],
      attackDamage: json['ATTACK_DAMAGE'],
      defense: json['DEFENSE'],
      movementSpeed: json['MOVEMENT_SPEED'],
      abilityProcedure: json['ABILITY_PROCEDURE'],
    );
  }

static Future<List<UnitInfo>> getUnitInfo(String tileId, String sessionToken) async {
  var req = APIrequest();
  try {
    dynamic jsonResponse = await req.postRequest('unit/get-info', {
      'TILE_ID': tileId,
      'session_token': sessionToken,
    });
    print(jsonResponse);

    if (jsonResponse is List && jsonResponse.isNotEmpty) {
      var data = jsonResponse[0];
      return [UnitInfo.fromJson(data)];  
    } else if (jsonResponse['error'] != null) {
      throw Exception(jsonResponse['error']);
    } else {
      throw Exception('Unexpected API response');
    }
  } catch (e) {
    print('Error fetching unit info: $e');
    throw e;
  }
}
  Future<bool> moveUnit(int origin_x, int origin_y, int target_x, int target_y, String map_id, String session_token) async{
    var req = APIrequest();
    try{
      dynamic jsonResponse = await req.postRequest('unit/move', {'origin_x' : origin_x, 'origin_y':origin_y, 'target_x':target_x, 'target_y': target_y, 'map_id':map_id, 'session_token' : session_token});
      if(jsonResponse == null){
        throw Exception('move unit has failed');
      }else{
        return true;
      }
    }catch (e){
      print('error in moveUnit: $e');
      rethrow;
    }
  }
}
