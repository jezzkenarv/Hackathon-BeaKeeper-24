#!/bin/bash
# The script gathers specific pieces of data from an API response or another source
# The collected data is formatted into a JSON object using 'jq'


# Check if BEACON_NODE_URL is set
if [ -z "$BEACON_NODE_URL" ]; then
  echo "Error: BEACON_NODE_URL env var is not set"
  exit 1
fi

# Set SLOT as the first script argument, default to "head" if not provided
SLOT=${1:-head}

# Fetch the beacon header information
# https://ethereum.github.io/beacon-APIs/#/Beacon/getBlockHeader
resp=$(curl -s -X 'GET' "$BEACON_NODE_URL/eth/v1/beacon/headers/$SLOT" -H 'accept: application/json')

# Parse the response using jq
# parsing responses is crucial for data extraction and conversion from raw JSON data to structured, usable varaiables within smart contracts 

# '-r' outputs raw strings, not JSON-encoded strings
# '.data.root' extracts the 'root' field from the 'data' object
# '.data.header.message.proposer_index' extracts the 'proposer_index' field from the nested 'data.header.message' object
# vm.parseJsonBytes32 and vm.parseJsonUint functions are used to parse JSON strings and convert them to Solidity types

# Extracts specific fields (root, proposer_index, parent_root, state_root, body_root, slot) from the JSON response and assigns them to variables
root=$(echo $resp | jq -r '.data.root')
proposer_index=$(echo $resp | jq -r '.data.header.message.proposer_index')
parent_root=$(echo $resp | jq -r '.data.header.message.parent_root')
state_root=$(echo $resp | jq -r '.data.header.message.state_root')
body_root=$(echo $resp | jq -r '.data.header.message.body_root')
slot=$(echo $resp | jq -r '.data.header.message.slot')

# Create a JSON response
# involves formatting data into a JSON structure (format that is easy to read and write for humans and easy to parse and generate for machines)
# commonly used in web APIs to send data from a server to a client
json_response=$(jq -nc --arg root "$root" --arg proposer_index "$proposer_index" --arg parent_root "$parent_root" --arg state_root "$state_root" --arg body_root "$body_root" --arg slot "$slot" '{
  block_root: $root,
  body_root: $body_root,
  parent_root: $parent_root,
  proposer_index: $proposer_index,
  state_root: $state_root,
  slot: $slot
}')

# Output the JSON response
echo $json_response
