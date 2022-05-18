// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.11;

// import "@openzeppelin/contracts/proxy/Clones.sol";
// import "./PrivateLottery.sol";

// contract FactoryAirdrop {
//     // Private lottery contract template
//     address[] public AirdropContractAddresses;  
//     address public proxyContract;
//     address public verifierContract;

//     using Clones for address;

//     // Constructor for implementation contracts
//     constructor(address _proxyContract, address _verifierContract) {
//         proxyContract = _proxyContract;
//         verifierContract = _verifierContract;
//     }

//     // Create private lottery contract
//     function createLottery (
//         IERC20 _airdrop,
//         uint _amount,
//         IPlonkVerifier _verifier,
//         bytes32 _root,
//         bytes32[] memory _commitments
//     ) external payable returns (address lotteryContract) {
//         lotteryContract = Clones.clone(proxyContract);
//         PrivateLottery(lotteryContract).initialize(
//             _airdrop, 
//             _amount, 
//             _verifier,
//             _root,
//             _commitments
//         );
//         AirdropContractAddresses.push(lotteryContract);
//     }
// }

