// SPDX-License-Identifier: MIT

/**
 * VladimirGav
 * GitHub Website: https://vladimirgav.github.io/
 * GitHub: https://github.com/VladimirGav
 */

/**
 * It is example of a StakingTokens of Contract from VladimirGav
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

contract StakingTokens is Ownable, Wallet {
    using SafeMath for uint256;

    function getOwnerToken(address addressToken) public view returns (
        address addressOwnerToken
    ) {
        return IERC20(addressToken).owner();
    }

    // Creating and deleting a stake. Available only to the owner of the tokens.

    // staking data
    struct StakingData {
        uint256 amount;
        uint256 startTime;
        uint256 finishTime;
        uint256 waitingTime;
        bool refund;
        uint256 totalStaked;
        uint256 totalRewards;
        uint256 totalHolders;
    }

    // staking array
    mapping(address => StakingData) public mappingStakingData;

    // add staking data
    function addStakingData(
        address addressToken,
        uint256 amount,
        uint256 startTime,
        uint256 finishTime,
        uint256 waitingTime,
        bool refund
    ) internal {
        require(getOwnerToken(addressToken) == msg.sender, "Staking can only be created by the owner of the token.");
        require(mappingStakingData[addressToken].amount == 0, "Staking already exists. Required to remove staking.");
        require(amount > 0, "amount < 0");

        if(startTime == 0){
            startTime = block.timestamp; // now
        }
        if(finishTime == 0){
            finishTime = startTime + 2419200; // + 28 days
        }
        if(waitingTime == 0){
            waitingTime = finishTime + 2419200; // + 28 days
        }
        require(startTime >= block.timestamp, "startTime < now");
        require(finishTime > startTime, "finishTime <= startTime");
        require(waitingTime > finishTime, "waitingTime >= finishTime");

        require(IERC20(addressToken).transferFrom(msg.sender, address(this), amount), "TransferFrom failed. Approval required.");

        mappingStakingData[addressToken].amount = amount;
        mappingStakingData[addressToken].startTime = startTime;
        mappingStakingData[addressToken].finishTime = finishTime;
        mappingStakingData[addressToken].waitingTime = waitingTime;
        mappingStakingData[addressToken].refund = refund;
        mappingStakingData[addressToken].totalStaked = 0;
        mappingStakingData[addressToken].totalRewards = amount;
        if(IERC20(addressToken).balanceOf(address(this)) < amount){
            mappingStakingData[addressToken].totalRewards = IERC20(addressToken).balanceOf(address(this));
        }
        mappingStakingData[addressToken].totalHolders = 0;
    }

    // Show static staking data
    function getStakingData(address addressToken) public view returns (
        uint256 amount,
        uint256 startTime,
        uint256 finishTime,
        uint256 waitingTime,
        bool refund
    ) {
        return (
        mappingStakingData[addressToken].amount,
        mappingStakingData[addressToken].startTime,
        mappingStakingData[addressToken].finishTime,
        mappingStakingData[addressToken].waitingTime,
        mappingStakingData[addressToken].refund
        );
    }

    // Show variable staking data
    function getStakingDataTotal(address addressToken) public view returns (
        uint256 totalStaked,
        uint256 totalRewards,
        uint256 totalHolders
    ) {
        return (
        mappingStakingData[addressToken].totalStaked,
        mappingStakingData[addressToken].totalRewards,
        mappingStakingData[addressToken].totalHolders
        );
    }

    // delete staking data
    function removeStakingData(
        address addressToken
    ) internal {
        require(getOwnerToken(addressToken) == msg.sender, "Staking can only be created by the owner of the token.");
        require(mappingStakingData[addressToken].amount > 0, "Staking tokens not found");

        if(mappingStakingData[addressToken].totalRewards > 0){
            require(block.timestamp > mappingStakingData[addressToken].waitingTime, "Now < waitingTime. Removal available after completion.");
            if(mappingStakingData[addressToken].refund){
                IERC20(addressToken).transfer(msg.sender, mappingStakingData[addressToken].totalRewards);
            } else {
                IERC20(addressToken).transfer(address(0x000000000000000000000000000000000000dEaD), mappingStakingData[addressToken].totalRewards);
            }
        }

        mappingStakingData[addressToken].amount = 0;
        mappingStakingData[addressToken].startTime = 0;
        mappingStakingData[addressToken].finishTime = 0;
        mappingStakingData[addressToken].waitingTime = 0;
        mappingStakingData[addressToken].refund = false;
        mappingStakingData[addressToken].totalStaked = 0;
        mappingStakingData[addressToken].totalRewards = 0;
        mappingStakingData[addressToken].totalHolders = 0;
    }

    /**
     * Create Staking, available only to the owner of the tokens
     * addressToken - token address
     * amount - amount of tokens to stake
     * startTime - start time in seconds
     * finishTime - finish time in seconds
     * waitingTime - until what time it is forbidden to remove a stake and it is possible to receive a reward in seconds
     * refund - true - return the unspent balance to the owner; false - Burn
     */
    function createStaking(
        address addressToken,
        uint256 amount,
        uint256 startTime,
        uint256 finishTime,
        uint256 waitingTime,
        bool refund
    ) public returns (bool) {
        addStakingData(addressToken, amount, startTime, finishTime, waitingTime, refund);
        return true;
    }

    /**
     * Remove staking, available only to the owner of the tokens
     * addressToken - token address
     */
    function removeStaking(
        address addressToken
    ) public returns (bool) {
        removeStakingData(addressToken);
        return true;
    }

    // Add and remove stakes for holders

    // Holder data
    struct HolderData {
        uint256 amount;
        uint256 startTime;
    }

    // Holder data array
    mapping(address => mapping(address => HolderData)) public mappingHolderData;

    // add holder data
    function addHolderData(
        address addressToken,
        uint256 amount
    ) internal {
        require(mappingStakingData[addressToken].amount > 0, "Staking tokens not found");
        require(block.timestamp < mappingStakingData[addressToken].finishTime, "Now > finishTime. Staking completed.");
        require(mappingHolderData[msg.sender][addressToken].amount == 0, "Staking already exists. Required unstake.");
        require(amount > 0, "amount < 0");

        require(IERC20(addressToken).transferFrom(msg.sender, address(this), amount), "TransferFrom failed. Approval required.");

        mappingHolderData[msg.sender][addressToken].amount = amount;
        mappingHolderData[msg.sender][addressToken].startTime = block.timestamp;
        mappingStakingData[addressToken].totalStaked = mappingStakingData[addressToken].totalStaked.add(amount);
        mappingStakingData[addressToken].totalHolders += 1;
    }

    // reward = _totalRewards * _holderTokens * _holderDuration / _totalStaked / _stakingDuration
    function rewardAlgorithm(uint256 _totalRewards, uint256 _totalStaked, uint256 _stakingDuration, uint256 _holderTokens, uint256 _holderDuration) public pure returns (
        uint256 reward
    ) {
        if (_totalRewards == 0) {
            return 0;
        }
        if (_totalStaked == 0) {
            return 0;
        }

        // _totalRewards * _holderTokens * _holderDuration / _totalStaked / _stakingDuration
        reward = _totalRewards.mul(_holderTokens).mul(_holderDuration).div(_totalStaked).div(_stakingDuration);

        return reward;
    }

    // Rewards calculator
    function calculateRewards(address addressHolder, address addressToken) public view returns (
        uint256 reward,
        uint256 stakingDuration,
        uint256 holderStartTime,
        uint256 holderFinishTime,
        uint256 holderDuration
    ) {
        if (mappingStakingData[addressToken].totalRewards == 0) {
            return (0, 0, 0, 0, 0);
        }
        if (mappingStakingData[addressToken].totalStaked == 0) {
            return (0, 0, 0, 0, 0);
        }
        if (mappingHolderData[addressHolder][addressToken].amount == 0) {
            return (0, 0, 0, 0, 0);
        }
        if (mappingHolderData[addressHolder][addressToken].startTime > block.timestamp) {
            return (0, 0, 0, 0, 0);
        }

        stakingDuration = mappingStakingData[addressToken].finishTime.sub(mappingStakingData[addressToken].startTime);

        holderStartTime = mappingHolderData[addressHolder][addressToken].startTime;
        holderFinishTime = block.timestamp;

        if(mappingHolderData[addressHolder][addressToken].startTime < mappingStakingData[addressToken].startTime){
            holderStartTime = mappingStakingData[addressToken].startTime;
        }
        if(block.timestamp > mappingStakingData[addressToken].finishTime){
            holderFinishTime = mappingStakingData[addressToken].finishTime;
        }
        holderDuration = holderFinishTime.sub(holderStartTime);

        reward = rewardAlgorithm(
            mappingStakingData[addressToken].totalRewards,
            mappingStakingData[addressToken].totalStaked,
            stakingDuration,
            mappingHolderData[addressHolder][addressToken].amount,
            holderDuration
        );

        return (reward, stakingDuration, holderStartTime, holderFinishTime, holderDuration);
    }

    // Get holder data
    function getHolderData(address addressHolder, address addressToken) public view returns (
        uint256 amount,
        uint256 startTime,
        uint256 reward,
        uint256 stakingDuration,
        uint256 holderStartTime,
        uint256 holderFinishTime,
        uint256 holderDuration
    ) {
        (reward, stakingDuration, holderStartTime, holderFinishTime, holderDuration) = calculateRewards(addressHolder, addressToken);
        return (
        mappingHolderData[addressHolder][addressToken].amount,
        mappingHolderData[addressHolder][addressToken].startTime,
        reward,
        stakingDuration,
        holderStartTime,
        holderFinishTime,
        holderDuration
        );
    }

    // Show current timestamp
    function showTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    // Send rewards to holder
    function sendRewards(address addressHolder, address addressToken) internal {
        uint256 reward = 0;
        uint256 stakingDuration = 0;
        uint256 holderStartTime = 0;
        uint256 holderFinishTime = 0;
        uint256 holderDuration = 0;
        (reward, stakingDuration, holderStartTime, holderFinishTime, holderDuration) = calculateRewards(addressHolder, addressToken);
        if(reward>0){
            mappingStakingData[addressToken].totalRewards = mappingStakingData[addressToken].totalRewards.sub(reward);
            require(IERC20(addressToken).transfer(addressHolder, reward), "Transfer reward failed.");
            mappingHolderData[addressHolder][addressToken].startTime = block.timestamp;
        }
    }

    // Send tokens to holder
    function sendStakeTokens(address addressHolder, address addressToken) internal {
        if(mappingHolderData[addressHolder][addressToken].amount > 0){
            if(mappingStakingData[addressToken].amount > 0){
                mappingStakingData[addressToken].totalHolders -= 1;
                mappingStakingData[addressToken].totalStaked = mappingStakingData[addressToken].totalStaked.sub(mappingHolderData[addressHolder][addressToken].amount);
            }
            require(IERC20(addressToken).transfer(addressHolder, mappingHolderData[addressHolder][addressToken].amount), "transfer StakeTokens failed.");
            mappingHolderData[addressHolder][addressToken].amount = 0;
            mappingHolderData[addressHolder][addressToken].startTime = 0;
        }
    }

    /**
     * Put on stake. Required to allow this smart contract to spend tokens
     * addressToken - token address
     * amount - amount tokens
     */
    function Stake(
        address addressToken,
        uint256 amount
    ) public returns (bool) {
        addHolderData(addressToken, amount);
        return true;
    }

    /**
     * Withdraw stake. Rewards will be sent if staking has not yet been removed
     */
    function Unstake(
        address addressToken
    ) public returns (bool) {
        require(mappingHolderData[msg.sender][addressToken].amount > 0, "Staking tokens not found.");
        sendRewards(msg.sender, addressToken);
        sendStakeTokens(msg.sender, addressToken);
        return true;
    }

    /**
     * Claim an reward.
     */
    function claimReward(address addressToken) public returns (bool) {
        sendRewards(msg.sender, addressToken);
        return true;
    }

}