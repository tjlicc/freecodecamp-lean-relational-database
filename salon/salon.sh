#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICE_LIST=$($PSQL "select service_id, name from services")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    # if service can not found
    if [[ -z $SERVICE_NAME ]]
    then
      # send to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # ask for phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # find customer id
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")

      # if customer can not found
      if [[ -z $CUSTOMER_ID ]]
      then
        # ask for customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # insert customer
        INSERT_RESULT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      fi

      # ask for time
      SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ *//')
      CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *//')
      echo -e "\nWhat time would you like your $SERVICE_NAME, ${CUSTOMER_NAME}?"
      read SERVICE_TIME

      # insert appointment
      INSERT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU
