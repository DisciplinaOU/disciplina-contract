// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "solidity-cborutils/contracts/CBOR.sol";

contract Disciplina {
    using CBOR for CBOR.CBORBuffer;

    mapping (address => bytes32) public prevHashCur;
    mapping (address => bytes32) public merkleRootCur;
    mapping (address => uint64) public sizes;

    event NewChain(address sender, bytes32 genesisHash, bytes32 merkleRoot, uint64 size);
    event NewHeader(address sender, bytes32 prevHash, bytes32 merkleRoot, uint64 size);

    function startChain(bytes32 genesisHash, bytes32 merkleRoot, uint64 size) external {
        require(prevHashCur[msg.sender] == 0x0, "Chain exists");
        require(genesisHash == addressHashCBOR(msg.sender), "Wrong genesis hash");

        prevHashCur[msg.sender] = genesisHash;
        merkleRootCur[msg.sender] = merkleRoot;
        sizes[msg.sender] = size;
        emit NewChain(msg.sender, genesisHash, merkleRoot, size);
    }

    function submitHeader(bytes32 prevHash, bytes32 merkleRoot, uint64 size) external {
        require(
            prevHash == privateHeaderHash(
                prevHashCur[msg.sender], merkleRootCur[msg.sender], sizes[msg.sender]),
            "Wrong hash"
        );
        prevHashCur[msg.sender] = prevHash;
        merkleRootCur[msg.sender] = merkleRoot;
        sizes[msg.sender] = size;
        emit NewHeader(msg.sender, prevHash, merkleRoot, size);
    }

    function constructPrivateHeader(bytes32 prevHash, bytes32 merkleRoot, uint64 size) public pure returns(bytes memory) {
        CBOR.CBORBuffer memory buf = CBOR.create(128);

        buf.startFixedArray(3);
        buf.writeUInt64(0);
        buf.writeBytes(abi.encodePacked(prevHash));
        buf.writeUInt64(1043); // Custom tag: denotes the start of MerkleSignature(size, root)
        buf.writeUInt64(size);
        buf.writeBytes(abi.encodePacked(merkleRoot));

        return buf.data();
    }

    function privateHeaderHash(bytes32 prevHash, bytes32 merkleRoot, uint64 size) public pure returns(bytes32) {
        return keccak256(constructPrivateHeader(prevHash, merkleRoot, size));
    }

    function addressHashCBOR(address addr) public pure returns(bytes32) {
        CBOR.CBORBuffer memory buf = CBOR.create(32);

        buf.writeBytes(abi.encodePacked(addr));
        return keccak256(buf.data());
    }
}