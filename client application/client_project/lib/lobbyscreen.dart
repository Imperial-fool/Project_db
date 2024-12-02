import 'package:client_project/Game.dart';
import 'package:client_project/MapManager.dart';
import 'package:client_project/game_view.dart';
import 'package:client_project/main.dart';
import "package:flutter/material.dart";
import 'package:flutter/material.dart';
import 'Game.dart';
import 'main.dart';

class CreateGamePage extends StatefulWidget {
  @override
  _CreateGamePageState createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  final _formKey = GlobalKey<FormState>();
  int _maxPlayerCount = 2;
  int _mapSizeX = 10;
  int _mapSizeY = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: 'Max Player Count',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a max player count';
                  }
                  return null;
                },
                items: [2, 3, 4, 5, 6, 7, 8, 9, 10]
                    .map((e) => DropdownMenuItem(
                          child: Text(e.toString()),
                          value: e,
                        ))
                    .toList(),
                onChanged: (int? value) {
                  setState(() {
                    _maxPlayerCount = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Map Size X',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a map size X';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid integer';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _mapSizeX = int.parse(value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Map Size Y',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a map size Y';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid integer';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _mapSizeY = int.parse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final gameId = await AllGames().createGame(_maxPlayerCount, _mapSizeX, _mapSizeY, user.session_token);
                    final game = await AllGames().getGame(user.session_token, gameId);
                    Globalgame = game;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LobbyScreen(
                          sessionToken: user.session_token
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Create Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class JoinGameScreen extends StatefulWidget {
  @override
  _JoinGameScreenState createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  late Future<List<Game>> _games;

  @override
  void initState() {
    super.initState();
    _games = AllGames().getAllgames(user.session_token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Game'),
      ),
      body: FutureBuilder<List<Game>>(
        future: _games,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No active games available.'));
          }

          final games = snapshot.data!;

          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('Game ${game.gameId}'),
                  subtitle: Text('Type: ${game.gameType}, Players: ${game.playerCount}/${game.maxPlayerCount}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {
                      user.addPlayerToActiveGame(user.session_token, user.player_id, game.gameId).then((value) {
                        Globalgame = game;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LobbyScreen(
                              sessionToken: user.session_token,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LobbyScreen extends StatelessWidget {
  final String sessionToken;

  const LobbyScreen({Key? key, required this.sessionToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Lobby',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Globalgame.startGame(sessionToken).then((value) {
                   {
                    Globalgame = value;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoadingScreen(sessionToken: user.session_token),
                      ),
                    );
                  }
                });
              },
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

