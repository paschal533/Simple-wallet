pragma solidity ^0.5.13;

import "./Allowance.sol";
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol';

contract Allowance is Ownable{
  using SafeMath for uint;
  event AllowanceChanged(address indexed _forWho, address indexed _fromWhom, uint _oldAmount, uint _newAmount)
  mapping(address => uint) public allowance;

  function addAllowance(address _who, uint _amount) public onlyOwner {
    emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
    allowance[_who] = _amount;
  }

  function checkAllowance(address _who) view public returns(uint) {
    return allowance[_who];
  }

  modifier ownerOrAllowed(uint _amount) {
    require(isOwner(), allowance[msg.sender] >= _amount, "You are not allowed");
    _;
  }

  function reduceAllowance(address _who, uint _amount) internal {
    emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who].sub(_amount));
    allowance[_who] = allowance[_who].sub(_amount);
  }

}

contract SimpleWallet is Allowance {
  event MoneySent(address _beneficiary, address _sender, uint _amount);
  event MoneyReceived(address indexed from, uint _amount);

  function withdrawMoney(address payable _to, uint _amount ) public ownerOrAllowed(_amount) {
    require(_amount <= address(this).balance, "there are not enought fund stored in this smart contract");
    if(!isOwner()) {
      reduceAllowance(msg.sender, _amount);
    }
    emit MoneySent(_to, msg.sender, _amount);
    _to.transfer(_amount);
  }

  function renounceOwnership() public onlyOwner {
    revert("Can't renounce ownership here")
  }
  
  function () external payable {
    emit MoneyReceived(msg.sender, msg.value);
  }
}
