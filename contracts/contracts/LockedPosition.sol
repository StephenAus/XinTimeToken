pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
// 锁仓认购期的账户
contract LockedPosition is ERC20, Ownable {

    mapping (address => uint256) private _partners;
    mapping (address => uint256) private _release;

    bool public publish = false;
    uint256 public released = 0;

    /**
    * @dev update account to partner list
    * @return 
    */
    function partner(address from, address to, uint256 value) internal {
        require(from != address(0), "The from address is empty");
        require(to != address(0), "The to address is empty");

        if(publish){
            // 已发行
            _release[from] = _release[from].add(value);
        }else{
            // 未发行
            if(owner() != from){
                _partners[from] = _partners[from].sub(value);
            }
            if(owner() != to){
                _partners[to] = _partners[to].add(value);
            }
        }
    }
    /**
     * @dev check an account position
     * @return bool
     */
    function checkPosition(address account, uint256 value) internal view returns (bool) {
        require(account != address(0), "The account address is empty");
        // 发行人，不限制
        if (isOwner()){
            return true;
        } 
        // 未发行，未锁仓，不限制
        if (!publish){
            return true;
        } 
        // 放开率100%，不限制
        if (released >= 100) {
            return true;
        }
        // 锁仓之后的交易地址，不限制
        if(_partners[account]==0){
            return true;
        }
        // 已经发行，锁定
        return ((_partners[account]/100) * released) >= _release[account] + value;
    }

    /**
     * @dev locked partners account
     * @return 
     */
    function locked() external onlyOwner {
        publish = true;
    }
    /**
     * @dev release position
     * @return 
     */
    function release(uint256 percent) external onlyOwner {
        require(percent <= 100 && percent > 0, "The released must be between 0 and 100");
        released = percent;
    }
     /**
     * @dev get account position
     * @return bool
     */
    function getPosition() external view returns(uint256) {
        return _partners[msg.sender];
    }

    /**
     * @dev get account release
     * @return bool
     */
    function getRelease() external view returns(uint256) {
        return _release[msg.sender];
    }

    /**
     * @dev get account position
     * @return bool
     */
    function positionOf(address account) external onlyOwner view returns(uint256) {
        require(account != address(0), "The account address is empty");
        return _partners[account];
    }

    /**
     * @dev get account release
     * @return bool
     */
    function releaseOf(address account) external onlyOwner view returns(uint256) {
        require(account != address(0), "The account address is empty");
        return _release[account];
    }
    
    
    function transfer(address to, uint256 value) public returns (bool) {
        require(checkPosition(msg.sender, value), "Insufficient positions");

        partner(msg.sender, to, value);

        return super.transfer(to, value);
    }

    function transferFrom(address from,address to, uint256 value) public returns (bool) {
        require(checkPosition(from, value), "Insufficient positions");

        partner(from, to, value);

        return super.transferFrom(from, to, value);
    }
}

