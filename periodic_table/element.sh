#!/bin/bash
# Element script

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_INFO=$($PSQL "SELECT symbol,name FROM elements WHERE atomic_number=$1")

    if [[ -z $ELEMENT_INFO ]]
    then
      echo "I could not find that element in the database."
    else
      PROPERTIES_INFO=$($PSQL "SELECT type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM properties FULL JOIN types USING(type_id) WHERE atomic_number=$1")

      echo $ELEMENT_INFO | while IFS="|" read SYMBOL NAME
      do
        SYMBOL=$(echo $SYMBOL | sed 's/ //g')
        NAME=$(echo $NAME | sed 's/ //g')
        echo $PROPERTIES_INFO | while IFS="|" read TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
        do
          TYPE=$(echo $TYPE | sed 's/ //g')
          ATOMIC_MASS=$(echo $ATOMIC_MASS | sed 's/ //g')
          MELTING_POINT=$(echo $MELTING_POINT | sed 's/ //g')
          BOILING_POINT=$(echo $BOILING_POINT | sed 's/ //g')
          
          echo "The element with atomic number $1 is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
        done
      done
    fi
  else
    #echo "Not number"
    if [[ $1 =~ ^[A-Z][a-z]?$ ]]
    then
      ELEMENT_INFO=$($PSQL "SELECT atomic_number,name FROM elements WHERE symbol='$1'")

      if [[ -z $ELEMENT_INFO ]]
      then
        echo "I could not find that element in the database."
      else
        echo $ELEMENT_INFO | while IFS="|" read ATOMIC_NUMBER NAME
        do
          ATOMIC_NUMBER=$(echo $ATOMIC_NUMBER | sed 's/ //g')
          NAME=$(echo $NAME | sed 's/ //g')

          PROPERTIES_INFO=$($PSQL "SELECT type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM properties INNER JOIN elements USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
          
          echo $PROPERTIES_INFO | while IFS="|" read TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
          do
            TYPE=$(echo $TYPE | sed 's/ //g')
            ATOMIC_MASS=$(echo $ATOMIC_MASS | sed 's/ //g')
            MELTING_POINT=$(echo $MELTING_POINT | sed 's/ //g')
            BOILING_POINT=$(echo $BOILING_POINT | sed 's/ //g')
            
            echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($1). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
          done
        done
      fi
    else
      #echo "Not number or symbol"
      ELEMENT_INFO=$($PSQL "SELECT atomic_number,symbol FROM elements WHERE name='$1'")

      if [[ -z $ELEMENT_INFO ]]
      then
        echo "I could not find that element in the database."
      else
        echo $ELEMENT_INFO | while IFS="|" read ATOMIC_NUMBER SYMBOL
        do
          ATOMIC_NUMBER=$(echo $ATOMIC_NUMBER | sed 's/ //g')
          SYMBOL=$(echo $SYMBOL | sed 's/ //g')

          PROPERTIES_INFO=$($PSQL "SELECT type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM properties INNER JOIN elements USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
          
          echo $PROPERTIES_INFO | while IFS="|" read TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
          do
            TYPE=$(echo $TYPE | sed 's/ //g')
            ATOMIC_MASS=$(echo $ATOMIC_MASS | sed 's/ //g')
            MELTING_POINT=$(echo $MELTING_POINT | sed 's/ //g')
            BOILING_POINT=$(echo $BOILING_POINT | sed 's/ //g')
            
            echo "The element with atomic number $ATOMIC_NUMBER is $1 ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $1 has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
          done
        done
      fi
    fi
  fi
fi
