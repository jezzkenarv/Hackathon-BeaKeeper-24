// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import {stdJson} from "forge-std/StdJson.sol";

contract ProposerBlockProof {

    function initializeData() public pure returns (
        bytes32 blockRoot,
        bytes32 bodyRoot,
        bytes32 parentRoot,
        bytes32 stateRoot,
        bytes32 proposerIndex,
        bytes32 slot,
        bytes32 zero
    ) {
        blockRoot = hex"f5377637c999e92ad5a1118023cac6e91a0fd9fd5a4ad2b1a1d3aa865f8bafd4";
        bodyRoot = hex"591213adb2ad0499dadaab30fa590c5bce833935b373536d0c110dea899f5292";
        parentRoot = hex"53bfaaf85da750e4e0d181dceaa0016675be001ae1430dd9ceb5e7ed1f4e2255";
        stateRoot = hex"4119938f7e4966b151a8cc733fd34063ead0aa2760839b9fe98ac2db4f290250";
        proposerIndex = bytes32(uint256(1613222));
        slot = bytes32(uint256(2066124));
        zero = bytes32(uint256(0));
    }

    function calculateProofNodes(
        bytes32 slot,
        bytes32 proposerIndex,
        bytes32 parentRoot,
        bytes32 stateRoot,
        bytes32 bodyRoot,
        bytes32 zero
    ) public pure returns (
        bytes32 slotAndProposerIndexNode,
        bytes32 parentAndStateRootNode,
        bytes32 bodyAndZeroNode,
        bytes32 zeroesParentNode
    ) {
        slotAndProposerIndexNode = keccak256(abi.encodePacked(slot, proposerIndex));
        parentAndStateRootNode = keccak256(abi.encodePacked(parentRoot, stateRoot));
        bodyAndZeroNode = keccak256(abi.encodePacked(bodyRoot, zero));
        zeroesParentNode = keccak256(abi.encodePacked(zero, zero));
    }

    function calculateFinalRoot(
        bytes32 slotAndProposerIndexNode,
        bytes32 parentAndStateRootNode,
        bytes32 bodyAndZeroNode,
        bytes32 zeroesParentNode
    ) public pure returns (bytes32 finalRoot) {
        bytes32 rightNode = keccak256(abi.encodePacked(slotAndProposerIndexNode, parentAndStateRootNode));
        bytes32 leftNode = keccak256(abi.encodePacked(bodyAndZeroNode, zeroesParentNode));
        finalRoot = keccak256(abi.encodePacked(rightNode, leftNode));
    }

    function verifyRoot(bytes32 finalRoot, bytes32 blockRoot) public pure returns (bool) {
        return finalRoot == blockRoot;
    }
}