// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.18;

import {console, Test} from "forge-std/Test.sol";
import {ProposerBlockProof } from "src/BeaconProof.sol";

contract ProposerBlockProofTest is Test {
    ProposerBlockProof proof;

    function setUp() public {
        proof = new ProposerBlockProof();
    }

    function testVerifyRoot() public {
        (
            bytes32 blockRoot,
            bytes32 bodyRoot,
            bytes32 parentRoot,
            bytes32 stateRoot,
            bytes32 proposerIndex,
            bytes32 slot,
            bytes32 zero
        ) = proof.initializeData();

        (
            bytes32 slotAndProposerIndexNode,
            bytes32 parentAndStateRootNode,
            bytes32 bodyAndZeroNode,
            bytes32 zeroesParentNode
        ) = proof.calculateProofNodes(slot, proposerIndex, parentRoot, stateRoot, bodyRoot, zero);

        bytes32 finalRoot = proof.calculateFinalRoot(
            slotAndProposerIndexNode, parentAndStateRootNode, bodyAndZeroNode, zeroesParentNode
        );

        bool isValid = proof.verifyRoot(finalRoot, blockRoot);
        assertTrue(isValid, "Root verification failed");
    }
}
     
