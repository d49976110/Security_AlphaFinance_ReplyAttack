// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IWERC20 {
    function mint(address token, uint256 amount) external;

    function setApprovalForAll(address operator, bool approved) external;
}
