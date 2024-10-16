#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

CHECK_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

if [[ -z $CHECK_USER ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."

  ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")

else
  EXISTING_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")

  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

  echo "Welcome back, $EXISTING_USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
 
read USER_GUESS

GUESS_COUNT=1

until [ $USER_GUESS == $SECRET_NUMBER ]
do

  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read USER_GUESS
  fi

  while [[ $USER_GUESS -gt $SECRET_NUMBER ]]
  do
    echo "It's lower than that, guess again:"

    (( GUESS_COUNT++ ))

    read USER_GUESS
  done

  while [[ $USER_GUESS -lt $SECRET_NUMBER ]]
  do
    echo "It's higher than that, guess again:"

    (( GUESS_COUNT++ ))

    read USER_GUESS
  done
done


USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

INSERT_GAME=$($PSQL "INSERT INTO users(user_id, username, games_played) VALUES($USER_ID, '$USERNAME', $GUESS_COUNT)")

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

if [[ $GAMES_PLAYED = 0 ]] || [[ $GUESS_COUNT -lt $BEST_GAME ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE username = '$USERNAME'")
fi

ADD_GAME_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")

echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
