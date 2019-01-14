pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "./LockedPosition.sol";

contract XinTimeToken is ERC20Detailed, LockedPosition {
    uint256 private constant INITIAL_SUPPLY = 2 * (10**8) * (10**18);

    constructor () public ERC20Detailed("Xin Time Token", "XTT", 18){
        _mint(msg.sender, INITIAL_SUPPLY);
        emit Transfer(address(0), msg.sender, totalSupply());
    }

}
