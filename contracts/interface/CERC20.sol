// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface CERC20 {
    function mint(uint256 mintAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);
}
