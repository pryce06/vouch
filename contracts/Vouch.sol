pragma solidity ^0.4.18;

import "./Voucher.sol";


contract Vouch is Voucher (10000) {

    uint public standardDeposit = 100;

    event ConnectionMade (address account1, address account2);

    mapping (address => uint) public IdentityFundBalance;
    mapping (address => mapping (address => bool)) public approvedConnections;
    mapping (address => mapping (address => bool)) public verifiedConnections;

    function Vouch () public {}

    function makeConnection (address target) public returns (bool) {
        approvedConnections[msg.sender][target] = true;
        return true;
    }

    function verify (address user1, address user2) public returns (bool) {
        require ((approvedConnections[user1][user2]) && (approvedConnections[user2][user1]));
        require ((!isFrozen[user1]) && (!isFrozen[user2]));
        require (balances[user1] > standardDeposit);
        require (balances[user2] > standardDeposit);
        balances[user1] -= standardDeposit;
        balances[user2] -= standardDeposit;
        IdentityFundBalance[user1] += standardDeposit;
        IdentityFundBalance[user2] += standardDeposit;
        verifiedConnections[user1][user2] = true;
        verifiedConnections[user2][user1] = true;
        emit ConnectionMade (user1, user2);
        return true;
    }

    function disconnect (address user1, address user2) internal {
        require ((user1 == msg.sender) || (user2 == msg.sender));
        approvedConnections[user1][user2] = false;
        approvedConnections[user2][user1] = false;
        balances[user1] += standardDeposit;
        balances[user2] += standardDeposit;
        IdentityFundBalance[user1] -= standardDeposit;
        IdentityFundBalance[user2] -= standardDeposit;
    }

    function getIdentityFundBalance (address addr) public view returns (uint) {
        return IdentityFundBalance[addr];
    }

    function getConnectionStatus (address user1, address user2) public view returns (bool) {
        return approvedConnections[user1][user2];
    }
}
