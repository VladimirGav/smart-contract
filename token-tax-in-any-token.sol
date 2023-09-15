// SPDX-License-Identifier: MIT

/**
 * VladimirGav
 * GitHub Website: https://vladimirgav.github.io/
 * GitHub: https://github.com/VladimirGav
 */

/**
 * It is example of a Token Buy, Sell, Transfer Tax in any tokens from VladimirGav
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

interface IUniswapV2Router01 {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external pure returns (uint256[] memory amounts);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external pure returns (uint256[] memory amounts);

    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint deadline) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint256[] memory amounts);
    function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint deadline) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint256[] memory amounts);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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

contract SwapTokensBlock is Ownable {

    // get Amounts Out By Swap
    function getAmountsOutBySwap(
        address addressSwapRouter,
        uint256 amountIn,
        address[] memory addressesPath
    ) public pure returns (
        uint256[] memory amountsOut
    ) {
        IUniswapV2Router01 interfaceSwapRouter = IUniswapV2Router01(addressSwapRouter);
        amountsOut = interfaceSwapRouter.getAmountsOut(amountIn, addressesPath);
        return (amountsOut);
    }

    function getFactoryBySwap(
        address addressSwapRouter
    ) public pure returns (
        address addressFactory
    ) {
        IUniswapV2Router01 interfaceSwapRouter = IUniswapV2Router01(addressSwapRouter);
        addressFactory = interfaceSwapRouter.factory();
        return (addressFactory);
    }

    function getPairBySwap(
        address addressSwapRouter,
        address tokenA,
        address tokenB
    ) public view returns (
        address addressPair
    ) {
        address addressFactory = getFactoryBySwap(addressSwapRouter);

        IUniswapV2Factory interfaceIUniswapV2Factory = IUniswapV2Factory(addressFactory);
        addressPair = interfaceIUniswapV2Factory.getPair(tokenA, tokenB);
        return (addressPair);
    }

    // execute Swap Tokens
    function executeSwapTokens(
        uint256 amountIn,
        address addressRecipient,
        address addressSwapRouter,
        address[] memory addressesPath
    ) internal returns (uint256[] memory amounts) {
        IUniswapV2Router01 interfaceSwapRouter = IUniswapV2Router01(addressSwapRouter);

        uint256[] memory getAmountsOut = getAmountsOutBySwap(addressSwapRouter, amountIn, addressesPath);
        uint256 amountOutMin = getAmountsOut[getAmountsOut.length-1];

        if(amountOutMin > 0){
            if(interfaceSwapRouter.WETH() == addressesPath[0] ){
                // WETH to Tokens
                amounts = interfaceSwapRouter.swapExactETHForTokens{ value: amountIn }(amountOutMin, addressesPath, addressRecipient, block.timestamp);
            } else if (interfaceSwapRouter.WETH() == addressesPath[addressesPath.length-1] ){
                // Tokens to WETH
                amounts = interfaceSwapRouter.swapExactTokensForETH(amountIn, amountOutMin, addressesPath, addressRecipient, block.timestamp);
            } else {
                // Tokens to Tokens
                amounts = interfaceSwapRouter.swapExactTokensForTokens(amountIn, amountOutMin, addressesPath, addressRecipient, block.timestamp);
            }
        }

        // The input token amount and all subsequent output token amounts.
        return amounts;

    }

}

contract SwapBlock is Ownable, SwapTokensBlock {
    using SafeMath for uint256;

    mapping(address=>bool) addressesLiquidity;
    mapping(address=>bool) addressesIgnoreTax;

    struct SwapData {
        address addressSwapRouter;
        address[] addressesPath;
    }

    mapping(uint => mapping(uint => SwapData)) public mappingSwapData;

    uint256[] private percentsTaxBuy;
    uint256[] private percentsTaxSell;
    uint256[] private percentsTaxTransfer;

    address[] private addressesTaxBuy;
    address[] private addressesTaxSell;
    address[] private addressesTaxTransfer;

    // typeTax - 1- TaxBuy, 2 - TaxSell, 3 - TaxTransfer
    // keyTax - key in addressesTax(Buy,Sell,Transfer) arrays
    function addSwapData(
        uint typeTax,
        uint keyTax,
        address addressSwapRouter,
        address[] memory addressesPath
    ) internal {
        require(typeTax > 0 && typeTax < 4, "typeTax != 1,2,3. typeTax: 1 - TaxBuy, 2 - TaxSell, 3 - TaxTransfer");

        require(typeTax==1 && keyTax < addressesTaxBuy.length, "keyTax in addressesTaxBuy not found");
        require(typeTax==2 && keyTax < addressesTaxSell.length, "keyTax in addressesTaxSell not found");
        require(typeTax==3 && keyTax < addressesTaxTransfer.length, "keyTax in addressesTaxTransfer not found");

        require(addressesPath.length > 1, "addressesPath < 1");
        require(addressesPath[0] == address(this), "addressesPath[0] != token of this contract");

        address tokenA;
        address tokenB;

        // Check Pairs
        for (uint i; i < addressesPath.length; i++) {
            tokenA = addressesPath[i];
            if(i > 0){
                require(getPairBySwap(addressSwapRouter, tokenA, tokenB) != address(0), "Swap Pair in addressesPath not found");
            }
            tokenB = addressesPath[i];
        }

        // Check Liquidity
        uint256[] memory getAmountsOut = SwapTokensBlock.getAmountsOutBySwap(addressSwapRouter, IERC20(address(this)).totalSupply().div(1000), addressesPath);
        require(getAmountsOut.length > 0, "Could not get price for this chain for 0.1% of tokens");

        mappingSwapData[typeTax][keyTax].addressSwapRouter = addressSwapRouter;
        mappingSwapData[typeTax][keyTax].addressesPath = addressesPath;
    }

    // reset Tax In Any Token
    function resetTaxInAnyToken(uint typeTax, uint keyTax) public onlyOwner {
        delete mappingSwapData[typeTax][keyTax].addressSwapRouter;
        delete mappingSwapData[typeTax][keyTax].addressesPath;
    }

    // set Tax In Any Token
    function setTaxInAnyToken(uint typeTax, uint keyTax, address addressSwapRouter, address[] memory addressesPath) public onlyOwner {
        addSwapData(typeTax, keyTax, addressSwapRouter, addressesPath);
    }

    // get Swap Data
    function getSwapData(uint typeTax, uint keyTax) public view returns (address addressSwapRouter, address[] memory addressesPath) {
        return (mappingSwapData[typeTax][keyTax].addressSwapRouter, mappingSwapData[typeTax][keyTax].addressesPath);
    }

    function getTaxSum(uint256[] memory _percentsTax) internal pure returns (uint256) {
        uint256 TaxSum = 0;
        for (uint i; i < _percentsTax.length; i++) {
            TaxSum = TaxSum.add(_percentsTax[i]);
        }
        return TaxSum;
    }

    function getPercentsTaxBuy() public view returns (uint256[] memory) {
        return percentsTaxBuy;
    }

    function getPercentsTaxSell() public view returns (uint256[] memory) {
        return percentsTaxSell;
    }

    function getPercentsTaxTransfer() public view returns (uint256[] memory) {
        return percentsTaxTransfer;
    }

    function getAddressesTaxBuy() public view returns (address[] memory) {
        return addressesTaxBuy;
    }

    function getAddressesTaxSell() public view returns (address[] memory) {
        return addressesTaxSell;
    }

    function getAddressesTaxTransfer() public view returns (address[] memory) {
        return addressesTaxTransfer;
    }

    function checkAddressLiquidity(address _addressLiquidity) external view returns (bool) {
        return addressesLiquidity[_addressLiquidity];
    }

    function addAddressLiquidity(address _addressLiquidity) public onlyOwner {
        addressesLiquidity[_addressLiquidity] = true;
    }

    function removeAddressLiquidity (address _addressLiquidity) public onlyOwner {
        addressesLiquidity[_addressLiquidity] = false;
    }

    function checkAddressIgnoreTax(address _addressIgnoreTax) external view returns (bool) {
        return addressesIgnoreTax[_addressIgnoreTax];
    }

    function addAddressIgnoreTax(address _addressIgnoreTax) public onlyOwner {
        addressesIgnoreTax[_addressIgnoreTax] = true;
    }

    function removeAddressIgnoreTax (address _addressIgnoreTax) public onlyOwner {
        addressesIgnoreTax[_addressIgnoreTax] = false;
    }

    function setTaxBuy(uint256[] memory _percentsTaxBuy, address[] memory _addressesTaxBuy) public onlyOwner {
        require(_percentsTaxBuy.length == _addressesTaxBuy.length, "_percentsTaxBuy.length != _addressesTaxBuy.length");

        uint256 TaxSum = getTaxSum(_percentsTaxBuy);
        require(TaxSum <= 20, "TaxSum > 20"); // Set the maximum tax limit

        percentsTaxBuy = _percentsTaxBuy;
        addressesTaxBuy = _addressesTaxBuy;

        for (uint i; i < _addressesTaxBuy.length; i++) {
            resetTaxInAnyToken(1, i);
        }
    }

    function setTaxSell(uint256[] memory _percentsTaxSell, address[] memory _addressesTaxSell) public onlyOwner {
        require(_percentsTaxSell.length == _addressesTaxSell.length, "_percentsTaxSell.length != _addressesTaxSell.length");

        uint256 TaxSum = getTaxSum(_percentsTaxSell);
        require(TaxSum <= 20, "TaxSum > 20"); // Set the maximum tax limit

        percentsTaxSell = _percentsTaxSell;
        addressesTaxSell = _addressesTaxSell;

        for (uint i; i < _addressesTaxSell.length; i++) {
            resetTaxInAnyToken(2, i);
        }
    }

    function setTaxTransfer(uint256[] memory _percentsTaxTransfer, address[] memory _addressesTaxTransfer) public onlyOwner {
        require(_percentsTaxTransfer.length == _addressesTaxTransfer.length, "_percentsTaxTransfer.length != _addressesTaxTransfer.length");

        uint256 TaxSum = getTaxSum(_percentsTaxTransfer);
        require(TaxSum <= 20, "TaxSum > 20"); // Set the maximum tax limit

        percentsTaxTransfer = _percentsTaxTransfer;
        addressesTaxTransfer = _addressesTaxTransfer;

        for (uint i; i < _addressesTaxTransfer.length; i++) {
            resetTaxInAnyToken(3, i);
        }
    }

    function showTaxBuy() public view returns (uint[] memory, address[] memory) {
        return (percentsTaxBuy, addressesTaxBuy);
    }

    function showTaxSell() public view returns (uint[] memory, address[] memory) {
        return (percentsTaxSell, addressesTaxSell);
    }

    function showTaxTransfer() public view returns (uint[] memory, address[] memory) {
        return (percentsTaxTransfer, addressesTaxTransfer);
    }

    function showTaxBuySum() public view returns (uint) {
        return getTaxSum(percentsTaxBuy);
    }

    function showTaxSellSum() public view returns (uint) {
        return getTaxSum(percentsTaxSell);
    }

    function showTaxTransferSum() public view returns (uint) {
        return getTaxSum(percentsTaxTransfer);
    }

}

contract SimpleToken is Context, Ownable, IERC20, SwapBlock {
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

        // send tax
        (uint256 amountRecipient) = getAmountAfterTax(sender, recipient, amount);

        _balances[recipient] = _balances[recipient].add(amountRecipient);
        emit Transfer(sender, recipient, amountRecipient);

    }

    function _approve(address addressOwner, address spender, uint256 amount) internal {
        require(addressOwner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[addressOwner][spender] = amount;
        emit Approval(addressOwner, spender, amount);
    }

    // send Tax and return Amount After Tax
    function getAmountAfterTax(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256 amountRecipient) {

        amountRecipient = amount;

        // checkAddressIgnoreTax
        if (!addressesIgnoreTax[sender] && !addressesIgnoreTax[recipient]) {
            uint typeTax;
            uint256 amountTax = 0;
            address addressesTax;

            if (addressesLiquidity[sender] && SwapBlock.getPercentsTaxBuy().length > 0) {
                // send Tax Buy
                typeTax = 1;

                for (uint i; i < SwapBlock.getPercentsTaxBuy().length; i++) {
                    amountTax = amount.div(100).mul(SwapBlock.getPercentsTaxBuy()[i]);
                    addressesTax = SwapBlock.getAddressesTaxBuy()[i];
                    amountRecipient = amountRecipient.sub(amountTax);

                    (address addressSwapRouter, address[] memory addressesPath) = getSwapData(typeTax, i);
                    if(addressesPath.length > 0){
                        // tax in another tokens
                        _balances[address(this)] = SafeMath.add(_balances[addressesTax], amountTax);
                        executeSwapTokens(amountTax,addressesTax,addressSwapRouter, addressesPath);
                    } else {
                        // tax in this tokens
                        _balances[addressesTax] = SafeMath.add(_balances[addressesTax], amountTax);
                        emit Transfer(sender, addressesTax, amountTax);
                    }
                }

            } else if (addressesLiquidity[recipient] && SwapBlock.getPercentsTaxSell().length > 0) {
                // send Tax Sell
                typeTax = 2;

                for (uint i; i < SwapBlock.getPercentsTaxSell().length; i++) {
                    amountTax = amount.div(100).mul(SwapBlock.getPercentsTaxSell()[i]);
                    addressesTax = SwapBlock.getAddressesTaxSell()[i];
                    amountRecipient = amountRecipient.sub(amountTax);

                    (address addressSwapRouter, address[] memory addressesPath) = getSwapData(typeTax, i);
                    if(addressesPath.length > 0){
                        // tax in another tokens
                        _balances[address(this)] = SafeMath.add(_balances[addressesTax], amountTax);
                        executeSwapTokens(amountTax,addressesTax,addressSwapRouter, addressesPath);
                    } else {
                        // tax in this tokens
                        _balances[addressesTax] = SafeMath.add(_balances[addressesTax], amountTax);
                        emit Transfer(sender, addressesTax, amountTax);
                    }
                }

            } else if (SwapBlock.getPercentsTaxTransfer().length > 0) {
                // send Tax Transfer
                typeTax = 3;

                for (uint i; i < SwapBlock.getPercentsTaxTransfer().length; i++) {
                    amountTax = amount.div(100).mul(SwapBlock.getPercentsTaxTransfer()[i]);
                    addressesTax = SwapBlock.getAddressesTaxTransfer()[i];
                    amountRecipient = amountRecipient.sub(amountTax);

                    (address addressSwapRouter, address[] memory addressesPath) = getSwapData(typeTax, i);
                    if(addressesPath.length > 0){
                        // tax in another tokens
                        _balances[address(this)] = SafeMath.add(_balances[addressesTax], amountTax);
                        executeSwapTokens(amountTax,addressesTax,addressSwapRouter, addressesPath);
                    } else {
                        // tax in this tokens
                        _balances[addressesTax] = SafeMath.add(_balances[addressesTax], amountTax);
                        emit Transfer(sender, addressesTax, amountTax);
                    }
                }

            }
        }

        return amountRecipient;
    }

}