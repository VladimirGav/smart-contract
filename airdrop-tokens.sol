// SPDX-License-Identifier: MIT

/**
 * VladimirGav
 * GitHub Website: https://vladimirgav.github.io/
 * GitHub: https://github.com/VladimirGav
 */

/**
 * It is example of a AirdropTokens of Contract from VladimirGav
 */

pragma solidity >=0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function owner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// @dev Wrappers over Solidity's arithmetic operations with added overflow * checks.
library SafeMath {
    // Counterpart to Solidity's `+` operator.
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    // Counterpart to Solidity's `-` operator.
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    // Counterpart to Solidity's `-` operator.
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    // Counterpart to Solidity's `*` operator.
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    // Counterpart to Solidity's `/` operator.
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    // Counterpart to Solidity's `/` operator.
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    // Counterpart to Solidity's `%` operator.
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    // Counterpart to Solidity's `%` operator.
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "onlyOwner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Wallet is Ownable {
    receive() external payable {}
    fallback() external payable {}

    // Transfer Eth
    function transferEth(address _to, uint256 _amount) public onlyOwner {
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    // Transfer Tokens
    function transferTokens(address addressToken, address _to, uint256 _amount) public onlyOwner {
        IERC20 contractToken = IERC20(addressToken);
        contractToken.transfer(_to, _amount);
    }

}


contract AirdropTokens is Ownable, Wallet {
    using SafeMath for uint256;

    function getOwnerToken(address addressToken) public view returns (
        address addressOwnerToken
    ) {
        return IERC20(addressToken).owner();
    }

    // Creating and deleting a Airdrop. Available only to the owner of the tokens.

    // Airdrop data
    struct AirdropData {
        bool contractIsHolder; // true - This contract is the holder, false - Owner is the holder
        uint256 amount;
        uint256 startTime;
        uint256 finishTime;
        bool refund;
        uint256 totalBalance;
        uint256 totalRecipients;
        uint256 totalReceived;
    }

    // Airdrop array
    mapping(address => AirdropData) public mappingAirdropData;

    // Recipients Data array
    mapping(address => mapping(address => uint256)) public mappingRecipientsData;

    // add Airdrop data
    function addAirdropData(
        address addressToken,
        bool contractIsHolder,
        uint256 startTime,
        uint256 finishTime,
        bool refund,
        address[] memory  _addressesArray,
        uint256[] memory  _amountsArray
    ) internal {
        require(getOwnerToken(addressToken) == msg.sender, "Airdrop can only be created by the owner of the token.");
        require(mappingAirdropData[addressToken].amount == 0, "Airdrop already exists.");
        require(_addressesArray.length == _amountsArray.length, "_addressesArray.length != _amountsArray.length");

        uint256 amount;
        for (uint i; i < _amountsArray.length; i++) {
            //require(_amountsArray[i] > 0, "amountsArray key = 0");
            mappingRecipientsData[_addressesArray[i]][addressToken] = _amountsArray[i];
            amount = amount.add(_amountsArray[i]);
        }

        require(amount > 0, "amount < 0");

        if(startTime == 0){
            startTime = block.timestamp; // now
        }
        if(finishTime == 0){
            finishTime = startTime + 2419200; // + 28 days
        }

        require(startTime >= block.timestamp, "startTime < now");
        require(finishTime > startTime, "finishTime <= startTime");

        if(contractIsHolder){
            require(IERC20(addressToken).transferFrom(msg.sender, address(this), amount), "TransferFrom failed. Approval required.");
        } else {
            require(IERC20(addressToken).allowance(msg.sender, address(this)) >= amount, "allowance < amount");
            require(IERC20(addressToken).balanceOf(msg.sender) >= amount, "balance < amount");
        }

        mappingAirdropData[addressToken].contractIsHolder = contractIsHolder;
        mappingAirdropData[addressToken].amount = amount;
        mappingAirdropData[addressToken].startTime = startTime;
        mappingAirdropData[addressToken].finishTime = finishTime;
        mappingAirdropData[addressToken].refund = refund;
        mappingAirdropData[addressToken].totalBalance = amount;
        if(contractIsHolder && IERC20(addressToken).balanceOf(address(this)) < amount){
            mappingAirdropData[addressToken].totalBalance = IERC20(addressToken).balanceOf(address(this));
        }
        mappingAirdropData[addressToken].totalRecipients = _amountsArray.length;
        mappingAirdropData[addressToken].totalReceived = 0;
    }

    // Show static Airdrop data
    function getAirdropData(address addressToken) public view returns (
        bool contractIsHolder,
        uint256 amount,
        uint256 startTime,
        uint256 finishTime,
        bool refund
    ) {
        return (
        mappingAirdropData[addressToken].contractIsHolder,
        mappingAirdropData[addressToken].amount,
        mappingAirdropData[addressToken].startTime,
        mappingAirdropData[addressToken].finishTime,
        mappingAirdropData[addressToken].refund
        );
    }

    // Show variable Airdrop data
    function getAirdropDataTotal(address addressToken) public view returns (
        uint256 totalBalance,
        uint256 totalRecipients,
        uint256 totalReceived
    ) {
        return (
        mappingAirdropData[addressToken].totalBalance,
        mappingAirdropData[addressToken].totalRecipients,
        mappingAirdropData[addressToken].totalReceived
        );
    }

    // delete Airdrop data
    function removeAirdropData(
        address addressToken,
        address[] memory  _addressesArray
    ) internal {
        require(getOwnerToken(addressToken) == msg.sender, "Airdrop can only be created by the owner of the token.");
        require(mappingAirdropData[addressToken].amount > 0, "Airdrop tokens not found");

        require(_addressesArray.length == mappingAirdropData[addressToken].totalRecipients, "_addressesArray.length != totalRecipients");
        for (uint i; i < _addressesArray.length; i++) {
            mappingRecipientsData[_addressesArray[i]][addressToken] = 0;
        }

        if(mappingAirdropData[addressToken].totalBalance > 0){
            require(block.timestamp > mappingAirdropData[addressToken].finishTime, "Now < finishTime. Removal available after completion.");
            if(mappingAirdropData[addressToken].contractIsHolder){
                if(mappingAirdropData[addressToken].refund){
                    IERC20(addressToken).transfer(msg.sender, mappingAirdropData[addressToken].totalBalance);
                } else {
                    IERC20(addressToken).transfer(address(0x000000000000000000000000000000000000dEaD), mappingAirdropData[addressToken].totalBalance);
                }
            }
        }

        mappingAirdropData[addressToken].amount = 0;
        mappingAirdropData[addressToken].startTime = 0;
        mappingAirdropData[addressToken].finishTime = 0;
        mappingAirdropData[addressToken].refund = false;
        mappingAirdropData[addressToken].totalBalance = 0;
        mappingAirdropData[addressToken].totalRecipients = 0;
        mappingAirdropData[addressToken].totalReceived = 0;
    }

    /**
     * Create Airdrop, available only to the owner of the tokens
     * addressToken - token address
     * contractIsHolder - true - This contract is the holder, false - Owner is the holder
     * startTime - start time in seconds
     * finishTime - finish time in seconds
     * refund - true - return the unspent balance to the owner; false - Burn
     * _addressesArray - Address Array
     * _amountsArray - Amounts Array
     */
    function createAirdrop(
        address addressToken,
        bool contractIsHolder,
        uint256 startTime,
        uint256 finishTime,
        bool refund,
        address[] memory  _addressesArray,
        uint256[] memory  _amountsArray
    ) public returns (bool) {
        addAirdropData(addressToken, contractIsHolder, startTime, finishTime, refund, _addressesArray, _amountsArray);
        return true;
    }

    /**
     * Remove Airdrop, available only to the owner of the tokens
     * addressToken - token address
     * _addressesArray - Address Array
     */
    function removeAirdrop(
        address addressToken,
        address[] memory  _addressesArray
    ) public returns (bool) {
        removeAirdropData(addressToken, _addressesArray);
        return true;
    }

    // check Airdrop
    function checkAirdrop(address addressAccount, address addressToken) public view returns (uint256 amount) {
        return mappingRecipientsData[addressAccount][addressToken];
    }

    // Send sendAirdrop
    function sendAirdrop(address addressAccount, address addressToken) internal {
        require(mappingAirdropData[addressToken].amount > 0, "Airdrop tokens not found");
        require(mappingAirdropData[addressToken].totalBalance > 0, "Airdrop totalBalance = 0");
        require(mappingRecipientsData[addressAccount][addressToken] > 0, "Your airdrop = 0");

        if(mappingAirdropData[addressToken].contractIsHolder){
            IERC20(addressToken).transfer(addressAccount, mappingRecipientsData[addressAccount][addressToken]);
        } else {
            IERC20(addressToken).transferFrom(getOwnerToken(addressToken), addressAccount, mappingRecipientsData[addressAccount][addressToken]);
        }

        mappingAirdropData[addressToken].totalBalance = mappingAirdropData[addressToken].totalBalance.sub(mappingRecipientsData[addressAccount][addressToken]);
        mappingAirdropData[addressToken].totalReceived += 1;

        mappingRecipientsData[addressAccount][addressToken] = 0;
    }

    /**
     * Claim Airdrop.
     */
    function claimAirdrop(address addressToken) public returns (bool) {
        sendAirdrop(msg.sender, addressToken);
        return true;
    }

}