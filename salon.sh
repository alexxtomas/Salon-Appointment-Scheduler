#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Welcome to the Salon ~~~\n"

# Function to display services
DISPLAY_SERVICES() {
  echo -e "\nHere are the available services:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

# Prompt user to select a service
MAIN_MENU() {
  DISPLAY_SERVICES
  echo -e "\nPlease select a service by entering the service ID:"
  read SERVICE_ID_SELECTED

  # Validate service ID
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nInvalid service ID. Please try again."
    MAIN_MENU
  else
    echo -e "\nYou selected $SERVICE_NAME. Let's proceed."
    GET_CUSTOMER_INFO
  fi
}

# Get customer info
GET_CUSTOMER_INFO() {
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  # Check if customer exists
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nIt looks like you're a new customer. What's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
  fi

  SCHEDULE_APPOINTMENT
}

# Schedule appointment
SCHEDULE_APPOINTMENT() {
  echo -e "\nWhat time would you like your appointment?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ //')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ //')
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  else
    echo -e "\nSomething went wrong. Please try again."
  fi
}

MAIN_MENU
