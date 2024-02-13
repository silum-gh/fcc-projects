#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo Enter your username:

LOGIN() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # take username
  read USERNAME
  USERNAME_LENGTH=$(echo -n $USERNAME | wc -m)

  if [[ $USERNAME_LENGTH -gt 22 ]]
  then
    LOGIN "Please enter a valid username."
  else
    # find user in database
    USER_LOOKUP=$($PSQL "SELECT username FROM players WHERE username='$USERNAME';")
    
    # greeting message
    if [[ -z $USER_LOOKUP ]] # new player
    then
      echo "Welcome, $USERNAME! It looks like this is your first time here."
      
      # add new player
      INSERT_USER_RESULT=$($PSQL "INSERT INTO players(username, games_played) VALUES('$USERNAME', 0);")

    else
      # get stats
      GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username='$USERNAME';" | sed 's/^ *| *$//g')
      BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME';" | sed 's/^ *| *$//g')

      # welcome message
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    fi

    
  fi
}

TAKE_GUESS() {
  INT_REGEX="^[0-9]+$"

  if [[ -z $GUESS ]]
  then
    echo "Guess the secret number between 1 and 1000:"
  fi

  read GUESS
  NUM_GUESSES=$(( NUM_GUESSES + 1 ))

  # not an integer
  if [[ ! $GUESS =~ $INT_REGEX ]]
  then
    echo "That is not an integer, guess again:"
    TAKE_GUESS
  else
    return
  fi
}

GUESSING_GAME() {
  
  NUM=$(( RANDOM % 1000 + 1 ))
  echo $NUM
  NUM_GUESSES=0

  # input guess
  TAKE_GUESS

  until [[ $GUESS == $NUM ]]
  do
    if [[ $GUESS -gt $NUM ]] 
    then
      echo "It's lower than that, guess again:"
      TAKE_GUESS
    else
      echo "It's higher than that, guess again:"
      TAKE_GUESS
    fi
  done
  
  GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED WHERE username='$USERNAME';")

  # if new best game
  if [[ -z $BEST_GAME || $NUM_GUESSES -gt $BEST_GAME ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE players SET best_game=$NUM_GUESSES WHERE username='$USERNAME';")
  fi

  echo "You guessed it in $NUM_GUESSES tries. The secret number was $NUM. Nice job!"

}

LOGIN
GUESSING_GAME
