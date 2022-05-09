# Hang-man

This game is based on the classic hang-man that you used to play
on the white board in elementary school. The player creating the secret word can
be human or computer while the guesse must be human (due to the saving and quitting options).  
The guesser must choose a letter that makes up the word.  
The guesser loses if they lose after the stick figure is fully shown 
(or 7 tries) and the player who set the word gains a point.  
The guesser wins and gains a point if they guess the word before 7 tries.  
Points are endless and there are no rounds, they are only used as a tracker.  
The guesser can save the current game while they are guessing or just before they quit the session.
Overwriting a file is possible if guesser enters an existing file name, 
but the guesser can choose not to and create a new slightly modified name. 
The guesser can load the file at the beginning of each session (a
new game is automatically started if there are no files). Quitting
is also possible while the guesser is guessing.
