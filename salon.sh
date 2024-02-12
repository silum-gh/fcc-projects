#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n\n~~~~~ MY SALON ~~~~~\n\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get services
  SERVICES_AVAILABLE=$($PSQL "SELECT * FROM services ORDER BY service_id;")

  # list services
  echo "$SERVICES_AVAILABLE" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  # select service
  read SERVICE_ID_SELECTED
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED';")

  # if not a service
  if [[ -z $SERVICE_ID ]]
  then
    MAIN_MENU "Please pick one from the list."

  # proceed to appointment booking
  else
   
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED';")

    # get phone number
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

    # if new customer
    if [[ -z $CUSTOMER_ID ]]
    then
      # get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      # add new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
    fi
    
    # get customer name and ID
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

    # ask for time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # add appointment
    ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")

    # booking message/redirect/exit
    echo -e "I have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
    
  fi
}


MAIN_MENU
