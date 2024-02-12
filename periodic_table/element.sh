#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
SEARCH_TERM=$1
NUM_REGEX="[0-9]+"
SYM_REGEX="^[A-Za-z]{1,2}$"


SEARCH_ELEMENT() {
  # If you run ./element.sh, it should output only Please provide an element as an argument. and finish running.
  if [[ -z $SEARCH_TERM ]]
  then
    echo "Please provide an element as an argument."
  else
    # Find element
    if [[ $SEARCH_TERM =~ $NUM_REGEX ]] # input is a number
    then
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$SEARCH_TERM;" | sed -E 's/^ *| *$//g')
    elif [[ $SEARCH_TERM =~ $SYM_REGEX ]] # input is a symbol
    then
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol ILIKE '$SEARCH_TERM';" | sed -E 's/^ *| *$//g')
    else # input is a name
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name ILIKE '$SEARCH_TERM';" | sed -E 's/^ *| *$//g')
    fi

    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo "I could not find that element in the database."
    else
      # get name, symbol, type, mass, melting point, and boiling point
      NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER;" | sed -E 's/^ *| *$//g')
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER;" | sed -E 's/^ *| *$//g')
      MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER;" | sed -E 's/^ *| *$//g')
      MP=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER;" | sed -E 's/^ *| *$//g')
      BP=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER;" | sed -E 's/^ *| *$//g')
      TYPE=$($PSQL "SELECT type FROM properties LEFT JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER;" | sed -E 's/^ *| *$//g')
      
      # Format output sentence
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
    fi
  fi
}

SEARCH_ELEMENT
