pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

// 控制代币的流动性
contract LiquidityControl is Ownable {

    mapping (address => bool) private _controls;
    /**
     * @dev lock liquidity
     * @return 
     */
    function lock(address account) external onlyOwner {
        require(account != address(0), "The account address is empty");
        require(!hasLock(account), "The account has been locked");
        require(account != owner(), "The owner cannot be locked");
        
        _controls[account] = true;
    }
    /**
     * @dev unlock
     * @return 
     */
    function unlock(address account) external onlyOwner {
        require(account != address(0),"The account address is empty");
        require(hasLock(account), "No account found");
        require(account != owner(), "The owner cannot be locked");

        _controls[account] = false;
    }
     /**
     * @dev check an account in liquidity list
     * @return bool
     */
    function hasLock(address account) public view returns (bool) {
        require(account != address(0), "The account address is empty");
        return _controls[account];
    }
}

