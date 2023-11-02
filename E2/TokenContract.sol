// SPDX-License-Identifier: Unlicenced
pragma solidity 0.8.18;

contract TokenContract {
    address public owner;

    struct Receivers {
        string name;
        uint256 tokens;
    }

    mapping(address => Receivers) public users;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
        users[owner].tokens = 100;
    }

    function double(uint _value) public pure returns (uint) {
        return _value * 2;
    }

    function register(string memory _name) public {
        users[msg.sender].name = _name;
    }

    function giveToken(address _receiver, uint256 _amount) public onlyOwner {
        require(users[owner].tokens >= _amount);
        users[owner].tokens -= _amount;
        users[_receiver].tokens += _amount;
    }

    function buyToken() external payable {
        // This prevents the owner from spending money in case of mistake
        require(msg.sender != owner);

        uint cost = 5 ether;

        // Set at the exact price, so we don't need to return the change
        require(msg.value == cost);

        uint amount = msg.value / cost;
        require(users[owner].tokens >= amount);
        users[owner].tokens -= amount;
        users[msg.sender].tokens += amount;
    }
}
