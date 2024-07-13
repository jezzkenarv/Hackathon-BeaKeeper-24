// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract ProposerBlockProof {
    address beaconRootsContract;
    uint256 public GENESIS_TIMESTAMP;

    mapping(uint256 => uint256) public proposerIndexes;

    // make sure that the slot is within the last 8191 slots
    // fetch beacon block from beacon node

    constructor(uint256 _genesisTimestamp, address _beaconRootsContract) {
        GENESIS_TIMESTAMP = _genesisTimestamp;
        beaconRootsContract = _beaconRootsContract;
    }

    // clean up the beacon proof
    function calculateProofNodes(
        uint64 slot,
        uint64 proposerIndex,
        bytes32 parentRoot,
        bytes32 stateRoot,
        bytes32 bodyRoot
    )
        public
        pure
        returns (
            bytes32 slotAndProposerIndexNode,
            bytes32 parentAndStateRootNode,
            bytes32 bodyAndZeroNode,
            bytes32 zeroesParentNode
        )
    {
        bytes32 zero = bytes32(uint256(0));
        slotAndProposerIndexNode = sha256(
            abi.encodePacked(
                abi.encodePacked(_to_little_endian_64(uint64(slot)), bytes24(0)),
                abi.encodePacked(_to_little_endian_64(uint64(proposerIndex)), bytes24(0))
            )
        );
        parentAndStateRootNode = sha256(abi.encodePacked(parentRoot, stateRoot));
        bodyAndZeroNode = sha256(abi.encodePacked(bodyRoot, zero));
        zeroesParentNode = sha256(abi.encodePacked(zero, zero));
    }

    function calculateBlockRoot(
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

    // If proof is verified, store the block to a mapping so that users can access data
    function storeProposerIndex(
        uint256 slot,
        uint256 proposerIndex,
        bytes32 parentRoot,
        bytes32 stateRoot,
        bytes32 bodyRoot
    ) public {
        // Reconstruction of the block root
        (
            bytes32 slotAndProposerIndexNode,
            bytes32 parentAndStateRootNode,
            bytes32 bodyAndZeroNode,
            bytes32 zeroesParentNode
        ) = calculateProofNodes(uint64(slot), uint64(proposerIndex), parentRoot, stateRoot, bodyRoot);

        bytes32 blockRoot =
            calculateBlockRoot(slotAndProposerIndexNode, parentAndStateRootNode, bodyAndZeroNode, zeroesParentNode);

        // Fetch the on-chain block root, note must use slot + 1 to fetch parent root from the child block
        (bool success, bytes32 beaconRootFromChain) = getParentRootFromSlot(slot + 1);
        require(success);
        assert(verifyRoot(blockRoot, beaconRootFromChain));

        // If we made it here, it means the proposerIndex corresponded to this slot
        proposerIndexes[slot] = proposerIndex;
    }

    function getProposerIndexAtTimestamp(
        uint256 timestamp
    ) public returns (uint256) {
        uint256 slot = timeStampToSlot(timestamp);
        return proposerIndexes[slot];
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

    function getParentRootFromTimestamp(uint256 timestamp) public returns (bool, bytes32) {
        (bool ret, bytes memory data) = address(beaconRootsContract).call(bytes.concat(bytes32(timestamp)));
        return (ret, bytes32(data));
    }

    function slotToTimestamp(uint256 slot) public view returns (uint256) {
        return slot * 12 + GENESIS_TIMESTAMP;
    }

    function getParentRootFromSlot(uint256 slot) public returns (bool, bytes32) {
        uint256 timestamp = slotToTimestamp(slot);
        return getParentRootFromTimestamp(timestamp);
    }

    function timeStampToSlot(uint256 timestamp) public view returns (uint256) {
        return (timestamp - GENESIS_TIMESTAMP) / 12;
    }
}
