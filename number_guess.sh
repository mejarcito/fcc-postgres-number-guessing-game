#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=guessing_number_game --tuples-only -c"

echo -e "\n~~~~~ Guessing Number Game ~~~~~\n"

# generate random number
RANDOM_NUMBER=$(($RANDOM%1000))
echo $RANDOM_NUMBER

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username= '$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo Welcome, $USERNAME! It looks like this is your first time here.
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  
  # get new user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username= '$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $USER_ID")
  echo "Welcome back, $(echo $USERNAME | sed -r 's/^ *| *$//')! You have played $(echo $GAMES_PLAYED | sed -r 's/^ *| *$//') games, and your best game took $(echo $BEST_GAME | sed -r 's/^ *| *$//') guesses."
fi

echo Guess the secret number between 1 and 1000:
read GUESS

TRIES=1

while [[ $GUESS != $RANDOM_NUMBER ]]
do

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
  elif [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
  elif [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read GUESS
  fi

  ((TRIES++))

done
INSERT_GUESS_RESULT=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($TRIES, $USER_ID)")

echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
