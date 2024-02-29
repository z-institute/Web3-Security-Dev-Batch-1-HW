// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";

contract DaoToken is ERC20("Dao Token", "DaoToken") {
    address public owner;

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    constructor() {
        owner = msg.sender;
        console.log("DaoToken owner: %s", owner);
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
        _moveDelegates(_delegates[_from], address(0), _amount);
    }

    mapping(address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    function _moveDelegates(address from, address to, uint256 amount) internal {
        if (from != to && amount > 0) {
            if (from != address(0)) {
                uint32 fromNum = numCheckpoints[from];
                uint256 fromOld = fromNum > 0 ? checkpoints[from][fromNum - 1].votes : 0;
                uint256 fromNew = fromOld - amount;
                _writeCheckpoint(from, fromNum, fromOld, fromNew);
            }

            if (to != address(0)) {
                uint32 toNum = numCheckpoints[to];
                uint256 toOld = toNum > 0 ? checkpoints[to][toNum - 1].votes : 0;
                uint256 toNew = toOld + amount;
                _writeCheckpoint(to, toNum, toOld, toNew);
            }
        }
    }

    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;
    mapping(address => uint32) public numCheckpoints;

    function delegates(address _addr) external view returns (address) {
        return _delegates[_addr];
    }

    function delegate(address _addr) external {
        console.log("msg.sender: %s", msg.sender);
        return _delegate(msg.sender, _addr);
    }

    function getVotes(address _addr) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[_addr];
        return nCheckpoints > 0 ? checkpoints[_addr][nCheckpoints - 1].votes : 0;
    }

    function _delegate(address _addr, address delegatee) internal {
        address currentDelegate = _delegates[_addr];
        console.log("Current Delegate: %s", currentDelegate);
        uint256 _addrBalance = balanceOf(_addr);
        console.log("Balance of _addr: %s", _addrBalance);
        _delegates[_addr] = delegatee;
        console.log("_delegates[_addr]: %s", _delegates[_addr]);
        _moveDelegates(currentDelegate, delegatee, _addrBalance);
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {
        uint32 blockNumber = uint32(block.number);

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }
    }
}
