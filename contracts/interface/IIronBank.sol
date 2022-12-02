// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IIronBank {
    function enterMarkets(address[] memory cTokens)
        external
        returns (uint256[] memory);
}
