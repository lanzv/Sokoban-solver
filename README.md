# Sokoban-solver
Final semestral project of first half year studying.

Sokoban is a game on a field n*m with obstractions, boxes, target positions and with one guy. That guy has to move all of boxes to
target positions. But he can not go through obstractions or through two boxes next to each other.

This console PASCAL application is designed to solve this game, find and show the steps. It contains text file maps.txt with maps we
want o have solved. Maps should be with specific format. First line of one record is '#name_of_map'. Final line is '#' too. Then every
map has to be in format n*m. Obstraction is represented by 'x'. Box is represented by 'k'. Box on target place is represented by 'K'. 
And the guy, or player, is represented by 'p' and if he is on target place by 'P'. The target place is represented by 'O'.

The algorithm is based on dynamic programming by recursively searching all paths (each path only once). There is one trick, that we
are looking only for paths of boxes movements and we ignore the player (we are just using the information about available fields for the
player). Then we use an A* algorithm to find the path for player to our box, if it is the move we want to do to finish the map. 
