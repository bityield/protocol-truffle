pragma solidity 0.6.10;

contract Migrations {
  address public owner = msg.sender;
  uint public lastCompletedMigration;

  modifier restricted() {
    require(
      msg.sender == owner,
      "restricted to owner"
    );
    _;
  }

  function setCompleted(uint completed) public restricted {
    lastCompletedMigration = completed;
  }
}
