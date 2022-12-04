// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IWETH {
    function balanceOf(address account) external view returns (uint256);

    function withdraw(uint256 amount) external;
}
