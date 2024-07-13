// SPDX-License-Identifier: GPL-3.0

// pragma solidity ^0.8.18;
pragma solidity >=0.8.0 <0.9.0;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ProposerBlockProof} from "src/BeaconProof.sol";

contract ProposerBlockProofScript is Script {
    ProposerBlockProof prover;
    address beaconRootsContract = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02; // same on holesky and mainnet

    function setUp() public {
        uint256 GENESIS_TIMESTAMP;

        if (block.chainid == 17000) {
            // holesky
            GENESIS_TIMESTAMP = 1634025600;
        } else if (block.chainid == 1) {
            // mainnet
            GENESIS_TIMESTAMP = 1634025600;
        } else {
            revert("Unsupported chainid");
        }
        prover = new ProposerBlockProof(GENESIS_TIMESTAMP, beaconRootsContract);
    }

    function run() public {
        (bool success, bytes32 root) = prover.getParentRootFromSlot(2083696);
        console.log(block.chainid); 
        console.log(success);
        console.logBytes32(root);

    }
}
