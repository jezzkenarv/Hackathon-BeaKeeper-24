// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.18;

// {"block_root":"0x44724d6135eae996ecbf722688d33f5d8bd5b60c7c34f8f22c35a3582ca1e553","body_root":"0x43edde79a9551e4a9ee5c95bcdacb929ddeb587d1b34851b709808ba968852cb","parent_root":"0x721c09025a9842ed2b17663fa256fa662adf00021f5e9e73c98164ce56ab1f5e","proposer_index":"162833","state_root":"0x71a3692f7266b7c71d102af85145fc36d58c97b1d740771eb08e0649da1d2a7a","slot":"2080878"}

// {"block_root":"0x835ad7967dd6a962abec2f79ca5ad99ae666a4214040cceca49c9752f26e86fa","body_root":"0x516f0c39af8a8ae04f5d577d3fb627209fc832cb909b9c5d66fa1af938b9d9e9","parent_root":"0x44724d6135eae996ecbf722688d33f5d8bd5b60c7c34f8f22c35a3582ca1e553","proposer_index":"881149","state_root":"0xecb58eb59448e2ee330829326d95771a157e8f26505fac298bf3b7e1cbabbbef","slot":"2080879"}

import {Test} from "forge-std/Test.sol";
import {ProposerBlockProof} from "src/BeaconProof.sol";
import {console} from "forge-std/console.sol";

contract Mock4788 {
    mapping(bytes => bytes) public parentRoots;

    constructor(uint256 startTimeStamp) {
        parentRoots[bytes.concat(bytes32(startTimeStamp))] =
            hex"721c09025a9842ed2b17663fa256fa662adf00021f5e9e73c98164ce56ab1f5e";
        parentRoots[bytes.concat(bytes32(uint256(startTimeStamp + 12)))] =
            hex"44724d6135eae996ecbf722688d33f5d8bd5b60c7c34f8f22c35a3582ca1e553";
    }

    fallback(bytes calldata timestamp) external returns (bytes memory) {
        return parentRoots[timestamp];
    }
}

contract Mock4788Test is Test {
    uint256 public HOLESKY_GENESIS_BLOCK = 1695902400;
    Mock4788 public beaconRootsContract;
    address beaconRootsContractAddr;

    // Initializes the Mock4788 contract with the Holesky genesis block timestamp
    // Deploys the Mock4788 contract and stores the address in beaconRootsContractAddr
    function setUp() public {
        beaconRootsContract = new Mock4788(HOLESKY_GENESIS_BLOCK);
        beaconRootsContractAddr = address(beaconRootsContract);
    }

    // Tests fetching the parent root for the genesis block timestamp
    function testFetchParentRootSlot0() public {
        uint256 timestamp = HOLESKY_GENESIS_BLOCK;
        (bool success, bytes memory parentRoot) = beaconRootsContractAddr.call(bytes.concat(bytes32(timestamp)));
        assert(success);
        assertEq(parentRoot, hex"721c09025a9842ed2b17663fa256fa662adf00021f5e9e73c98164ce56ab1f5e");
    }

    // Tests fetching the parent root for the genesis block timestamp (timestamp + 12)
    function testFetchParentRootSlot1() public {
        uint256 timestamp = HOLESKY_GENESIS_BLOCK + 12;
        (bool success, bytes memory parentRoot) = beaconRootsContractAddr.call(bytes.concat(bytes32(timestamp)));
        assert(success);
        assertEq(parentRoot, hex"44724d6135eae996ecbf722688d33f5d8bd5b60c7c34f8f22c35a3582ca1e553");
    }

    function testFetchParentRootSlot0UsingProposerBlockProof() public {
        ProposerBlockProof prover = new ProposerBlockProof(HOLESKY_GENESIS_BLOCK, beaconRootsContractAddr);

        uint256 timestamp = HOLESKY_GENESIS_BLOCK;
        (bool success, bytes32 parentRoot) = prover.getParentRootFromTimestamp(timestamp);
        assert(success);
        assertEq(parentRoot, hex"721c09025a9842ed2b17663fa256fa662adf00021f5e9e73c98164ce56ab1f5e");
    }

    // Tests fetching a parent root using the ProposerBlockProof contract.
    function testFetchParentRootSlot1UsingProposerBlockProof() public {
        ProposerBlockProof prover = new ProposerBlockProof(HOLESKY_GENESIS_BLOCK, beaconRootsContractAddr);

        uint256 timestamp = HOLESKY_GENESIS_BLOCK + 12;
        (bool success, bytes32 parentRoot) = prover.getParentRootFromTimestamp(timestamp);
        assert(success);
        assertEq(parentRoot, hex"44724d6135eae996ecbf722688d33f5d8bd5b60c7c34f8f22c35a3582ca1e553");
    }

    function testVerifyHardCodedProposerProof() public {
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

        bytes32 finalRoot = prover.calculateBlockRoot(
            slotAndProposerIndexNode, parentAndStateRootNode, bodyAndZeroNode, zeroesParentNode
        );

        // get real block root from 4788

        uint256 timestamp = HOLESKY_GENESIS_BLOCK;
        (bool success, bytes32 blockRoot) = prover.getParentRootFromTimestamp(timestamp + 12);
        assert(success);

        bool isValid = prover.verifyRoot(finalRoot, blockRoot);
        assertTrue(isValid, "Root verification failed");
    }
}
