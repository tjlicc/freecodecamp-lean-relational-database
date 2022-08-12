#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$((RANDOM % 1000 + 1))
GAMES_PLAYED=0
GUESS_TIMES=0

GAME() {
  echo -n "Enter your username: "
  read USERNAME

  if [[ -z $USERNAME ]]
  then
    GAME
  else
    # find username from database
    USER_RESULT=$($PSQL "select games_played, best_game from game_users where username='$USERNAME';")
    
    if [[ -z $USER_RESULT ]]
    then
      echo "Welcome, ${USERNAME}! It looks like this is your first time here."
      # insert an user
      INSERT_RESULT=$($PSQL "insert into game_users(username) values('$USERNAME')")
    else
      GAMES_PLAYED=$(echo "$USER_RESULT" | sed -E 's/(.*)\|(.*)|/\1/')
      BEST_GAME=$(echo "$USER_RESULT" | sed -E 's/(.*)\|(.*)|/\2/')

      if [[ -z $GAMES_PLAYED ]]
      then
        echo "Welcome back, ${USERNAME}! You have not played any games."
        GAMES_PLAYED=0
      else
        echo "Welcome back, ${USERNAME}! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      fi
    fi

    GUESS
  fi
}

GUESS() {
  if [[ -z $1 ]]
  then
    echo -n "Guess the secret number between 1 and 1000: "
  else 
    echo -n "$1"
  fi
  read GUESS_NUMBER

  if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  then
    GUESS "That is not an integer, guess again: "
  else
    GUESS_TIMES=$((GUESS_TIMES + 1))
    if [[ $GUESS_NUMBER < $RANDOM_NUMBER ]]
    then
      GUESS "It's lower than that, guess again: "
    elif [[ $GUESS_NUMBER > $RANDOM_NUMBER ]]
    then
      GUESS "It's higher than that, guess again: "
    else
      echo "You guessed it in $GUESS_TIMES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      # save data
      GAMES_PLAYED=$((GAMES_PLAYED + 1))
      if [[ -z $BEST_GAME ]]
      then
        BEST_GAME=$GUESS_TIMES
      else
        BEST_GAME=$((GUESS_TIMES > BEST_GAME ? BEST_GAME : GUESS_TIMES))
      fi
      UPDATE_RESULT=$($PSQL "update game_users set games_played=$GAMES_PLAYED, best_game=$BEST_GAME where username='$USERNAME'")
    fi
  fi
}

GAME
