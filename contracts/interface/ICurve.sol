// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ICurve {
    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);
    function add_liquidity(uint256[3] calldata uamounts, uint256 min_mint_amount, bool _use_underlying) external;
}
