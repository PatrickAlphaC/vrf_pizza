pragma solidity ^0.6.6;

interface VRF_Pizza_Interface {
    function fulfil_random_pizza(uint256 randomNumber) external;
}
