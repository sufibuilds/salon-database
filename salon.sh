#! /bin/bash

# Connection string to query the database
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n" [cite: 1, 5]
echo -e "Welcome to My Salon, how can I help you?\n" [cite: 1, 5]

MAIN_MENU() {
  # If a specific error message is passed, display it instead
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Fetch services from database
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # Format list dynamically: "id) name"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME" [cite: 2, 3, 6]
  done

  # Read user choice
  read SERVICE_ID_SELECTED

  # Validate selection against database
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # Loop back if not found
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?" [cite: 2]
  else
    # Prompt for phone number
    echo -e "\nWhat's your phone number?" [cite: 3, 6]
    read CUSTOMER_PHONE

    # Look up customer
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # If new customer, request name and record them
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?" [cite: 3]
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # Fetch customer ID for foreign key reference
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Clean up outputs by removing leading/trailing whitespaces returned by psql queries
    CLEAN_SERVICE_NAME=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')
    CLEAN_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')

    # Get appointment time
    echo -e "\nWhat time would you like your $CLEAN_SERVICE_NAME, $CLEAN_CUSTOMER_NAME?" [cite: 3, 6]
    read SERVICE_TIME

    # Log appointment to database
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Success confirmation string
    echo -e "\nI have put you down for a $CLEAN_SERVICE_NAME at $SERVICE_TIME, $CLEAN_CUSTOMER_NAME." [cite: 4, 7]
  fi
}

MAIN_MENU