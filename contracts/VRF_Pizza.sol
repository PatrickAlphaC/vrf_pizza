
pragma solidity 0.6.6;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@chainlink/contracts/src/v0.6/vendor/SafeMath.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import {VRF_Pizza_RNG_Interface} from "../interfaces/VRF_Pizza_RNG_Interface.sol";

contract VRF_Pizza is ChainlinkClient, Ownable{
    using SafeMath for uint256;
    string public pizza_response;
    AggregatorV3Interface internal MATIC_TO_USD_PRICE_FEED;

    uint256 public PIZZA_PRICE_USD;
    address public MATIC_USD_ADDRESS;
    uint256 public fee;
    address public oracle;
    bytes32 public pizza_jobId;
    address public pizza_rng_address;
    // uint256[] public order_queue;
    address[] public pizza_orderers;
    
    // matic mainnet LINK 0xb0897686c545045afc77cf20ec7a532e3120e0f1
    // matic testnet LINK 0x326C977E6efc84E512bB9C30f76E30c160eD06FB

    // matic mainnet MATIC/USD 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0
    // matic testnet MATIC/USD 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
    constructor(address _link, address _MaticToUSD, address _oracle, string memory jobid, uint256 usd_price, uint256 _fee)
    public  {
        if (_link == address(0)) {
            setPublicChainlinkToken();
        } else {
            setChainlinkToken(_link);
        }
        PIZZA_PRICE_USD = usd_price;
        MATIC_USD_ADDRESS = _MaticToUSD;
        MATIC_TO_USD_PRICE_FEED = AggregatorV3Interface(MATIC_USD_ADDRESS);
        fee = _fee; 
        oracle = _oracle;
        pizza_jobId = stringToBytes32(jobid);
    }

    function order_pizza(uint256 userProvidedSeed) public payable is_paid returns (bytes32){
        pizza_orderers.push(msg.sender);
        return VRF_Pizza_RNG_Interface(pizza_rng_address).create_random_pizza(userProvidedSeed);
    }

    function set_pizza_rng_address(address _pizza_rng_address) public onlyOwner{
        pizza_rng_address = _pizza_rng_address;
    }

    function view_matic_pizza_price() public view returns(uint256){
        uint256 precision = 1 * 10 ** 18;
        uint256 price = uint(getLatestPizzaPriceInMATIC());
        uint256 cost_per_pizza_in_matic = (precision / price) * (PIZZA_PRICE_USD * 100000000);
        return cost_per_pizza_in_matic;
    }

    modifier is_paid() {
        // they need to send a value with this tx
        uint256 cost_per_pizza_in_matic = view_matic_pizza_price();
        require(msg.value > cost_per_pizza_in_matic, "Not enough MATIC sent!");
        _;
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
        Chainlink.Request memory request = buildChainlinkRequest(pizza_jobId, address(this), this.fulfill_pizza.selector);
        request.addInt("random_number", int(uint128(randomNumber)));
        // request.addUint("random_number", uint128(randomNumber));
        sendChainlinkRequestTo(oracle, request, fee);
        // order_queue.push(randomNumber);
    }

    // function execute_order_queue() public {
    //     // anyone can call this
    //     require(order_queue.length > 0, "need some orders!");
    //     for (uint i=0; i< order_queue.length; i++){
    //         uint256 random_number = order_queue[order_queue.length - 1];
    //         Chainlink.Request memory request = buildChainlinkRequest(pizza_jobId, address(this), this.fulfill_pizza.selector);
    //         request.addInt("random_number", int(random_number));
    //         sendChainlinkRequestTo(oracle, request, fee);
    //         order_queue.pop();
    //     }
    // }

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

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }

    function withdraw(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function withdrawLink() external {
        LinkTokenInterface linkToken = LinkTokenInterface(chainlinkTokenAddress());
        require(linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))), "Unable to transfer");
    }
}
