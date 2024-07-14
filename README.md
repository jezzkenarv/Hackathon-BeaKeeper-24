## BeaKeeper 

### Description

BeaKeeper is a smart contract designed for efficient storage and verification of beacon state proofs. As Ethereum's EIP-4788 retains data for only the last 8191 blocks, BeaKeeper allows users to access this information seamlessly without needing to verify or submit their own proofs, thus streamlining data access and preserving historical state.

### Features

- Proves and stores beacon state proofs
- Access historical data beyond the 8191-block limitation of EIP-4788
- Efficient data retrieval and proof verification

### Contracts Overview
#### ProposerBlockProof Contract
The core contract responsible for storing and verifying beacon block proposer data. It interacts with the beacon root contract to fetch and verify block roots, ensuring the integrity of the stored data.
#### MerkleProofTest Contract
Used to test calculation and verification of Merkle proofs.
#### Mock4788 Contract
A mock implementation of the EIP-4788 beacon root contract. It simulates the behavior of the actual beacon root contract by storing predefined parent roots for testing purposes
#### Mock4788Test Contract
Used the Mock4788 contract to ensure it correctly simulates the behavior of the EIP-4788 beacon root contract. It includes tests for fetching parent roots and verifying proposer proofs using mock data.
#### Integration4788Test Contract
Tests the integration of the ProposerBlockProof contract with the actual EIP-4788 beacon root contract. It includes tests for real-time verification of proposer proofs and storage of proposer indexes.
#### ProposerBlockProofScript Contract
A script used to set up and run the ProposerBlockProof contract in different environments. It handles the initialization and configuration of the contract based on the network being used.


### Usage
1. Set the required environment variables:

`export BEACON_NODE_URL=<YOUR_BEACON_NODE_URL>`

`export RPC_URL=<YOUR_RPC_URL>`

2.  Run the tests using Foundry:

`forge test --rpc-url $RPC_URL --ffi --evm-version cancun`
> **Note:** Need to configure forge test using the Cancun EVM version to use EIP-4788

### Future Work
**1. Enhanced Automation**
- Integrate with an automation feature to further streamline the data archival process.

**2. Scalability Improvements**
- Optimize the smart contracts and data structures to handle larger volumes of data more efficiently
  
**3. User Interface**
- Develop a user-friendly interface for interacting with the smart contracts, making it easier for non-technical users to access and verify historical beacon chain data

**4. Extended Beacon Chain Data**
- What I did for the hackathon is just proving and storing block proposer data, but this can easily be extended to anything related to the beacon chain

### Documentation
For more detailed information on the beacon chain and related APIs, please refer to the following resources:

1. [Ethereum Consensus Specs - Beacon Chain](https://github.com/ethereum/consensus-specs/blob/dev/specs/phase0/beacon-chain.md#beaconblock): This document provides comprehensive details on the beacon chain, including the structure of the `BeaconBlock`.

2. [Ethereum Beacon APIs - Get Block Header](https://ethereum.github.io/beacon-APIs/#/Beacon/getBlockHeader): This API documentation explains how to retrieve the header of a beacon block using the beacon node API.

### License
This project is licensed under the GPL-3.0 License



