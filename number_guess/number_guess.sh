#!/bin/bash
#Number guessing game

NUMBER_GUESS=$(($RANDOM%1000))
#echo $NUMBER_GUESS

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo "Enter your username:"
read USERNAME

USERNAME_RESULT=$($PSQL "SELECT games_played, best_game FROM users INNER JOIN userdata USING(user_id) WHERE name='$USERNAME'")

if [[ -z $USERNAME_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."

  ADD_USERNAME=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")

  ADD_USERDATA=$($PSQL "INSERT INTO userdata(user_id) VALUES('$USER_ID')")

else
  echo "$USERNAME_RESULT" | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
fi

NUMBER_OF_TRIES=0
echo "Guess the secret number between 1 and 1000:"

while [[ $USER_GUESS != $NUMBER_GUESS ]]
do
  read USER_GUESS
  ((NUMBER_OF_TRIES++))

  if [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $USER_GUESS -lt $NUMBER_GUESS ]]
    then
      echo "It's higher than that, guess again:"
    else
      if [[ $USER_GUESS -gt $NUMBER_GUESS ]]
      then
        echo "It's lower than that, guess again:"
      fi
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done

echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $NUMBER_GUESS. Nice job!"

echo "$USERNAME_RESULT" | while IFS="|" read GAMES_PLAYED BEST_GAME
do
  SUM_PLAYS=$($PSQL "UPDATE userdata SET games_played=$(($GAMES_PLAYED+1)) WHERE user_id=$USER_ID")

  if [[ $BEST_GAME -gt $NUMBER_OF_TRIES || $BEST_GAME -eq 0 ]]
  then
    BEST_UPDATE=$($PSQL "UPDATE userdata SET best_game=$NUMBER_OF_TRIES WHERE user_id=$USER_ID")
  fi
done
