#!/bin/bash

# Add a page count of 100 and append a page argument
API_QUERY="https://api.github.com/search/repositories?q=+user:_USERNAME_&type=Repositories&ref=advsearch&l=&l=&per_page=100&page=_PAGE_"
echo "Repository Search API query template is '$API_QUERY'"
echo ""

# Where to store records returned as JSON Lines
OUTPUT_FILENAME='data/aws_repos.jsonl'
echo "Storing results to ${OUTPUT_FILENAME}"
echo ""

PAGE_SIZE=100

# Clean out the old file
if [ -f "${OUTPUT_FILENAME}" ];
then
    echo "Backing up '${OUTPUT_FILENAME}' ..."
    mv ${OUTPUT_FILENAME} "${OUTPUT_FILENAME}.bak"
fi
echo "Storing results to ${OUTPUT_FILENAME} ..."
echo ""

# Get the repositories for each username
TOTAL_RECORDS=0
while read USER; 
do
    QUERY_WITH_USER=${API_QUERY/_USERNAME_/${USER}}
    QUERY_WITH_PAGE=${QUERY_WITH_USER/_PAGE_/1}
    
    echo "Fetching ${USER} page 1 and total count ..."
    RESULT=$(curl -s "${QUERY_WITH_PAGE}" | jq -c "{total_count: .total_count, items: .items}")
    TOTAL_COUNT=$(echo ${RESULT} | jq ".total_count")
    PAGE_COUNT=$(((${PAGE_SIZE} - 1 + ${TOTAL_COUNT})/${PAGE_SIZE}))
    echo "Found ${TOTAL_COUNT} ${USER} repositories in ${PAGE_COUNT} pages ..."

    # Write first page of results
    echo ${RESULT} | jq -c ".items[]" >> ${OUTPUT_FILENAME}

    # Fetch the rest of the pages and write them as we go
    for ((i=2; i <= ${PAGE_COUNT} ; i++))
    do
        echo "Fetching ${USER} page ${i}..."
        QUERY_WITH_PAGE=${QUERY_WITH_USER/_PAGE_/${i}}
        curl -s "${QUERY_WITH_PAGE}" | jq -c ".items[]" >> ${OUTPUT_FILENAME}
    done

    echo ""

done < data/users.txt

RECORD_COUNT=$(wc -l ${OUTPUT_FILENAME} | cut -d ' ' -f5)
echo ""
echo "Done! There are ${RECORD_COUNT} JSON repository records, one per line, stored in ${OUTPUT_FILENAME}."
echo ""
