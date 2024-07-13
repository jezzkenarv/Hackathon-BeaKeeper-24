// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {ProposerBlockProof} from "src/BeaconProof.sol";
import {console} from "forge-std/console.sol";



contract 4788Test is Test {

    uint256 public HOLESKY_GENESIS_BLOCK = 1695902400;
    Mock4788 public beaconRootsContract;
    address beaconRootsContractAddr;

    function setUp() public {
        beaconRootsContract = new Mock4788(HOLESKY_GENESIS_BLOCK);
        beaconRootsContractAddr = address(beaconRootsContract);
    }

    function testFetchChildRoot() public {
        uint256 timestamp = HOLESKY_GENESIS_BLOCK;
        (bool success, bytes memory parentRoot) = beaconRootsContractAddr.call(
            bytes.concat(bytes32(timestamp))
        );
        assert(success);
        assertEq(parentRoot, hex"721c09025a9842ed2b17663fa256fa662adf00021f5e9e73c98164ce56ab1f5e");
    }

    function testFetchParentRoot() public {
        uint256 timestamp = HOLESKY_GENESIS_BLOCK + 12;
        (bool success, bytes memory parentRoot) = beaconRootsContractAddr.call(
            bytes.concat(bytes32(timestamp))
        );
        assert(success);
        assertEq(parentRoot, hex"44724d6135eae996ecbf722688d33f5d8bd5b60c7c34f8f22c35a3582ca1e553");
    }

    function testFoo() public {
        ProposerBlockProof prover = new ProposerBlockProof(HOLESKY_GENESIS_BLOCK, beaconRootsContractAddr);

        uint256 timestamp = HOLESKY_GENESIS_BLOCK + 12;
        (bool success, bytes32 parentRoot) = prover.getRootFromTimestamp(timestamp);
        assert(success);
        assertEq(parentRoot, hex"44724d6135eae996ecbf722688d33f5d8bd5b60c7c34f8f22c35a3582ca1e553");
    }

    // function testFoo() public {
    //     ProposerBlockProof prover = new ProposerBlockProof(HOLESKY_GENESIS_BLOCK, beaconRootsContractAddr);

    //     uint256 timestamp = HOLESKY_GENESIS_BLOCK + 12;
    //     (bool success, bytes32 parentRoot) = prover.getRootFromTimestamp(timestamp);
    //     assert(success);
    //     assertEq(parentRoot, hex"44724d6135eae996ecbf722688d33f5d8bd5b60c7c34f8f22c35a3582ca1e553");
    // }

    function testVerifyProposerProof() public {
        ProposerBlockProof prover = new ProposerBlockProof(HOLESKY_GENESIS_BLOCK, beaconRootsContractAddr);
        bytes32 bodyRoot = hex"43edde79a9551e4a9ee5c95bcdacb929ddeb587d1b34851b709808ba968852cb";
        bytes32 parentRoot = hex"721c09025a9842ed2b17663fa256fa662adf00021f5e9e73c98164ce56ab1f5e";
        bytes32 stateRoot = hex"71a3692f7266b7c71d102af85145fc36d58c97b1d740771eb08e0649da1d2a7a";
        uint64 proposerIndex = 162833;
        uint64 slot = 2080878;

        (
            bytes32 slotAndProposerIndexNode,
            bytes32 parentAndStateRootNode,
            bytes32 bodyAndZeroNode,
            bytes32 zeroesParentNode
        ) = prover.calculateProofNodes(slot, proposerIndex, parentRoot, stateRoot, bodyRoot);

        bytes32 finalRoot = prover.calculateFinalRoot(
            slotAndProposerIndexNode, parentAndStateRootNode, bodyAndZeroNode, zeroesParentNode
        );

// get real block root from 4788

        uint256 timestamp = HOLESKY_GENESIS_BLOCK;
        (bool success, bytes32 blockRoot) = prover.getRootFromTimestamp(timestamp + 12);
        assert(success);

        bool isValid = prover.verifyRoot(finalRoot, blockRoot);
        assertTrue(isValid, "Root verification failed");
    }

}