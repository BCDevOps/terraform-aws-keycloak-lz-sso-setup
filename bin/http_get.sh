#!/bin/sh

#adapted from example at https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/data_source

# Exit if any of the intermediate steps fail
set -e

# Extract "foo" and "baz" arguments from the input into
# FOO and BAZ shell variables.
# jq will ensure that the values are properly quoted
# and escaped for consumption by the shell.
#eval "$(jq -r `@sh "URL=\(.url)"`)"

#extract value for URL from json on stdin (sed bit strips leading and trailing quotes...eww..there's probably a nicer way.)
URL=$(jq .url <&0 | sed -e 's/^"//' -e 's/"$//')

# Fetch the contents from $URL and assign to DATA variable
DATA=$(curl -s  $URL)

# Safely produce a JSON object containing the content from the URL.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg data "$DATA" '{"data":$data}'
