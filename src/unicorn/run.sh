#!/bin/sh

echo 'Starting... \n'
echo "$(mongo --version) \n"

# Check variables
if [ -z "$MONGO_ADDRESS" ];
then
	echo MONGO_ADDRESS variable is not set
	exit 1
fi;

if [ -z "$RECREATE_COLLECTIONS" ];
then
  echo RECREATE_COLLECTIONS variable is not set and it will have default value: false
  echo Collections will not be re-created

  $RECREATE_COLLECTIONS="false"
else
  RECREATE_COLLECTIONS="$(echo $RECREATE_COLLECTIONS | tr [:upper:] [:lower:])"
  echo WARNING:
  echo "\t" Collections with matching names will be re-created
  echo "\t" If you do not want this option set RECREATE_COLLECTIONS environment variable to '"false"' "\n\n"
fi;

# Show environment variables
echo ENVIRONMENT:
echo "\t" MONGO_ADDRESS: $MONGO_ADDRESS
echo "\t" RECREATE_COLLECTIONS: $RECREATE_COLLECTIONS "\n\n"

echo INFO: Current folder: "$PWD"

find data/* -type d | while read filename;
do
	DATABASE_NAME="$(basename "$filename")"
    DATABASE_INDEX="$(echo "db.getMongo().getDBNames().indexOf('$DATABASE_NAME')" | mongo "$MONGO_ADDRESS" --quiet)"

	if [ "$DATABASE_INDEX" != "-1" ]
	then
	  echo INFO: Database: $DATABASE_NAME exists
	else
	  echo INFO: Database: $DATABASE_NAME does not exists
	fi;

	cd data/$DATABASE_NAME
	echo INFO: Moved into folder: $PWD

	find ./* -type f | while read filename;
	do
		COLLECTION_NAME="$(basename "$filename" .json)"
		FILE_NAME="$(basename "$filename")"

		COLLECTION_EXISTS="$(mongo $MONGO_ADDRESS/$DATABASE_NAME --eval "printjson(db.getCollectionInfos( { name: '$COLLECTION_NAME' } ))" --quiet)"
		COLLECTION_EMPTY="[ ]"

        if [ "$RECREATE_COLLECTIONS" = "true" ] && [ "$COLLECTION_EXISTS" != "$COLLECTION_EMPTY" ];
		then
			echo INFO: Removing collection: $COLLECTION_NAME

			DROP_CMD="db.$COLLECTION_NAME.drop()"
			RESULT="$(mongo $MONGO_ADDRESS/$DATABASE_NAME --eval "printjson($DROP_CMD)" --quiet)"
            RESULT="$(echo $RESULT | tr [:upper:] [:lower:])"

			if [ "$RESULT" = "true" ];
			then
				echo INFO: Finished removing collection: $COLLECTION_NAME
			else
				echo ERROR: Removing collection: $COLLECTION_NAME failed
				echo ERROR: Reason: $RESULT
				exit 1
			fi;
		else
		  echo INFO: Collection: $COLLECTION_NAME does not exist
		fi;

		echo INFO: Starting import on host: $MONGO_ADDRESS for database/collection: $DATABASE_NAME/$COLLECTION_NAME "\n"
		mongoimport --host $MONGO_ADDRESS --db $DATABASE_NAME --collection $COLLECTION_NAME --type json --file $FILE_NAME --jsonArray -v

		echo INFO: Finished import on host: $MONGO_ADDRESS for database/collection: $DATABASE_NAME/$COLLECTION_NAME "\n"
	done;

	cd ..
	cd ..

	echo INFO: Moved back to root folder: "$(basename "$PWD")"

done;

echo "\t\t" "                                             "
echo "\t\t" "                               /             "
echo "\t\t" "                    __       //              "
echo "\t\t" "                    -\= \=\ //               "
echo "\t\t" "                  --=_\=---//=--             "
echo "\t\t" "                -_==/  \/ //\/--             "
echo "\t\t" "                 ==/   /O   O\==--           "
echo "\t\t" "    _ _ _ _     /_/    \  ]  /--             "
echo "\t\t" "   /\ ( (- \    /       ] ] ]==-             "
echo "\t\t" "  (\ _\_\_\-\__/     \  (,_,)--  hwat?!      "
echo "\t\t" " (\_/                 \     \-               "
echo "\t\t" " \/      /       (   ( \  ] /)               "
echo "\t\t" " /      (         \   \_ \./ )               "
echo "\t\t" " (       \         \      )  \               " "\n"