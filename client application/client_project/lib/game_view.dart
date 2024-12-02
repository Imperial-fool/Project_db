import 'package:client_project/Game.dart';
import 'package:client_project/MapManager.dart';
import 'package:client_project/Unit.dart';
import 'package:client_project/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
late Game Globalgame;
MapManager mapManager = MapManager(); 
List<Tile> highlightedTiles = [];
UnitInfo? currentUnitInfo;
class MapView extends StatefulWidget {
  final String sessionToken;
  
  const MapView({
    super.key,
    required this.sessionToken
  });

  @override
  // ignore: library_private_types_in_public_api
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Tile? selectedUnit;
  bool showUnitPopup_ = false;
  int currentTurn = 0;
  Timer? _refreshTimer; 
  final TransformationController _transformationController = TransformationController();
  void showUnitPopup(UnitInfo unitInfo, Tile tileinfo) {
  setState(() {

    currentUnitInfo = unitInfo; // Store the unit info for display
    selectedUnit = tileinfo;
    showUnitPopup_ = true; // Flag to control popup visibility
  });
}
  void OnClose(){
    setState(() {
      currentUnitInfo = null;
      showUnitPopup_ = false;
    });
  }

  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchAndUpdateMap();  
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAndUpdateMap(); // Initial map load
    startAutoRefresh(); // Start auto-refresh
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
  void handleEndTurn() async {
    Globalgame.endTurn(user.session_token);
    fetchAndUpdateMap(); 
    setState(() {
      currentTurn = Globalgame.turn!;
    });
  }
  

  void fetchAndUpdateMap() async {
    try {
      // Call fetchMapInfo from MapManager
      mapManager.map = await mapManager.fetchMapInfo(widget.sessionToken);
      Globalgame = await Globalgame.getCurrentGameInfo(user.session_token);
      final GlobalKey<_MapGeneratorState> _childKey = GlobalKey();
      _childKey.currentState?.updateTileState();
      
      // Refresh the UI with the new map data
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      // Handle errors if needed
      if (kDebugMode) {
        print('Error fetching map info: $error');
      }
    }
  }

  void requestMapUpdate() {
    fetchAndUpdateMap();
  }

  void onTileTap(Tile tile, int movementSpeed) async {
    if (selectedUnit != null) {
      // Move the unit to the selected tile
      if (kDebugMode) {
        print('Moving unit to tile ${tile.tileId}');
      }
      if(selectedUnit != null && currentUnitInfo != null){
      var ret = await currentUnitInfo?.moveUnit(selectedUnit!.x,selectedUnit!.y,tile.x,tile.y,Globalgame.mapId,user.session_token);
      if(ret!){
        selectedUnit = null;
        highlightedTiles = [];
      }
      requestMapUpdate();
      setState(() {});
      }
    } 
  }

  List<Tile> calculateMovementRange(Tile unitTile, int movementSpeed) {
    List<Tile> rangeTiles = [];
    for (var tile in mapManager.map.tiles) {
      int distance = (tile.x - unitTile.x).abs() + (tile.y - unitTile.y).abs();
      if (distance <= movementSpeed) {
        rangeTiles.add(tile);
      }
    }
    setState(() {
      highlightedTiles = rangeTiles;
    });
    return rangeTiles;
  }

@override
Widget build(BuildContext context) {
  mapManager.map.tiles.map((tile) => tile.x).reduce((a, b) => a > b ? a : b);
  mapManager.map.tiles.map((tile) => tile.y).reduce((a, b) => a > b ? a : b);



  return Stack(
    children: [
      InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(10),
          minScale: 0.1,
          maxScale: 4.0,
          child: MapGenerator(
                showUnitPopup: showUnitPopup,
                onTileTap: onTileTap
              ),
        ),
      if (showUnitPopup_ && currentUnitInfo != null) // Check flag and info before displaying popup
          UnitPopup(
            unitInfo: currentUnitInfo!,
            onTileTap: onTileTap,
            calculateMovementRange: calculateMovementRange,
            onClose: OnClose,
          ),
      Positioned(
        top: 16,
        right: 16,
        child: Text('Turn: ${Globalgame.turn}'), // Add turn counter here
      ),
      Positioned(
        bottom: 16,
        right: 16,
        child: ElevatedButton(
          onPressed: () { 
            handleEndTurn();
            fetchAndUpdateMap();
          },
          child: const Text('End Turn'),
        ),
      ),
    ],
  );
}
}


class MapGenerator extends StatefulWidget {
  final Function(UnitInfo, Tile) showUnitPopup;
  final Function(Tile, int) onTileTap;
  final double tileSize = 50;

  const MapGenerator({super.key, 
    required this.showUnitPopup,
    required this.onTileTap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MapGeneratorState createState() => _MapGeneratorState();
}

class _MapGeneratorState extends State<MapGenerator> {
  List<Widget> tileWidgets = [];
  void updateTileState() {
    setState(() {
    });
  }
  @override
  Widget build(BuildContext context) {
    // Access variables passed from the parent widget through the widget property
    final showUnitPopup = widget.showUnitPopup;
    final onTileTap = widget.onTileTap;
    final tileSize = widget.tileSize;

    final maxX = mapManager.map.tiles.map((tile) => tile.x).reduce((a, b) => a > b ? a : b);
    final maxY = mapManager.map.tiles.map((tile) => tile.y).reduce((a, b) => a > b ? a : b);

    final mapWidth = (maxX + 1) * tileSize;
    final mapHeight = (maxY + 1) * tileSize;

    final offsetX = (MediaQuery.of(context).size.width - mapWidth) / 2;
    final offsetY = (MediaQuery.of(context).size.height - mapHeight) / 2;

    tileWidgets = mapManager.map.tiles.map((tile) {
      return Positioned(
        left: offsetX + tile.x * tileSize,
        top: offsetY + tile.y * tileSize,
        child: TileWidget(
          tile: tile,
          showUnitPopup: showUnitPopup,  // Use the variable here
          onTileTap: onTileTap,          // Use the variable here
          size: tileSize,
        ),
      );
    }).toList();

    return Stack(
      children: tileWidgets,
    );
  }
}

class TileWidget extends StatefulWidget {
  final Tile tile;
  final Function(UnitInfo, Tile) showUnitPopup;
  final Function(Tile, int) onTileTap;
  final double size;

  const TileWidget({super.key, 
    required this.tile,
    required this.showUnitPopup,
    required this.onTileTap,
    required this.size,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TileWidgetState createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> {
  late Tile tile; 
  @override
  void initState() {
    super.initState();
    tile = widget.tile;  // Initialize with the passed tile
  }
  void updateTile(Tile updatedTile) {
    setState(() {
      tile = updatedTile;
    });
  }
  @override
  Widget build(BuildContext context) {
    
    // Set the tile color based on its type
    Color tileColor = Colors.blue;
    if (widget.tile.tileType == 1) {
      tileColor = Colors.lightGreen;
    } else if (widget.tile.tileType == 2) {
      tileColor = Colors.green;
    } else if (widget.tile.tileType == 3) {
      tileColor = Colors.yellow;
    } else if (widget.tile.tileType == 4) {
      tileColor = Colors.blue;
    } else if (widget.tile.tileType == 5) {
      tileColor = Colors.white;
    }

    return GestureDetector(
      onTap: () async {
        if (kDebugMode) {
          print("Tap detected at: x=${tile.x}, y=${tile.y}");
        }

        // If there is a currently selected unit and the tile is within the highlighted range, trigger onTileTap
        bool exist = highlightedTiles.any((item) => item.tileId == tile.tileId);
        if (currentUnitInfo != null && exist) {
          widget.onTileTap(widget.tile, currentUnitInfo!.movementSpeed);
          return;
        }
        
        // If the tile has an occupied unit, fetch and show its info
        if (widget.tile.occupied != null && currentUnitInfo == null && tile.occupied != null) {
          var unit = await UnitInfo.getUnitInfo(tile.tileId, user.session_token);
          widget.showUnitPopup(unit.first, tile);
          return;
        }
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        color: tileColor,
        child: Stack(
          children: [
            // Tile City Icon
            if (widget.tile.isCity)
              const Center(
                child: Icon(
                  Icons.location_city,
                  color: Colors.white,
                ),
              ),
            // Tile Occupied Icon
            if (widget.tile.occupied != null)
              const Center(
                child: Icon(
                  Icons.add_circle,
                  color: Colors.black,
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class UnitPopup extends StatelessWidget {
  final UnitInfo? unitInfo;
  final Function(Tile, int) onTileTap;
  final Function(Tile, int) calculateMovementRange;
  final VoidCallback onClose; // Callback for closing the popup

  const UnitPopup({
    super.key,
    this.unitInfo,
    required this.onTileTap,
    required this.calculateMovementRange,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (unitInfo == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0, // Lock the popup to the left side
      top: 50, // Adjust to position the popup lower if needed
      child: Container(
        width: 200, // Small width to keep it compact
        height: 300,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10), // Optional rounded corners
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button at the top right corner
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onClose, // Call the onClose callback when pressed
                  ),
                ),
                // Text with the same font size
                const Text(
                  'Unit Info',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontFamily: 'Courier New',
                    fontSize: 16, // Consistent font size for all text
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Name: ${unitInfo!.name}',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontFamily: 'Courier New',
                    fontSize: 16, // Consistent font size
                  ),
                ),
                Text(
                  'HP: ${unitInfo!.currentHp}/${unitInfo!.maxHp}',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontFamily: 'Courier New',
                    fontSize: 16, // Consistent font size
                  ),
                ),
                Text(
                  'Attack: ${unitInfo!.attackDamage}',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontFamily: 'Courier New',
                    fontSize: 16, // Consistent font size
                  ),
                ),
                Text(
                  'Defense: ${unitInfo!.defense}',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontFamily: 'Courier New',
                    fontSize: 16, // Consistent font size
                  ),
                ),
                Text(
                  'Movement: ${unitInfo!.movementSpeed}',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontFamily: 'Courier New',
                    fontSize: 16, // Consistent font size
                  ),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    calculateMovementRange(
                        mapManager.map.getTileById(unitInfo!.tileId),
                        unitInfo!.movementSpeed);
                    context
                        .findAncestorStateOfType<_MapViewState>()
                        ?.requestMapUpdate();

                    if (kDebugMode) {
                      print("Move button pressed");
                    }

                  },
                  child: const Text('Move'),
                ),
                const SizedBox(height: 10),
                if (unitInfo!.abilityProcedure.isNotEmpty)
                  ElevatedButton(
                    onPressed: () async {
                      if (kDebugMode) {
                        print("Execute Ability button pressed");
                      }
                      var ret = await mapManager.executeAbility(unitInfo!.tileId, Globalgame.mapId, user.session_token);
                      context
                          .findAncestorStateOfType<_MapViewState>()
                          ?.OnClose();
                      context
                          .findAncestorStateOfType<_MapViewState>()
                          ?.requestMapUpdate();
                    },
                    child: const Text('Execute Ability'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}




class LoadingScreen extends StatelessWidget {
  final String sessionToken;
  const LoadingScreen({super.key, required this.sessionToken});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GameMap>(
      future: mapManager.initialize(sessionToken),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Map Loader')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return MapView(
            sessionToken: sessionToken
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Map Loader')),
          body: const Center(child: Text('Failed to load map')),
        );
      },
    );
  }
}