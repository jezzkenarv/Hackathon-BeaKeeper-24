// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {ProposerBlockProof} from "src/BeaconProof.sol";
import {console} from "forge-std/console.sol";

contract MerkleProofTest is Test {
    ProposerBlockProof proof;
    uint256 HOLESKY_GENESIS_BLOCK = 1695902400;
    address beaconRootsContract = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    function setUp() public {
        proof = new ProposerBlockProof(HOLESKY_GENESIS_BLOCK, beaconRootsContract);
    }

    function testVerifyRoot() public {
        bytes32 blockRoot = hex"f5377637c999e92ad5a1118023cac6e91a0fd9fd5a4ad2b1a1d3aa865f8bafd4";
        bytes32 bodyRoot = hex"591213adb2ad0499dadaab30fa590c5bce833935b373536d0c110dea899f5292";
        bytes32 parentRoot = hex"53bfaaf85da750e4e0d181dceaa0016675be001ae1430dd9ceb5e7ed1f4e2255";
        bytes32 stateRoot = hex"4119938f7e4966b151a8cc733fd34063ead0aa2760839b9fe98ac2db4f290250";
        uint64 proposerIndex = 1613222;
        uint64 slot = 2066124;

        (
            bytes32 slotAndProposerIndexNode,
            bytes32 parentAndStateRootNode,
            bytes32 bodyAndZeroNode,
            bytes32 zeroesParentNode
        ) = proof.calculateProofNodes(slot, proposerIndex, parentRoot, stateRoot, bodyRoot);

        bytes32 finalRoot = proof.calculateFinalRoot(
            slotAndProposerIndexNode, parentAndStateRootNode, bodyAndZeroNode, zeroesParentNode
        );
        console.logBytes32(finalRoot);
        console.logBytes32(blockRoot);
        bool isValid = proof.verifyRoot(finalRoot, blockRoot);
        assertTrue(isValid, "Root verification failed");
    }

    // test to ensure the slot number is within the 8191 blocks

    // test that only verified block proofs are stored in the contract
}
