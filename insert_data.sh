#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPP WIN_GOALS OPP_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    #get winner team ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    
    #if not found
    if [[ -z $WINNER_ID ]]
    then
      #insert id
      INSERT_WINNER_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ $INSERT_WINNER_ID_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi

      #get new id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    fi

    #get loser team id
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPP';")

    #if not found
    if [[ -z $OPP_ID ]]
    then
      #insert id
      INSERT_OPP_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPP');")
      if [[ $INSERT_OPP_ID_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPP
      fi

      #get new id
      OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPP';")

    fi
    
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPP_ID, $WIN_GOALS, $OPP_GOALS);")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games, $WINNER vs $OPP $ROUND ($YEAR)"
    fi

  fi
done
