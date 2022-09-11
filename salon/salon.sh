#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ MY SALON ~~\n"
echo "Welcome, how can I help you?"

MAIN_MENU() {
  echo -e "$1"

  echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID PIPE NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  MAX_SERVICE_ID=$($PSQL "SELECT MAX(service_id) FROM services")
  if [[ $SERVICE_ID_SELECTED =~ '^[0-9]+$' ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"
  fi

  if [[ $SERVICE_ID_SELECTED > $MAX_SERVICE_ID || $SERVICE_ID_SELECTED -le 0 ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  RESULT_PHONE=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $RESULT_PHONE ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    AUX=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi

  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  AUX=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

EXIT() {
  echo "Thank you."
}

MAIN_MENU