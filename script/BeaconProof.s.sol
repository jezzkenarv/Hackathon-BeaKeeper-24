// // SPDX-License-Identifier: GPL-3.0

// pragma solidity ^0.8.18;

// import {stdJson} from "forge-std/StdJson.sol";
// import {Script} from "forge-std/Script.sol";
// import {ProposerBlockProof} from "src/BeaconProof.sol";

// contract ProposerBlockProofScript is Script {
//     ProposerBlockProof prover;

//     function setUp() public {
//         uint256 GENESIS_TIMESTAMP;

//         if (block.chainid == 17000) {
//             // holesky
//             GENESIS_TIMESTAMP = 1634025600;
//         } else if (block.chainid == 1) {
//             // mainnet
//             GENESIS_TIMESTAMP = 1634025600;
//         } else {
//             revert("Unsupported chainid");
//         }
//         prover = new ProposerBlockProof(GENESIS_TIMESTAMP);
//     }
// }
