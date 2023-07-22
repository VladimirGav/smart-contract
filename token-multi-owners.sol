// SPDX-License-Identifier: MIT

/**
 * VladimirGav
 * GitHub Website: https://vladimirgav.github.io/
 * GitHub: https://github.com/VladimirGav
 */

/**
 * It is example of a MultiOwners of Contract from VladimirGav
 */

pragma solidity >=0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);

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

// Contract provides multiple owners and multi signature to perform functions
// Usage example
// public onlyMultiOwners
// uint256 FunctionId = 1; // Come up with an Id for this function
// (bool resultSig) = MultiOwners.getSig(FunctionId, uintArray, addressArray, boolArray); // We get true if there are enough signatures
// If there are enough signatures, then we execute the function
// if(resultSig == true){
// Content to be completed if signed by all owners
// }
contract MultiOwners is Context {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Addresses that can sign multi-signature functions
    address[] private addressesMultiOwners;

    constructor () {
        addressesMultiOwners.push(_msgSender());
        emit OwnershipTransferred(address(0), _msgSender());
    }

    // Get addresses of multi-owners
    function getAddressesMultiOwners() public view returns (address[] memory) {
        return addressesMultiOwners;
    }

    // Get the address of the first multiowner
    function getFirstMultiOwner() public view returns (address) {
        address FirstMultiOwner = address(0);
        if(addressesMultiOwners.length > 0){
            FirstMultiOwner = addressesMultiOwners[0];
        }
        return FirstMultiOwner;
    }

    // Get the address of the first multiowner
    function owner() public view returns (address) {
        return getFirstMultiOwner();
    }

    function checkAddressMultiOwner(address[] memory _addressesMultiOwners, address _addressMultiOwner) internal pure returns (bool) {
        bool OwnerExists = false;
        for (uint i; i < _addressesMultiOwners.length; i++) {
            if(_addressesMultiOwners[i] == _addressMultiOwner){
                OwnerExists = true;
            }
        }
        return OwnerExists;
    }

    // Multi owner only
    modifier onlyMultiOwners() {
        require(checkAddressMultiOwner(addressesMultiOwners, _msgSender()) == true, "onlyMultiOwners");
        _;
    }

    // Multisignatures

    // Data for multi-signature functions
    uint256 SigFunctionId;
    uint256[] SigDataUintArray;
    address[] SigDataAddressArray;
    bool[] SigDataBoolArray;

    // Function to add data for multisignature functions
    function addSigData(
        uint256 FunctionId,
        uint256[] memory uintData,
        address[] memory addressData,
        bool[] memory boolData
    ) internal {
        SigFunctionId = FunctionId;
        SigDataUintArray = uintData;
        SigDataAddressArray = addressData;
        SigDataBoolArray = boolData;
    }

    // Function to get data for multi-signature functions
    function getSigData() public view returns (
        uint256 FunctionId,
        uint256[] memory uintData,
        address[] memory addressData,
        bool[] memory boolData
    ) {
        return (SigFunctionId, SigDataUintArray, SigDataAddressArray, SigDataBoolArray);
    }

    address[] private addressesOwnersSig; // owners who signed the last transaction

    // The minimum number of signatures required to perform a multi-signature function
    function getMinSignatures() public view returns (uint256) {
        return getAddressesMultiOwners().length;
    }

    // Get the addresses that signed the last multisig function transaction
    function getAddressesOwnersSig() public view returns (address[] memory) {
        return addressesOwnersSig;
    }

    // Counting the quantity of signatures
    function getCountSignatures() public view returns (uint256) {
        return getAddressesOwnersSig().length;
    }

    // We display how many signed and how many signatures are required
    function getQuantitySig() public view returns (uint256, uint256) {
        return (getCountSignatures(), getMinSignatures());
    }

    // Get the id of the last signed feature with multi-signature
    function getSigFunctionId() public view returns (uint256) {
        return SigFunctionId;
    }

    // Reset all signatures
    function resetSig() internal {
        // Clean up signatures
        delete addressesOwnersSig;

        // Clear all signed data
        delete SigFunctionId;
        delete SigDataUintArray;
        delete SigDataAddressArray;
        delete SigDataBoolArray;
    }

    // Sign transaction
    function addSig() internal {
        addressesOwnersSig.push(msg.sender);
    }

    // We send the id of the function and the data that needs to be signed. Return true if there are enough signatures to complete the operation
    function getSig(uint256 FunctionId, uint256[] memory uintArray, address[] memory addressArray, bool[] memory boolArray) internal returns (bool) {

        bool createNewSigData = false;
        // If there is at least 1 signature for this function
        if(MultiOwners.getAddressesOwnersSig().length > 0){
            // Check the data for the mutisignature
            (uint256 FunctionIdTest, uint256[] memory uintArrayTest, address[] memory addressArrayTest, bool[] memory boolArrayTest) = MultiOwners.getSigData();

            // Checking FunctionId
            if(FunctionId != FunctionIdTest){ createNewSigData = true; }

            // Checking array length matches
            if(uintArray.length != uintArrayTest.length){ createNewSigData = true; }
            if(addressArray.length != addressArrayTest.length){ createNewSigData = true; }
            if(boolArray.length != boolArrayTest.length){ createNewSigData = true; }

            // Checking if array elements match
            for (uint i; i < uintArray.length; i++) { if(uintArray[i] != uintArrayTest[i]){ createNewSigData = true; } }
            for (uint i; i < addressArray.length; i++) { if(addressArray[i] != addressArrayTest[i]){ createNewSigData = true; } }
            for (uint i; i < boolArray.length; i++) { if(boolArray[i] != boolArrayTest[i]){ createNewSigData = true; } }
        } else {
            createNewSigData = true;
        }

        if(createNewSigData == true){
            MultiOwners.resetSig(); // Clear all signed data
            MultiOwners.addSigData(FunctionId, uintArray, addressArray, boolArray); // Creating data for multi-signature
        }

        // We sign the transaction by the current user
        MultiOwners.addSig();

        // If there are enough signatures, then execute
        if(MultiOwners.getAddressesOwnersSig().length >= MultiOwners.getMinSignatures()){
            MultiOwners.resetSig(); // Clear all signed data to block retries
            return true;
        }
        return false;
    }

    // Multiowner Management

    // Add multi-owner
    function addAddressMultiOwner(address _newMultiOwner) public onlyMultiOwners {
        require(_newMultiOwner != address(0), "newMultiOwner is zero address");
        require(checkAddressMultiOwner(addressesMultiOwners, _newMultiOwner) == false, "addAddresMultiOwner: Owner address already exists");

        // We create arrays of data for signature
        uint256[] memory uintArray = new uint256[](1);
        uintArray[0] = 0;
        address[] memory addressArray = new address[](1);
        addressArray[0] = _newMultiOwner;
        bool[] memory boolArray = new bool[](1);
        boolArray[0] = false;

        uint256 FunctionId = 1; // Come up with an Id for this function
        (bool resultSig) = MultiOwners.getSig(FunctionId, uintArray, addressArray, boolArray); // We get true if there are enough signatures

        // If there are enough signatures, then we execute the function
        if(resultSig == true){
            // Content to be completed if signed by all owners
            addressesMultiOwners.push(_newMultiOwner);
        }
    }

    // Delete one multi-owner
    function removeAddressMultiOwner(address _removeMultiOwner) public onlyMultiOwners {
        require(checkAddressMultiOwner(addressesMultiOwners, _removeMultiOwner) == true, "removeAddressMultiOwner: Owner address not found");

        // We create arrays of data for signature
        uint256[] memory uintArray = new uint256[](1);
        uintArray[0] = 0;
        address[] memory addressArray = new address[](1);
        addressArray[0] = _removeMultiOwner;
        bool[] memory boolArray = new bool[](1);
        boolArray[0] = false;

        uint256 FunctionId = 2; // Come up with an Id for this function
        (bool resultSig) = MultiOwners.getSig(FunctionId, uintArray, addressArray, boolArray); // We get true if there are enough signatures

        // If there are enough signatures, then we execute the function
        if(resultSig == true){
            // Content to be completed if signed by all owners
            for (uint i = 0; i < addressesMultiOwners.length; i++) {
                if (addressesMultiOwners[i] == _removeMultiOwner) {
                    addressesMultiOwners[i] = addressesMultiOwners[addressesMultiOwners.length - 1];
                    addressesMultiOwners.pop();
                }
            }
        }
    }

    // Remove all multi-owners, relinquish ownership
    function removeAllMultiOwner() public onlyMultiOwners {

        // We create arrays of data for signature
        uint256[] memory uintArray = new uint256[](0);
        address[] memory addressArray = new address[](0);
        bool[] memory boolArray = new bool[](0);

        uint256 FunctionId = 3; // Come up with an Id for this function
        (bool resultSig) = MultiOwners.getSig(FunctionId, uintArray, addressArray, boolArray); // We get true if there are enough signatures

        // If there are enough signatures, then we execute the function
        if(resultSig == true){
            // Content to be completed if signed by all owners
            for (uint i = 0; i < addressesMultiOwners.length; i++) {
                MultiOwners.resetSig(); // Clear all signed data to block retries
                delete addressesMultiOwners;
            }
        }
    }

}

contract SimpleToken is Context, MultiOwners, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    constructor() {
        _name = "VladimirGav";
        _symbol = "VladimirGav";
        _decimals = 18;
        _totalSupply = 1000000 * 1000000000000000000;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address addressOwner, address spender) external view returns (uint256) {
        return _allowances[addressOwner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "Transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "Decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount <= _balances[sender], "Transfer amount exceeds balance");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address addressOwner, address spender, uint256 amount) internal {
        require(addressOwner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[addressOwner][spender] = amount;
        emit Approval(addressOwner, spender, amount);
    }

}