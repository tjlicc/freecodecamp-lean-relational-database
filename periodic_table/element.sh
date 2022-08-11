PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c "

# use first arg as element's atomic_number or name or symbol
ELEMENT=$1

if [[ -z $ELEMENT ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $ELEMENT =~ ^[0-9]+$ ]]
  then
    CONDITION="elements.atomic_number=$ELEMENT"
  else
    CONDITION="elements.symbol='$ELEMENT' or elements.name='$ELEMENT'"
  fi
  
  ELEMEN_RESULT=$($PSQL "select elements.atomic_number, elements.name, elements.symbol, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius from elements inner join properties on elements.atomic_number=properties.atomic_number inner join types on types.type_id=properties.type_id where $CONDITION")
  if [[ -z $ELEMEN_RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    echo $ELEMEN_RESULT | while read ATOMIC_NUMBER BAR NAME BAR SYMBOL BAR TYPE BAR ATOMIC_MASS BAR MELTING_POINT_CELSIUS BAR BOILING_POINT_CELSIUS
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
    done
  fi
fi
