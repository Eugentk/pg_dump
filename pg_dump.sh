#!/bin/bash

set -e

# Set current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Import config file

source $DIR/pg_dump.conf

# Variables

CURRENT=$(date +"%Y-%m-%d-at-%H-%M-%S")

TIMESTAMP=`[ "$(uname)" = Linux ] && date +%s --date="-$DELETE_AFTER"`

# Split databases
IFS=',' read -ra DBS <<< "$PG_DATABASES"

# Delete old files
echo " * Backup creation started...";

# Loop thru databases

for db in "${DBS[@]}"; do
    FILENAME="$CURRENT"_"$db"

    echo "   -> backing up $db..."

    # Dump database
    pg_dump -h $PG_HOST -U $PG_USER -p $PG_PORT $db > /tmp/"$FILENAME".sql

    # Copy backup file to S3
    aws s3 cp /tmp/"$FILENAME".sql s3://$S3_PATH/"$FILENAME".sql --storage-class STANDARD_IA

    # Delete local file
    rm /tmp/"$FILENAME".sql

    # Log
    echo "      ...database $db has been backed up"
done

# Delete old files
echo " * Deleting old backup files...";

aws s3 ls s3://$S3_PATH/ | while read -r line;  do

    # Get file creation date
    createDate=`echo $line|awk {'print $1" "$2'}`
    createDate=`date -d"$createDate" +%s`

    if [[ $createDate -lt $TIMESTAMP ]]
    then
        # Get file name
        FILENAME=`echo $line|awk {'print $4'}`
        if [[ $FILENAME != "" ]]
          then
            echo "   -> Deleting $FILENAME"
            aws s3 rm s3://$S3_PATH/$FILENAME
        fi
    fi
done;

echo ""
echo "...Backup done!";
echo ""