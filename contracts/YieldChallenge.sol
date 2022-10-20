// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./VaultAPI.sol";

contract YieldChallenge {

  // The token the user is going to stake and then earn in
  address token;

  // Yearn vault to deposit the token and earn yield
  address vault;

  // the address that is going to be able to submit that the challenge has been completed successfully
  address judge;

  // our treasury
  address treasury;
  
  struct Challenge {
    uint256 deadline;
    uint256 deposited;
    uint256 shares;
    bool isSuccess;
  }

  mapping(address => Challenge) private challenges;

  constructor(address _token, address _vault, address _judge, address _treasury) {
    /*
    initialize the token we are going to use, the yearn vault we will deposit into
    the judge, and the treasury where we will send the reimining yield
    */

    token = _token;
    vault = _vault;
    judge = _judge;
    treasury = _treasury;
  }

  function deposit(uint256 _amount, uint256 _deadline) external {
    /*
    deposit funds from the user and set the deadline to complete the challenge
    */
    require(_amount > 0, "amount has to be > 0");
    require(_deadline > block.timestamp, "deadline has to be in the future");

    if (IERC20(token).transferFrom(msg.sender, address(this), _amount)) {
      
      IERC20(token).approve(vault, _amount);
      uint256 shares = VaultAPI(vault).deposit(_amount);

      challenges[msg.sender] = Challenge(_deadline, _amount, shares, false);
    }

  }

  function submitResult(address _user, bool _status) external {
    /*
    the judge can submit the result of the challenge
    */
    require(msg.sender == judge, "only the judge can judge");
    require(block.timestamp > challenges[_user].deadline, "deadline not met ser");

    challenges[_user].isSuccess = _status;
  }

  function withdraw() external {
    /*
    withdraw your money after the deadline has been met
    if you completed the challenge successfuly, you get the yield
    if not, we keep it 
    */
    require(challenges[msg.sender].deadline > block.timestamp, "patience, deadline not met");

    Challenge memory userChallenge = challenges[msg.sender];

    uint256 totalWithdrew = VaultAPI(vault).withdraw(userChallenge.shares);

    if(userChallenge.isSuccess) { // perfect, you did it! you get your money + yield
      IERC20(token).transfer(msg.sender, totalWithdrew);
    } else { // you didn't succeed, you get your money back, but we keep the yield 
      IERC20(token).transfer(msg.sender, userChallenge.deposited);
      IERC20(token).transfer(treasury, totalWithdrew - userChallenge.deposited);
    }

  }
}