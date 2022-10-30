#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WGOALS OGOALS
do
  if [[ $YEAR != "year" ]]
  then
    TEAM_ID_FROM_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    if [[ -z $TEAM_ID_FROM_WINNER ]]
    then
      INSERT_TEAM_RESULT_FROM_WINNER="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"

      if [[ $INSERT_TEAM_RESULT_FROM_WINNER == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi

      TEAM_ID_FROM_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    TEAM_ID_FROM_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    if [[ -z $TEAM_ID_FROM_OPPONENT ]]
    then
      INSERT_TEAM_RESULT_FROM_OPPONENT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"

      if [[ $INSERT_TEAM_RESULT_FROM_OPPONENT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi

      TEAM_ID_FROM_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id='$TEAM_ID_FROM_WINNER' AND opponent_id='$TEAM_ID_FROM_OPPONENT'")

    if [[ -z $GAME_ID ]]
    then
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID_FROM_WINNER, $TEAM_ID_FROM_OPPONENT, $WGOALS, $OGOALS)")

      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo "Insert into games: $WINNER($WGOALS) VS $OPPONENT($OGOALS)"
      fi
    fi
  fi
done