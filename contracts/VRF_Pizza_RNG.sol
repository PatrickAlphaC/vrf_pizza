
pragma solidity 0.6.6;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {VRF_Pizza_Interface} from "../interfaces/VRF_Pizza_Interface.sol";

contract VRF_Pizza_RNG is VRFConsumerBase, Ownable {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    address public vrf_pizza_contract;
    address public vrfCoordinator;
    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     */
    constructor(bytes32 _keyhash, address _vrfCoordinator, address _linkToken) 
        VRFConsumerBase(
            _vrfCoordinator, // VRF Coordinator
            _linkToken  // LINK Token
        ) public
    {
        keyHash = _keyhash;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        vrfCoordinator = _vrfCoordinator;
    }

    function set_vrf_pizza_contract(address _vrf_pizza_address) public onlyOwner {
        vrf_pizza_contract = _vrf_pizza_address;
    }
    
    /** 
     * Requests randomness from a user-provided seed
     */
    function create_random_pizza(uint256 userProvidedSeed) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        require(msg.sender == vrfCoordinator, "Fulillment only permitted by Coordinator");
        randomResult = randomness;
        VRF_Pizza_Interface(vrf_pizza_contract).fulfil_random_pizza();
    }
}
