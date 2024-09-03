// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MerkleAirdrop {
    bytes32 public merkleRoot;
    address token;
    address owner;

    constructor(address _tokenAddress, bytes32 _merkleRoot) {
        token = _tokenAddress;
        merkleRoot = _merkleRoot;
        owner == msg.sender; 
    }

    mapping(address => bool) public hasClaimed; 
    event AirdropClaimed(address indexed claimer, uint256 amount); 

  
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }


    function claim(uint256 _amount, bytes32[] calldata proof) public {
        require(!hasClaimed[msg.sender], "Already Claimed");

        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(msg.sender, _amount)))
        );

        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");

        IERC20(token).transfer(msg.sender, _amount);
        emit AirdropClaimed(msg.sender, _amount);
    }


    function updateRoot(bytes32 newMerkleRoot) external onlyOwner {
        merkleRoot = newMerkleRoot;
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        require(IERC20(token).transfer(msg.sender, amount), "Withdraw failed.");
    }
}
