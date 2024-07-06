// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Greetings{
    string message="Hello World";

    function greet() external view returns (string memory){
        return message;
    }

    function setGreetingMessage(string memory _msg) external{
        message = _msg;
    }
}