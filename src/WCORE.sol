// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import "@openzeppelin/access/Ownable2Step.sol";

import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

/// @notice Minimalist and modern Wrapped Ether implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/WCORE.sol)
/// @author Inspired by WCORE9 (https://github.com/dapphub/ds-weth/blob/master/src/weth9.sol)
contract WCORE is ERC20("Wrapped Core", "WCORE"), Ownable2Step {
    using SafeTransferLib for address;

    event Deposit(address indexed from, uint256 amount);

    event Withdrawal(address indexed to, uint256 amount);

    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);

        msg.sender.safeTransferETH(amount);
    }

   
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }


    receive() external payable virtual {
        deposit();
    }
}
