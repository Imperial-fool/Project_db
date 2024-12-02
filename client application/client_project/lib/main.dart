import 'package:client_project/MapManager.dart';
import 'package:client_project/lobbyscreen.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'Game.dart';
import 'gamePage.dart';
import 'Unit.dart';
import 'package:flutter/material.dart';
import 'lobbyscreen.dart';
import 'User.dart';
void main() => runApp(const MyApp());
User user = User();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   
    
    return const MaterialApp(
      
      home: Scaffold(
        backgroundColor: Colors.white60,
        body: Center(
          child: LoginBox()
          ),
        ),
      );
  }
}

class LoginBox extends StatefulWidget {
  const LoginBox({super.key});

  @override
  State<LoginBox> createState() => _LoginBoxState();

}

class _LoginBoxState extends State<LoginBox> {
  // Create TextEditingControllers for username and password
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String message = '';

  @override
  Widget build(BuildContext context) {
    return Center( // Center the whole widget within the screen
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6, // 60% width
        height: MediaQuery.of(context).size.height * 0.4, // 40% height
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900], // Set the background to grey
          borderRadius: BorderRadius.circular(12), // Optional rounded corners
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display message only after response
            if (message.isNotEmpty)
              Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Courier New', // 80s computer font
                  color: Colors.yellow, // Yellow text color
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 16),

            // Username input row
            Row(
              children: <Widget>[
                const Text(
                  'Username: ',
                  style: TextStyle(color: Colors.white, fontFamily: 'Courier New'),
                ),
                Expanded(
                  child: TextField(
                    style:const TextStyle(color: Colors.yellow, fontFamily: 'Courier New'),
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your username',
                      hintStyle: TextStyle(color: Colors.white70, fontFamily: 'Courier New'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Password input row
            Row(
              children: <Widget>[
                const Text(
                  'Password: ',
                  style: TextStyle(color: Colors.white, fontFamily: 'Courier New'),
                ),
                Expanded(
                  child: TextField(
                    style:const TextStyle(color: Colors.yellow, fontFamily: 'Courier New'),
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.white70, fontFamily: 'Courier New'),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Buttons (Login and Create User)
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      final username = _usernameController.text;
                      final password = _passwordController.text;
                      print('Login pressed: Username=$username, Password=$password');
                      user.login(username, password).then((value) {
                        if (user.session_token != '') {
                          // Navigate to the new page upon successful login
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(username: username, playerId: user.player_id.toString()),
                            ),
                          );
                        } else {
                          setState(() {
                            message = value;
                          });
                        }
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[700], // Slightly brighter grey for buttons
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: 'Courier New', // 80s computer font
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      final username = _usernameController.text;
                      final password = _passwordController.text;
                      print('Create User pressed: Username=$username, Password=$password');
                      user.createUser(username, password).then((value) {
                        setState(() {
                          message = value;
                        });
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[700], // Slightly brighter grey for buttons
                    ),
                    child: const Text(
                      'Create User',
                      style: TextStyle(
                        fontFamily: 'Courier New', // 80s computer font
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class HomePage extends StatelessWidget {
  final String username;
  final String playerId;

  HomePage({required this.username, required this.playerId});

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60, // Set the background to white60
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
      ),
      body: Stack(
        children: [
          
          // Centered Buttons (Create Game and Join Game)
          Container(
            color: Colors.grey[700],
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Colors.grey[700], // Container for Create Game button
                    child: ElevatedButton(
                      onPressed: () {
                        // Action for Join Game
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateGamePage(),
                        ),
                      );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Make background transparent for ElevatedButton
                        side: BorderSide(color: Colors.grey[700]!), // Match the grey border
                      ),
                      child: const Text(
                        'Create Game',
                        style: TextStyle(
                          fontFamily: 'Courier New', // 80s computer font
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    color: Colors.grey[700], // Container for Join Game button
                    child: ElevatedButton(
                      onPressed: () {
                        // Action for Join Game
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JoinGameScreen(),
                        ),
                      );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Make background transparent for ElevatedButton
                        side: BorderSide(color: Colors.grey[700]!), // Match the grey border
                      ),
                      child: const Text(
                        'Join Game',
                        style: TextStyle(
                          fontFamily: 'Courier New', // 80s computer font
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Username and player_id box
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              color: Colors.grey[800], // Box with grey background
              padding: const EdgeInsets.all(8),
              child: Text(
                '$username#$playerId',
                style: const TextStyle(
                  fontFamily: 'Courier New', // 80s computer font
                  color: Colors.yellow, // Yellow text color
                  fontSize: 18,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
