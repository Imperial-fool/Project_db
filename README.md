This was a project for a random compsci course that quickly spiralled into a full-stack novel application that even my professor said with a few more weeks of polish
could have become a the basis for a master's thesis. 
it is only a prototype at the moment, as this was completed solo in under 4 weeks.

The basic stucture of the application is modeled after financial software, I created a backend DB that does all state management for a game
these stored procs are then used by the middleware to call 'game' functions, which can be interacted with by the flutter frontend

completed features-

    -Map gen
    
    -In house session auth/user creation
    
    -Lobby system
    
    -Unit movement
    
    -Turn logic
    
WIP

	-City creation (in db/not in frontend)
  
  	-Building (in db/ not in frontend)
  
 	 -Unit abilties (in db/partially functional)
  
Incomplete/not possible with architecture

  	-fog of war (while possible this would require a function to be called number of player per turn + whenever a unit is moved, this computationally is expensive for a database but i do want to explore query optimizations to implement this without it taking 20 seconds to execute a bst search)
  
	-Battling (honestly relatively simple to implement and have notes on how to do it but time constraints prevented it) 
  
  	-Map view updates (controlled territory isn't reflected in the frontend, need to change some map view code)
  
