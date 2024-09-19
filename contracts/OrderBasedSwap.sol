// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract OrderBasedSwap {
    struct Deposit {
        address depositor;
        address tokenToDeposit;
        uint256 amount;
        address tokenDesired;
        uint256 price;
        bool active;
    }

    mapping(address => Deposit[]) public deposits;

    event DepositCreated(address indexed depositor, address tokenToDeposit, uint256 amount, address tokenDesired, uint256 price);
    event DepositFulfilled(address indexed depositor, address indexed buyer, address tokenToDeposit, uint256 amount, address tokenDesired, uint256 totalPrice);
    event DepositCancelled(address indexed depositor, uint256 index);

    
    function depositTokens(address _tokenToDeposit, uint256 _amount, address _tokenDesired, uint256 _price) public {
        // Transfer tokens from the depositor to this contract
        // (Assuming the token follows ERC20 standards)
        require(IERC20(_tokenToDeposit).transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        Deposit memory newDeposit = Deposit({
            depositor: msg.sender,
            tokenToDeposit: _tokenToDeposit,
            amount: _amount,
            tokenDesired: _tokenDesired,
            price: _price,
            active: true
        });

        deposits[msg.sender].push(newDeposit);
        emit DepositCreated(msg.sender, _tokenToDeposit, _amount, _tokenDesired, _price);
    }

    // Fulfills an active deposit
    function fulfillDeposit(address _depositor, uint256 _index) public {
        Deposit storage deposit = deposits[_depositor][_index];
        require(deposit.active, "Deposit is not active");
        
        uint256 totalPrice = deposit.price * deposit.amount;

        require(IERC20(deposit.tokenDesired).transferFrom(msg.sender, deposit.depositor, totalPrice), "Payment failed");

        
        require(IERC20(deposit.tokenToDeposit).transfer(msg.sender, deposit.amount), "Token transfer failed");

        deposit.active = false; // Mark deposit as fulfilled
        emit DepositFulfilled(deposit.depositor, msg.sender, deposit.tokenToDeposit, deposit.amount, deposit.tokenDesired, totalPrice);
    }

    
    function cancelDeposit(uint256 _index) public {
        Deposit storage deposit = deposits[msg.sender][_index];
        require(deposit.active, "Deposit is not active");

        deposit.active = false; // Mark deposit as inactive
        emit DepositCancelled(msg.sender, _index);
    }
}
