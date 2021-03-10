
pragma solidity 0.6.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/math/SafeMath.sol';

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import {VRF_Pizza_RNG_Interface} from "../interfaces/VRF_Pizza_RNG_Interface.sol";


contract VRF_Pizza is ChainlinkClient, Ownable{
    using SafeMath for uint256;
    uint256 public PIZZA_PRICE_USD;
    address public MATIC_USD_ADDRESS;
    AggregatorV3Interface internal MATIC_TO_USD_PRICE_FEED;
    uint256 internal fee;
    address private oracle;
    bytes32 private pizza_jobId;
    string public pizza_response;
    address public pizza_rng_address;
    
    // matic mainnet LINK 0xb0897686c545045afc77cf20ec7a532e3120e0f1
    // matic testnet LINK 0x326C977E6efc84E512bB9C30f76E30c160eD06FB

    // matic mainnet MATIC/USD 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0
    // matic testnet MATIC/USD 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
    constructor(address _link, address _MaticToUSD, address _oracle, bytes32 jobid)
    public  {
        if (_link == address(0)) {
            setPublicChainlinkToken();
        } else {
            setChainlinkToken(_link);
        }
        PIZZA_PRICE_USD = 50;
        MATIC_USD_ADDRESS = _MaticToUSD;
        MATIC_TO_USD_PRICE_FEED = AggregatorV3Interface(MATIC_USD_ADDRESS);
        // matic testnet VRF details
        // coordinator 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255
        // keyhash 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4
        // fee 0.0001 LINK
        fee = 0.0001 * 10 ** 18; // 0.0001 LINK

        // mainnet ??
        // oracle: ??
        // jobid: ??

        // testnet 
        // oracle: 0xBf87377162512f8098f78f055DFD2aDAc34cbB47
        // jobid: ??
        oracle = _oracle;
        pizza_jobId = jobid;

        // matic mainnet vrf details
        // VRF Coordinator: 0x3d2341ADb2D31f1c5530cDC622016af293177AE0
        // LINK: 0xb0897686c545045aFc77CF20eC7A532E3120E0F1
        // KeyHash: 0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da
        // Fee: 100000000000000 (0.0001 LINK)
    }

    function order_pizza(uint256 userProvidedSeed) public payable is_paid {
        // validate_order(msg.value);
        VRF_Pizza_RNG_Interface(pizza_rng_address).create_random_pizza(userProvidedSeed);
    }

    function set_pizza_rng_address(address _pizza_rng_address) public onlyOwner{
        pizza_rng_address = _pizza_rng_address;
    }

    // function validate_order(uint256 value) public view {
    //     // they need to send a value with this tx
    //     uint256 precision = 1 * 10 ** 22;
    //     uint256 price = uint(getLatestPizzaPriceInMATIC());
    //     // address(link).transferFrom(msg.sender, address(this), price);
    //     uint256 cost_per_pizza_in_matic = (precision / price) * PIZZA_PRICE_USD;
    //     require((value * precision) > cost_per_pizza_in_matic, "Not enough MATIC sent!");
    // }

    function view_matic_pizza_price() public view returns(uint256){
        uint256 precision = 1 * 10 ** 8;
        uint256 additional_precision = 1 * 10 ** 10;
        uint256 price = uint(getLatestPizzaPriceInMATIC());
        // address(link).transferFrom(msg.sender, address(this), price);
        uint256 cost_per_pizza_in_matic = (precision / price) * (PIZZA_PRICE_USD * 100000000);
        cost_per_pizza_in_matic = cost_per_pizza_in_matic * additional_precision;
        return cost_per_pizza_in_matic;
    }

    modifier is_paid() {
        // they need to send a value with this tx
        uint256 cost_per_pizza_in_matic = view_matic_pizza_price();
        require(msg.value > cost_per_pizza_in_matic, "Not enough MATIC sent!");
        _;
    }

    function request_pizza_order(uint256 randomResult) internal returns (bytes32){
        Chainlink.Request memory request = buildChainlinkRequest(pizza_jobId, address(this), this.fulfill_pizza.selector);
        request.addUint("random_number", randomResult);
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function getLatestPizzaPriceInMATIC() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = MATIC_TO_USD_PRICE_FEED.latestRoundData();
        return price;
    }

    function fulfil_random_pizza(uint256 randomNumber) public {
        require(msg.sender == pizza_rng_address, "Fulillment only permitted by the Pizza RNG Contract");
        request_pizza_order(randomNumber);
    }

    function fulfill_pizza(bytes32 _requestId, bytes32 _pizza_response) public recordChainlinkFulfillment(_requestId)
    {
        pizza_response = bytes32ToString(_pizza_response);
    }

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}
