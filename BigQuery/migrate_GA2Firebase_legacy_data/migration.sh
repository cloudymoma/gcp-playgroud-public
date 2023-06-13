#!/bin/bash -ex

# Analytics Property ID for the Project. Find this in Analytics Settings in Firebase
PROPERTY_ID=your Analytics property ID

# Bigquery Export Project
BQ_PROJECT_ID="your BigQuery Project ID" (e.g., "firebase-public-project")

# Firebase App ID for the app.
FIREBASE_APP_ID="your Firebase App ID" (e.g., "1:300830567303:ios:09b1ab1d3ca29bda")

# Dataset to import from.
BQ_DATASET="name of BigQuery dataset you want to import from" (e.g., "com_firebase_demo_IOS")

# Platform
PLATFORM="platform of the app. ANDROID or IOS"

# Date range for which you want to run migration, [START_DATE,END_DATE] inclusive.
START_DATE=20180324
END_DATE=20180327

# Do not modify the script below, unless you know what you are doing :)
startdate=$(date -d"$START_DATE"  +%Y%m%d) || exit -1
enddate=$(date -d"$END_DATE"  +%Y%m%d) || exit -1

# Iterate through the dates.
DATE="$startdate"
while [ "$DATE" -le "$enddate" ]; do

        # BQ table constructed from above params.
        BQ_TABLE="$BQ_PROJECT_ID.$BQ_DATASET.app_events_$DATE"

        echo "Migrating $BQ_TABLE"

        cat migration_script.sql | sed -e "s/SCRIPT_GENERATED_TABLE_NAME/$BQ_TABLE/g" | bq query \
        --debug_mode \
        --allow_large_results \
        --noflatten_results \
        --use_legacy_sql=False \
        --destination_table analytics_$PROPERTY_ID.events_$DATE \
        --batch \
        --append_table \
        --parameter=firebase_app_id::$FIREBASE_APP_ID \
        --parameter=date::$DATE \
        --parameter=platform::$PLATFORM \
        --project_id=$BQ_PROJECT_ID


        temp=$(date -I -d "$DATE + 1 day")
        DATE=$(date -d "$temp" +%Y%m%d)

done
exit

# END OF SCRIPT