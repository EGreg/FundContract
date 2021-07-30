// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IFundContract.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract FundFactory is OwnableUpgradeable, ReentrancyGuardUpgradeable {
   
    address contractInstance;
    event Produced(address caller, address addr);
  
    function init(address _contractInstance) public initializer  {
        __Ownable_init();
        contractInstance = _contractInstance;
    }
    
     /**
     * @param _sellingToken address of erc20 token
     * @param _timestamps array of timestamps
     * @param _prices price exchange
     * @param _endTime after this time exchange stop
     * @param _thresholds thresholds
     * @param _bonuses bonuses
     */
    function produce(
        address _sellingToken,
        uint256[] memory _timestamps,
        uint256[] memory _prices,
        uint256 _endTime,
        uint256[] memory _thresholds,
        uint256[] memory _bonuses
    ) 
        public 
        nonReentrant
        returns(address) 
    {
        
        address proxy = createClone(address(contractInstance));
        
        IFundContract(proxy).init(
            _sellingToken,
            _timestamps,
            _prices,
            _endTime,
            _thresholds,
            _bonuses
        );

        emit Produced(msg.sender, proxy);
        
        OwnableUpgradeable(proxy).transferOwnership(msg.sender);
        
        return proxy;
    }
    
    function createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }
    
}
