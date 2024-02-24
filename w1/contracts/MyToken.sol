
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";

contract MyToken is Initializable, ERC20Upgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, UUPSUpgradeable {
    /// Max token limit per request

   uint256 public limit = 100;

/// For rate limiting
   mapping(address => uint256) public userMintableAmountsMap;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __ERC20_init("MyToken", "MTK");
        __Ownable_init(initialOwner);
        __ERC20Permit_init("MyToken");
        __UUPSUpgradeable_init();

        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address _recipient, uint256 _amount) public {
        require(_recipient != address(0), "INVALID_RECIPIENT");
        require(userMintableAmountsMap[_recipient] <= limit, "EXCEEDS_LIMIT");
        userMintableAmountsMap[_recipient] +=1;
        _mint(_recipient, _amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}
