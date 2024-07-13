// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import {stdJson} from "forge-std/StdJson.sol";

contract ProposerBlockProof {

    function calculateProofNodes(
        uint64 slot,
        uint64 proposerIndex,
        bytes32 parentRoot,
        bytes32 stateRoot,
        bytes32 bodyRoot
    ) public pure returns (
        bytes32 slotAndProposerIndexNode,
        bytes32 parentAndStateRootNode,
        bytes32 bodyAndZeroNode,
        bytes32 zeroesParentNode
    ) {
        bytes32 zero = bytes32(uint256(0));
        slotAndProposerIndexNode = sha256(abi.encodePacked(abi.encodePacked(_to_little_endian_64(uint64(slot)), bytes24(0)), abi.encodePacked(_to_little_endian_64(uint64(proposerIndex)), bytes24(0))));
        parentAndStateRootNode = sha256(abi.encodePacked(parentRoot, stateRoot));
        bodyAndZeroNode = sha256(abi.encodePacked(bodyRoot, zero));
        zeroesParentNode = sha256(abi.encodePacked(zero, zero));
    }

    function calculateFinalRoot(
        bytes32 slotAndProposerIndexNode,
        bytes32 parentAndStateRootNode,
        bytes32 bodyAndZeroNode,
        bytes32 zeroesParentNode
    ) public pure returns (bytes32 finalRoot) {
        bytes32 rightNode = sha256(abi.encodePacked(slotAndProposerIndexNode, parentAndStateRootNode));
        bytes32 leftNode = sha256(abi.encodePacked(bodyAndZeroNode, zeroesParentNode));
        finalRoot = sha256(abi.encodePacked(rightNode, leftNode));
    }

    function verifyRoot(bytes32 finalRoot, bytes32 blockRoot) public pure returns (bool) {
        return finalRoot == blockRoot;
    }

// source from beacon deposit contract 
    function _to_little_endian_64(uint64 value) internal pure returns (bytes memory ret) {
        ret = new bytes(8);
        bytes8 bytesValue = bytes8(value);
        // Byteswapping during copying to bytes.
        ret[0] = bytesValue[7];
        ret[1] = bytesValue[6];
        ret[2] = bytesValue[5];
        ret[3] = bytesValue[4];
        ret[4] = bytesValue[3];
        ret[5] = bytesValue[2];
        ret[6] = bytesValue[1];
        ret[7] = bytesValue[0];
}
}