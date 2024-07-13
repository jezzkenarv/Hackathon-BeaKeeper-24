// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import {Test} from "forge-std/Test.sol";
import {ProposerBlockProof} from "src/BeaconProof.sol";
import {console} from "forge-std/console.sol";

contract Integration4788Test is Test {
    uint256 public HOLESKY_GENESIS_BLOCK = 1695902400;
    // same on holesky and mainnet
    address beaconRootsContract = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;
    ProposerBlockProof prover;

    function setUp() public {
        prover = new ProposerBlockProof(HOLESKY_GENESIS_BLOCK, beaconRootsContract);
    }

    // Helper function to get beacon block header from beacon node via ffi script
    function getBeaconBlockHeader(uint256 slot) internal returns (bytes memory) {
        string[] memory inputs = new string[](2);
        inputs[0] = "./shell-scripts/getBeaconBlockHeader.sh";
        inputs[1] = vm.toString(slot);
        return vm.ffi(inputs);
    }

    // same test but on real-time holesky eip-4788 data
    function testVerifyProposerProof() public {
        require(block.chainid == 17000, "Must be Holesky RPC");

        // Fetch a recent beacon block header (at least 1 less than the head)
        uint256 slot = prover.timeStampToSlot(block.timestamp) - 1; // get a recent slot
        string memory beaconBlockHeaderJSON = string(getBeaconBlockHeader(slot));

        // Parse beacon block header JSON
        bytes32 bodyRoot = vm.parseJsonBytes32(beaconBlockHeaderJSON, ".body_root");
        bytes32 parentRoot = vm.parseJsonBytes32(beaconBlockHeaderJSON, ".parent_root");
        bytes32 stateRoot = vm.parseJsonBytes32(beaconBlockHeaderJSON, ".state_root");
        uint256 proposerIndex = vm.parseJsonUint(beaconBlockHeaderJSON, ".proposer_index");

        // Generate the proof
        (
            bytes32 slotAndProposerIndexNode,
            bytes32 parentAndStateRootNode,
            bytes32 bodyAndZeroNode,
            bytes32 zeroesParentNode
        ) = prover.calculateProofNodes(uint64(slot), uint64(proposerIndex), parentRoot, stateRoot, bodyRoot);

        // Generate the block root
        bytes32 blockRoot = prover.calculateBlockRoot(
            slotAndProposerIndexNode, parentAndStateRootNode, bodyAndZeroNode, zeroesParentNode
        );

        // Get real block root from 4788 contract, note must use slot + 1 to fetch parent root from the child block
        (bool success, bytes32 beaconRootFromChain) = prover.getParentRootFromSlot(slot + 1);
        assertTrue(success, "4788 call failed");

        // Compare to the beacon root from chain
        bool isValid = prover.verifyRoot(blockRoot, beaconRootFromChain);
        assertTrue(isValid, "Root verification failed");
    }

    // same test but on real-time holesky eip-4788 data
    function testSaveProposerIndex() public {
       require(block.chainid == 17000, "Must be Holesky RPC");

        // Fetch a recent beacon block header (at least 1 less than the head)
        uint256 slot = prover.timeStampToSlot(block.timestamp) - 1; // get a recent slot
        string memory beaconBlockHeaderJSON = string(getBeaconBlockHeader(slot));

        // Parse beacon block header JSON
        bytes32 bodyRoot = vm.parseJsonBytes32(beaconBlockHeaderJSON, ".body_root");
        bytes32 parentRoot = vm.parseJsonBytes32(beaconBlockHeaderJSON, ".parent_root");
        bytes32 stateRoot = vm.parseJsonBytes32(beaconBlockHeaderJSON, ".state_root");
        uint256 proposerIndex = vm.parseJsonUint(beaconBlockHeaderJSON, ".proposer_index");

        prover.storeProposerIndex(uint64(slot), uint64(proposerIndex), parentRoot, stateRoot, bodyRoot);

        assertEq(prover.proposerIndexes(slot), proposerIndex);
        assertEq(prover.getProposerIndexAtTimestamp(block.timestamp - 12), proposerIndex);
    }
}
