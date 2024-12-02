// index.js
require('dotenv').config();
const express = require('express');
const { poolPromise, sql } = require('./db');

const app = express();
app.use(express.json());

// createGame API
app.post('/game/createGame', async (req, res) => {
  if (
    !req.body.hasOwnProperty('player_max_count') ||
    !req.body.hasOwnProperty('gametype') ||
    !req.body.hasOwnProperty('map_size_x') ||
    !req.body.hasOwnProperty('map_size_y') ||
    !req.body.hasOwnProperty('session_token')
  ) {
    return res.status(400).json({ error: 'All parameters are required.' });
  }

  const { player_max_count, gametype, map_size_x, map_size_y, session_token } = req.body;

  try {
    const pool = await poolPromise;
    console.log('Session Token:', session_token, typeof session_token);
    const result = await pool.request()
      .input('player_max_count', sql.Int, player_max_count)
      .input('gametype', sql.Int, gametype)
      .input('map_size_x', sql.Int, map_size_x)
      .input('map_size_y', sql.Int, map_size_y)
      .input('session_token', sql.UniqueIdentifier, session_token)
      .execute('dbo.createGame');

    res.status(200).json({ message: 'Game created successfully.', gameId: result.recordset[0][''] });
  } catch (error) {
    console.error('Error executing createGame:', error);
    res.status(500).json({ error: 'Failed to create game.' });
  }
});

app.post('/player/generatePlayer', async (req, res) => {
  
  if (
    !req.body.hasOwnProperty('password') ||
    !req.body.hasOwnProperty('username')
  ) {
    return res.status(400).json({ error: 'Password and username are required.' });
  }

  const { password, username } = req.body;
  console.log('Executing request: generatePlayer, values: ', password, ' ', username);
  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('password', sql.VarChar(25), password)
      .input('username', sql.VarChar(25), username)
      .output('output', sql.Int)
      .execute('GeneratePlayer');

    res.status(200).json({ output: result.output.output });
  } catch (error) {
    console.error('Error executing GeneratePlayer:', error);
    res.status(500).json({ error: 'Failed to generate player.' });
  }
});

app.post('/player/login', async (req, res) => {
  if (
    !req.body.hasOwnProperty('username') ||
    !req.body.hasOwnProperty('password')
  ) {
    return res.status(400).json({ error: 'Username and password are required.' });
  }

  const { username, password } = req.body;
  console.log('Executing request: login, values: ', password, ' ', username);
  try {
    const pool = await poolPromise;
    const result = await pool.request()
    .input('password', sql.VarChar(25), password)
    .input('username', sql.VarChar(25), username)
    .output('session_token', sql.UniqueIdentifier)
    .output('player_id', sql.Int)
    .execute('dbo.PLAYERLOGIN');

    if(result.returnValue === 0) {

      return res.status(200).json({
        message: 'Login successful',
        sessionToken: result.output.session_token,
        player_id: result.output.player_id
      });
    }else{
      return res.status(401).json({error: 'invalid username or password'})
    }
  } catch (error) {
    console.error('error executing store proc:', error);
    return res.status(500).json({error: 'internal server error'});
  }
})

// AddPlayerToActiveGame API
app.post('/player/addPlayerToActiveGame', async (req, res) => {
  if (
    !req.body.hasOwnProperty('player_id') ||
    !req.body.hasOwnProperty('game_id') ||
    !req.body.hasOwnProperty('session_token')
  ) {
    return res.status(400).json({ error: 'Player ID, game ID, and session token are required.' });
  }

  const { player_id, game_id, session_token } = req.body;

  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('player_id', sql.Int, player_id)
      .input('game_id', sql.Int, game_id)
      .input('session_token', sql.UniqueIdentifier, session_token)
      .execute('dbo.AddPlayerToActiveGame');

    res.status(200).json({ message: 'Player added to the active game if there was space.' });
  } catch (error) {
    console.error('Error executing AddPlayerToActiveGame:', error);
    res.status(500).json({ error: 'Failed to add player to active game.' });
  }
});

app.post('/game/get-current-game-info', async (req, res) => {
  if (!req.body.hasOwnProperty('session_token')) {
    return res.status(400).json({ error: 'Session token is required.' });
  }

  const { session_token } = req.body;

  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('session_token', sql.UniqueIdentifier, session_token)
      .execute('getCurrentGameInfo')

    if (result.recordset.length === 0) {
      res.status(404).json({ error: 'Player is not in a game' });
    } else {
      res.json(result.recordset[0]);
    }
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Database error' });
  } finally {
    sql.close();
  }
})

app.post('/map/get-current-map-info', async(req, res) => {
  if (!req.body.hasOwnProperty('session_token')) {
    return res.status(400).json({ error: 'Session token is required.' });
  }

  const { session_token } = req.body;
  
  try{
    const pool = await poolPromise;
    const result = await pool.request()
    .input('session_token', sql.UniqueIdentifier, session_token)
    .execute('getCurrentMapInfo')
   
    res.json(result.recordset);
  }catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Database error' });
  } finally {
    sql.close(); 
  }
})

app.post('/unit/get-info', async (req, res) => {
  if (
    !req.body.hasOwnProperty('TILE_ID') ||
    !req.body.hasOwnProperty('session_token')
  ) {
    return res.status(400).json({ error: 'TILE_ID and session_token are required.' });
  }

  const { TILE_ID, session_token } = req.body;

  try {
    const pool = await poolPromise;
    console.log('Executing getUnitInfo with TILE_ID:', TILE_ID, 'and session_token:', session_token);

    const result = await pool.request()
      .input('TILE_ID', sql.UniqueIdentifier, TILE_ID)
      .input('session_token', sql.UniqueIdentifier, session_token)
      .execute('dbo.getUnitInfo');

    // Check for the return value indicating the execution outcome
    if (result.returnValue === 1) {
      return res.status(401).json({ error: 'Not a valid session token.' });
    }

    // Send the retrieved unit info
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error executing getUnitInfo:', error);
    res.status(500).json({ error: 'Failed to retrieve unit info.' });
  }
});
app.post('/unit/move', async (req, res) => {
  const { origin_x, origin_y, target_x, target_y, map_id, session_token } = req.body;

  if (
    !req.body.hasOwnProperty('origin_x') ||
    !req.body.hasOwnProperty('origin_y') ||
    !req.body.hasOwnProperty('target_x') ||
    !req.body.hasOwnProperty('target_y') ||
    !req.body.hasOwnProperty('map_id') ||
    !req.body.hasOwnProperty('session_token')
  ) {
    return res.status(300).json({ error: 'All parameters are required.' });
  }

  try {
    const pool = await poolPromise;

    const result = await pool.request()
      .input('origin_x', sql.Int, origin_x)
      .input('origin_y', sql.Int, origin_y)
      .input('target_x', sql.Int, target_x)
      .input('target_y', sql.Int, target_y)
      .input('map_id', sql.UniqueIdentifier, map_id)
      .input('session_token', sql.UniqueIdentifier, session_token)
      .execute('dbo.move_entity');  // Execute the stored procedure

    const returnValue = result.returnValue;

    // Check for possible errors returned by the stored procedure
    if (returnValue === 1) {
      return res.status(401).json({ error: 'Entity has already moved.' });
    } else if (returnValue === 2) {
      return res.status(402).json({ error: 'Player does not own this entity.' });
    } else if (returnValue === 3) {
      return res.status(403).json({ error: 'Invalid move.' });
    } else if (returnValue === 4) {
      return res.status(200).json({ message: 'Entity moved successfully.' });
    }

    // Default error response
    res.status(500).json({ error: 'An unexpected error occurred.' });
  } catch (error) {
    console.error('Error executing move_entity:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});
app.post('/unit/executeAbility', async (req, res) => {
  if (
    !req.body.hasOwnProperty('x') ||
    !req.body.hasOwnProperty('y') ||
    !req.body.hasOwnProperty('map_id') ||
    !req.body.hasOwnProperty('session_token')
  ) {
    return res.status(400).json({ error: 'x, y, map_id, and session_token are required.' });
  }

  const { x, y, map_id, session_token } = req.body;

  try {
    const pool = await poolPromise;
    console.log('Executing ExecuteAbility with x:', x, ', y:', y, ', map_id:', map_id, ', session_token:', session_token);

    const result = await pool.request()
      .input('x', sql.Int, x)
      .input('y', sql.Int, y)
      .input('map_id', sql.UniqueIdentifier, map_id)
      .input('session_token', sql.UniqueIdentifier, session_token)
      .execute('dbo.ExecuteAbility');
    console.log(result);
    // Check for the return value indicating the execution outcome
    if (result.returnValue === 2) {
      return res.status(400).json({ error: 'Ability has already been used for this entity.' });
    }
    if (result.returnValue === 3) {
      return res.status(400).json({ error: 'No ability procedure found for the unit.' });
    }
    if(result.returnValue === 1){
    // If the procedure is executed successfully, return success response
    res.status(200).json({ message: 'Ability executed successfully.' });
    }
  } catch (error) {
    console.error('Error executing ExecuteAbility:', error);
    res.status(500).json({ error: 'Failed to execute ability.' });
  }
});

app.post('/game/endTurn', async (req, res) => {
  if (!req.body.hasOwnProperty('session_token')) {
    return res.status(400).json({ error: 'Session token is required.' });
  }

  const { session_token } = req.body;

  try {
    const pool = await poolPromise;

    const result = await pool.request()
      .input('session_token', sql.UniqueIdentifier, session_token)
      .execute('dbo.endturn');

    // If no errors occur, return success response
    res.status(200).json({ message: 'Turn ended successfully.' });
  } catch (error) {
    console.error('Error ending turn:', error);
    res.status(500).json({ error: 'Failed to end turn.' });
  }
});

app.post('/game/start', async (req, res) => {
  if (!req.body.hasOwnProperty('session_token')) {
    return res.status(400).json({ error: 'Session token is required.' });
  }

  const { session_token } = req.body;

  try {
    const pool = await poolPromise; // Get the database connection pool

    // Execute the `startGame` stored procedure
    const result = await pool.request()
      .input('session_token', sql.UniqueIdentifier, session_token)
      .execute('startGame');

    // Check if the procedure executed correctly
    if (result.returnValue === 0) {
      res.status(200).json({ message: 'Game started successfully.' });
    } else {
      res.status(400).json({ error: 'Failed to start game. Check if the player is authorized or if the game is already started.' });
    }
  } catch (error) {
    console.error('Error executing startGame:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/games/get-all-games', async (req, res) => {
  if (!req.body.hasOwnProperty('session_token')) {
    return res.status(400).json({ error: 'Session token is required.' });
  }

  const { session_token } = req.body;
  
  try{
    const pool = await poolPromise;
    const result = await pool.request()
    .input('session_token', sql.UniqueIdentifier, session_token) 
    .execute('getAllGames'); 

    res.json(result.recordset);
  }catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Database error' });
  } finally {
    sql.close();
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
