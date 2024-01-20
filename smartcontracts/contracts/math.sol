// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


library MathVol {

    uint256 constant decimals = 10**8;

    function getAbsoluteValue(int256 num) public pure returns (int256) {
        if (num < 0) {
            return -num; // If the number is negative, return its negation
        } else {
            return num;  // If the number is non-negative, return the number itself
        }
    }

    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "Division by zero is not allowed");
        uint256 result = a / b;
        return result;
    }

    function divide(int256 a, int256 b) public pure returns (int256) {
        require(b != 0, "Division by zero is not allowed");
        int256 result = a / b * int256(decimals);
        return result;
    }

    function multiply(int256 a, int256 b) public pure returns (int256) {
        return divide(a * b, int256(decimals) * int256(decimals));
    }

    function applyFixedPoint(int256 a) public pure returns (int256){
        return a * int256(decimals);
    }

    function applyFixedPoint(uint256 a) public pure returns (uint256){
        return a * decimals;
    }
}