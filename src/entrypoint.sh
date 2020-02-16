#!/bin/sh

main() {
echo "Starting... \n"
echo "$(mongo --version) \n"

validateInptus $MONGO_ADDRESS

configureEnvironment

wiatForServerToBecomeHealthy

echo ENVIRONMENT:
echo "\t" MONGO_ADDRESS: $MONGO_ADDRESS
echo "\t" RECREATE_COLLECTIONS: $RECREATE_COLLECTIONS "\n\n"
echo INFO: Current folder: "$PWD"

find ./imports/* -type d | while read filename;
do
	DATABASE_NAME="$(basename "$filename")"
	processDatabase $DATABASE_NAME $MONGO_ADDRESS

	cd imports/$DATABASE_NAME
	echo INFO: Moved into folder: $PWD

	find ./* -type f | while read filename;
	do
		COLLECTION_NAME="$(basename "$filename" .json)"
		FILE_NAME="$(basename "$filename")"

		processCollection $MONGO_ADDRESS $DATABASE_NAME $COLLECTION_NAME $RECREATE_COLLECTIONS

		echo INFO: Starting import on host: $MONGO_ADDRESS for database/collection: $DATABASE_NAME/$COLLECTION_NAME "\n"
		mongoimport --host $MONGO_ADDRESS --db $DATABASE_NAME --collection $COLLECTION_NAME --type json --file $FILE_NAME --jsonArray -v

		echo INFO: Finished import on host: $MONGO_ADDRESS for database/collection: $DATABASE_NAME/$COLLECTION_NAME "\n"
	done;

	cd ..
	cd ..

	echo INFO: Moved back to root folder: "$(basename "$PWD")"

done;

	drawUnicorn
}

validateInptus() {
	if [ -z "$1" ];
	then
		echo "$1 variable is not set"
		exit 1
	fi;
}

configureEnvironment() {
	if [ -z "$RECREATE_COLLECTIONS" ];
	then
		echo RECREATE_COLLECTIONS variable is not set and it will have default value: false
		echo Collections will not be re-created

		RECREATE_COLLECTIONS="false"
	else
		RECREATE_COLLECTIONS="$(echo $RECREATE_COLLECTIONS | tr [:upper:] [:lower:])"

		if [ "$RECREATE_COLLECTIONS" != "false" ] && [ "$RECREATE_COLLECTIONS" != "true" ]; then
			RECREATE_COLLECTIONS="false"
		fi;

		echo WARNING:
		echo "\t" Collections with matching names will be re-created
		echo "\t" If you do not want this option set RECREATE_COLLECTIONS environment variable to '"false"' "\n\n"
	fi;
}

wiatForServerToBecomeHealthy() {

	HEALTHY=0;
	COUNTER=0;

	echo "HEALTHY: $HEALTHY and COUNTER: $COUNTER";

	while [ $HEALTHY = 0 ] && [ $COUNTER -lt 5 ]
	do

		if [ $COUNTER -gt 0 ];
		then
			sleep 5
		fi;

		COUNTER=$(($COUNTER + 1));

		echo "Starting health check. Try number: $COUNTER"
		RESULT=$(echo 'db.stats().ok' | mongo $MONGO_ADDRESS --quiet)

		if [ "$RESULT" = "1" ];
		then
			HEALTHY=1
		else
			echo "Health check failed with error: \n $RESULT \n"
		fi;

		echo "Finished health check. Server: $MONGO_ADDRESS is healthy: $HEALTHY \n"
	done;

	if [ $HEALTHY != "1" ];
	then
		exit 1;
	fi;
};

processDatabase() {
	DATABASE_INDEX="$(echo "db.getMongo().getDBNames().indexOf('$1')" | mongo "$2" --quiet)"

	if [ "$DATABASE_INDEX" != "-1" ]
	then
	  echo INFO: Database: $1 exists
	else
	  echo INFO: Database: $1 does not exists
	fi;
}

processCollection() {
	COLLECTION_EXISTS="$(mongo $1/$2 --eval "printjson(db.getCollectionInfos( { name: '$3' } ))" --quiet)"
	COLLECTION_EMPTY="[ ]"

	if [ "$4" = "true" ] && [ "$COLLECTION_EXISTS" != "$COLLECTION_EMPTY" ];
	then
		echo INFO: Removing collection: $3

		DROP_CMD="db.$3.drop()"
		RESULT="$(mongo $1/$2 --eval "printjson($DROP_CMD)" --quiet)"
		RESULT="$(echo $RESULT | tr [:upper:] [:lower:])"

		if [ "$RESULT" = "true" ];
		then
			echo INFO: Finished removing collection: $3
		else
			echo ERROR: Removing collection: $3 failed
			echo ERROR: Reason: $RESULT
			exit 1
		fi;
	else
	  echo INFO: Collection: $3 does not exist
	fi;
}

drawUnicorn() {
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
}

main