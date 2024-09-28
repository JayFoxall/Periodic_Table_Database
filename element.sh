#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

MAIN () {
  if [[ -z $1 ]] 
  then
    echo "Please provide an element as an argument."
  else

    GET_ATOMIC_NUMBER $1

    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo "I could not find that element in the database."
    fi

    if [[ $ATOMIC_NUMBER ]]
    then
      GET_ELEMENT_DATA
      PRINT_OUTPUT_MESSAGE
    fi

  fi
}

GET_ATOMIC_NUMBER(){
  if [[ $1 =~ ^[0-9]+$ ]]
  then
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1;")
  fi

  if [[ -z $ATOMIC_NUMBER ]] 
  then
    TRIMMED_INPUT=$(echo "$1" | sed 's/^[ \t]*//;s/[ \t]*$//')
    LOWERCASE_INPUT="${TRIMMED_INPUT,,}"
    NORMALISED_INPUT="${LOWERCASE_INPUT^}"
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$NORMALISED_INPUT';")
  fi

  if [[ -z $ATOMIC_NUMBER ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$NORMALISED_INPUT';")
  fi
}

GET_ELEMENT_DATA () {
  NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER;")
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER;")
  TYPE=$($PSQL "SELECT type FROM properties LEFT JOIN types USING (type_id) WHERE atomic_number = '$ATOMIC_NUMBER';")
  MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")
  MELTING_POINT_CELSIUS=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")
  BOILING_POINT_CELSIUS=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")
}

PRINT_OUTPUT_MESSAGE(){
  OUTPUT_MESSAGE="The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  echo $OUTPUT_MESSAGE
}

MAIN $1