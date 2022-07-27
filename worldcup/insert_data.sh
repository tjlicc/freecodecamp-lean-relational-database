#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# truncate all tables
echo $($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    # get winner_id
    WINNER_ID=$($PSQL "select team_id from teams where name = '$WINNER'")

    # if not found
    if [[ -z $WINNER_ID ]]
    then
      # insert a team
      INSERT_WINNER_RESULT=$($PSQL "insert into teams(name) values('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        # get new winner_id
        WINNER_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
      fi
    fi

    # get opponent_id
    OPPONENT_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")

    # if not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert a team
      INSERT_OPPONENT_RESULT=$($PSQL "insert into teams(name) values('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        # get new opponent_id
        OPPONENT_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")
      fi
    fi

    # insert a game
    INSERT_GAME_RESULT=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done