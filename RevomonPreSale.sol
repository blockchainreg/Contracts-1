pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
 


/**
 * @title ERC1132 interface
 * @dev see https://github.com/ethereum/EIPs/issues/1132
 */

abstract contract ERC1132 {
    /**
     * @dev Reasons why a user's tokens have been locked
     */
    mapping(address => bytes32[]) public lockReason;

    /**
     * @dev locked token structure
     */
    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    /**
     * @dev Holds number & validity of tokens locked for a given reason for
     *      a specified address
     */
    mapping(address => mapping(bytes32 => lockToken)) public locked;

    /**
     * @dev Records data of all the tokens Locked
     */
    event Locked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount,
        uint256 _validity
    );

    /**
     * @dev Records data of all the tokens unlocked
     */
    event Unlocked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount
    );
    
    /**
     * @dev Locks a specified amount of tokens against an address,
     *      for a specified reason and time
     * @param _reason The reason to lock tokens
     * @param _amount Number of tokens to be locked
     * @param _time Lock time in seconds
     */
    function lock(string memory _reason, uint256 _amount, uint256 _time)
        public virtual returns (bool);
  
    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason
     *
     * @param _of The address whose tokens are locked
     * @param _reason The reason to query the lock tokens for
     */
    function tokensLocked(address _of, string memory _reason)
        public virtual view returns (uint256 amount);
    
    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason at a specific time
     *
     * @param _of The address whose tokens are locked
     * @param _reason The reason to query the lock tokens for
     * @param _time The timestamp to query the lock tokens for
     */
    function tokensLockedAtTime(address _of, string memory _reason, uint256 _time)
        public virtual view returns (uint256 amount);
    
    /**
     * @dev Returns total tokens held by an address (locked + transferable)
     * @param _of The address to query the total balance of
     */
    function totalBalanceOf(address _of)
        public virtual view returns (uint256 amount);
    
    /**
     * @dev Extends lock for a specified reason and time
     * @param _reason The reason to lock tokens
     * @param _time Lock extension time in seconds
     */
    function extendLock(string memory _reason, uint256 _time)
        public virtual returns (bool);
    
    /**
     * @dev Increase number of tokens locked for a specified reason
     * @param _reason The reason to lock tokens
     * @param _amount Number of tokens to be increased
     */
    function increaseLockAmount(string memory _reason, uint256 _amount)
        public virtual returns (bool);

    /**
     * @dev Returns unlockable tokens for a specified address for a specified reason
     * @param _of The address to query the the unlockable token count of
     * @param _reason The reason to query the unlockable tokens for
     */
    function tokensUnlockable(address _of, string memory _reason)
        public virtual view returns (uint256 amount);
 
    /**
     * @dev Unlocks the unlockable tokens of a specified address
     * @param _of Address of user, claiming back unlockable tokens
     */
    function unlock(address _of)
        public virtual returns (uint256 unlockableTokens);

    /**
     * @dev Gets the unlockable tokens of a specified address
     * @param _of The address to query the the unlockable token count of
     */
    function getUnlockableTokens(address _of)
        public virtual view returns (uint256 unlockableTokens);

}

interface IRevoTokenContract{
  function balanceOf(address account) external view returns (uint256);
  function totalSupply() external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
}



contract RevoPreSaleContract is Ownable {
    using SafeMath for uint;
    
    uint256 public tokenPurchased;
    uint256 public contributors;
    bool public isListingDone;
    
    // Price calculed with ETH pegged at 1800 USDT.
    uint256 public constant BASE_PRICE_IN_WEI = 61111111111111;
    
    bool public isWhitelistEnabled = true;
    uint256 public minWeiPurchasable = 500000000000000000;
    mapping (bytes=>bool) public whitelistedAddresses;
    mapping (bytes=>uint256) public whitelistedAddressesCap;
    mapping (address=>bool) public salesDonePerUser;
    IRevoTokenContract private token;
    IRevoTokenContract private usdtToken;
    uint256 public tokenCap;
    bool public started = true;
  
   /**
    * @dev Error messages for require statements
    */
    string internal constant ALREADY_LOCKED = 'Tokens already locked';
    string internal constant NOT_LOCKED = 'No tokens locked';
    string internal constant AMOUNT_ZERO = 'Amount can not be 0';
    
    mapping(address => bytes32[]) public lockReason;

    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    mapping(address => mapping(bytes32 => lockToken)) public locked;

    event Locked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount,
        uint256 _validity
    );

    event Unlocked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount
    );

   /**
    * @dev constructor to mint initial tokens
    * Shall update to _mint once openzepplin updates their npm package.
    */
    constructor(address dotxTokenAddress, address usdtAddress) public {
        token = IRevoTokenContract(dotxTokenAddress);
        usdtToken = IRevoTokenContract(usdtAddress);
    }
    /**
   * Low level token purchase function
   */
    function buyTokens(uint256 amountUSDTInWei) public payable validPurchase{
        salesDonePerUser[msg.sender] = true;
        
        uint256 tokenCount = amountUSDTInWei/BASE_PRICE_IN_WEI;

        tokenPurchased = tokenPurchased.add(tokenCount);
    
        contributors = contributors.add(1);
    
        forwardFunds(amountUSDTInWei);
        
        //Lock 
        uint lockAmountStage = calculatePercentage(amountUSDTInWei, 20, 1000000);
        lock("lock_1", lockAmountStage, 0); //First unlock at listing
        lock("lock_2", lockAmountStage, 2419200); //Second unlock 28 days after the pre-sale - 28 * 86400 = 2419200
        lock("lock_3", lockAmountStage, 3628800); //Third unlock 42 days after the pre-sale - 42 * 86400 = 3628800
        lock("lock_4", lockAmountStage, 4838400); //Fourht unlock 56 days after the pre-sale - 56 * 86400 = 4838400
        lock("lock_5", lockAmountStage, 6048000); //Fifth unlock 70 days after the pre-sale - 70 * 86400 = 6048000
    }
    
    modifier validPurchase() {
        require(started);
        require(!isWhitelistEnabled || whitelistedAddresses[getSlicedAddress(msg.sender)] == true);
        require(msg.value >= minWeiPurchasable);
        require(msg.value <= (whitelistedAddressesCap[getSlicedAddress(msg.sender)]).mul(10**18));
        require(salesDonePerUser[msg.sender] == false);
        _;
    }

    /**
    * Forwards funds to the tokensale wallet
    */
    function forwardFunds(uint256 amount) internal {
        usdtToken.transferFrom(msg.sender, address(owner()), amount);
    }


    function enableWhitelistVerification() public onlyOwner {
        isWhitelistEnabled = true;
    }
    
    function disableWhitelistVerification() public onlyOwner {
        isWhitelistEnabled = false;
    }
    
    function changeMinWeiPurchasable(uint256 value) public onlyOwner {
        minWeiPurchasable = value;
    }
    
    function changeStartedState(bool value) public onlyOwner {
        started = value;
    }
    
    function addToWhitelistPartners(bytes[] memory _addresses, uint256[] memory _maxCaps) public onlyOwner {
        for(uint256 i = 0; i < _addresses.length; i++) {
            whitelistedAddresses[_addresses[i]] = true;
            updateWhitelistAdressCap(_addresses[i], _maxCaps[i]);
        }
    }
    
    function updateWhitelistAdressCap(bytes memory _address, uint256 _maxCap) public onlyOwner {
        whitelistedAddressesCap[_address] = _maxCap;
    }

    function addToWhitelist(bytes memory _address) public onlyOwner {
        whitelistedAddresses[_address] = true;
        whitelistedAddressesCap[_address] = 5;
    }
    
    function addToWhitelist(bytes[] memory addresses) public onlyOwner {
        for(uint i = 0; i < addresses.length; i++) {
            addToWhitelist(addresses[i]);
        }
    }
    
    function isAddressWhitelisted(address _address) view public returns(bool) {
        return !isWhitelistEnabled || whitelistedAddresses[getSlicedAddress(_address)] == true;
    }
    
    function withdrawTokens(uint256 amount) public onlyOwner {
        token.transfer(owner(), amount);
    }
    
    function getSlicedAddress(address _address) public pure returns(bytes memory) {
        bytes memory addressBytes = abi.encodePacked(_address);
        bytes memory addressSliced = sliceAddress(addressBytes);
        return addressSliced;
    }
    
    function sliceAddress(bytes memory addrBytes) private pure returns(bytes memory) {
        return abi.encodePacked(addrBytes[0], addrBytes[1], addrBytes[7], addrBytes[19]);
    }
    
    function setListingDone(bool isDone) public onlyOwner {
        isListingDone = isDone;
    }
    
    /*
        LOCK PART
    */

    /**
     * @dev Locks a specified amount of tokens against an address,
     *      for a specified reason and time
     * @param _reason The reason to lock tokens
     * @param _amount Number of tokens to be locked
     * @param _time Lock time in seconds
     */
    function lock(string memory _reason, uint256 _amount, uint256 _time) private returns (bool) {
        bytes32 reason = stringToBytes32(_reason);
        uint256 validUntil = now.add(_time); //solhint-disable-line

        // If tokens are already locked, then functions extendLock or
        // increaseLockAmount should be used to make any changes
        require(tokensLocked(msg.sender, bytes32ToString(reason)) == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);

        if (locked[msg.sender][reason].amount == 0)
            lockReason[msg.sender].push(reason);

        token.transferFrom(msg.sender, address(this), _amount);

        locked[msg.sender][reason] = lockToken(_amount, validUntil, false);

        emit Locked(msg.sender, reason, _amount, validUntil);
        return true;
    }
    
    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason
     *
     * @param _of The address whose tokens are locked
     * @param _reason The reason to query the lock tokens for
     */
    function tokensLocked(address _of, string memory _reason) public view returns (uint256 amount) {
        bytes32 reason = stringToBytes32(_reason);
        if (!locked[_of][reason].claimed)
            amount = locked[_of][reason].amount;
    }

    /**
     * @dev Returns total tokens held by an address (locked + transferable)
     * @param _of The address to query the total balance of
     */
    function totalBalanceOf(address _of) public view returns (uint256 amount) {
        amount = token.balanceOf(_of);

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            amount = amount.add(tokensLocked(_of, bytes32ToString(lockReason[_of][i])));
        }   
    }    

    /**
     * @dev Returns unlockable tokens for a specified address for a specified reason
     * @param _of The address to query the the unlockable token count of
     * @param _reason The reason to query the unlockable tokens for
     */
    function tokensUnlockable(address _of, string memory _reason) public view returns (uint256 amount) {
        bytes32 reason = stringToBytes32(_reason);
        if (locked[_of][reason].validity <= now && !locked[_of][reason].claimed) //solhint-disable-line
            amount = locked[_of][reason].amount;
    }

    /**
     * @dev Unlocks the unlockable tokens of a specified address
     */
    function unlock() public returns (uint256 unlockableTokens) {
        require(isListingDone, "Listing not done");
        
        uint256 lockedTokens;

        for (uint256 i = 0; i < lockReason[msg.sender].length; i++) {
            lockedTokens = tokensUnlockable(msg.sender, bytes32ToString(lockReason[msg.sender][i]));
            if (lockedTokens > 0) {
                unlockableTokens = unlockableTokens.add(lockedTokens);
                locked[msg.sender][lockReason[msg.sender][i]].claimed = true;
                emit Unlocked(msg.sender, lockReason[msg.sender][i], lockedTokens);
            }
        }  

        if (unlockableTokens > 0)
            token.transfer(msg.sender, unlockableTokens);
    }

    /**
     * @dev Gets the unlockable tokens of a specified address
     * @param _of The address to query the the unlockable token count of
     */
    function getUnlockableTokens(address _of) public view returns (uint256 unlockableTokens) {
        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            unlockableTokens = unlockableTokens.add(tokensUnlockable(_of, bytes32ToString(lockReason[_of][i])));
        }  
    }
    
    function getremainingLockTime(address _of, string memory _reason) public view returns (uint256 remainingTime) {
        bytes32 reason = stringToBytes32(_reason);
        if (locked[_of][reason].validity > now && !locked[_of][reason].claimed) //solhint-disable-line
            remainingTime = locked[_of][reason].validity.sub(now);
    }
    
    function getremainingLockDays(address _of, string memory _reason) public view returns (uint256 remainingDays) {
        bytes32 reason = stringToBytes32(_reason);
        if (locked[_of][reason].validity > now && !locked[_of][reason].claimed) //solhint-disable-line
            remainingDays = (locked[_of][reason].validity.sub(now)) / 86400;
    }
    
    /*
    UTILS
    */
    
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function bytes32ToString(bytes32 x) public pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint256 j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
    
    function calculatePercentage(uint256 amount, uint256 percentage, uint256 precision) public pure returns(uint256){
        return amount.mul(precision).mul(percentage).div(100).div(precision);
    }
}