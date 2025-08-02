// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {StableCoin} from "./StableCoin.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/data-feeds/interfaces/AggregatorV3Interface.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console2} from "forge-std/console2.sol";

contract DSCEngine is ReentrancyGuard {
    event CollateralDeposited(
        address sender,
        address tokenCollateralAddr,
        uint256 amount
    );

    error DSCEngine__AmountNeedsMoreThenZero();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__DifferntQuantityPriceFeedAndTokens();
    error DSCEngine__TransferFailed();
    error DSCEngine_HealthFactorLessThenOne(uint256 healthFactor);
    error DSCEngine__MintFailed();

    uint256 private constant LIQUIDATION_THRESHOLD = 50;

    mapping(address token => address priceFeed) private s_tokenAddrsToPriceFeed;
    mapping(address user => mapping(address token => uint256 amount))
        private s_collateralDeposited;
    mapping(address user => uint256 amountDcsMinted) private s_dcsMinted;

    address[] private s_collateralTokensAddresses;

    StableCoin private immutable i_dsc;

    modifier moreThenZero(uint256 _amount) {
        if (_amount < 0) {
            revert DSCEngine__AmountNeedsMoreThenZero();
        }
        _;
    }

    modifier isAllowedToken(address _tokenCollateralAddr) {
        if (s_tokenAddrsToPriceFeed[_tokenCollateralAddr] == address(0)) {
            revert DSCEngine__NotAllowedToken();
        }
        _;
    }

    constructor(
        address[] memory tokenAddress,
        address[] memory priceFeedAddress,
        address dscAddress
    ) {
        if (tokenAddress.length != priceFeedAddress.length) {
            revert DSCEngine__DifferntQuantityPriceFeedAndTokens();
        }

        for (uint256 i = 0; i < tokenAddress.length; i++) {
            s_tokenAddrsToPriceFeed[tokenAddress[i]] = priceFeedAddress[i];
            s_collateralTokensAddresses.push(tokenAddress[i]);
        }

        console2.log(
            "ADDERES FOR TOKEN IN DCS ENGINE!!!",
            tokenAddress[0],
            "-----",
            tokenAddress[1]
        );

        console2.log(
            "ADDERES FOR PRICE FEED IN DCS ENGINE!!!",
            priceFeedAddress[0],
            "-----",
            priceFeedAddress[1]
        );
        i_dsc = StableCoin(dscAddress);
    }

    function depositCollateralAndMintDsc() external {}

    function depositCollateral(
        address _tokenCollateralAddr,
        uint256 _amount
    )
        external
        moreThenZero(_amount)
        isAllowedToken(_tokenCollateralAddr)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][_tokenCollateralAddr] += _amount;
        emit CollateralDeposited(msg.sender, _tokenCollateralAddr, _amount);
        bool success = IERC20(_tokenCollateralAddr).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc(
        uint256 _amountDsc
    ) external moreThenZero(_amountDsc) nonReentrant {
        s_dcsMinted[msg.sender] += _amountDsc;
        _revertIfHealthFactorIsBroken(msg.sender);
        bool minted = i_dsc.mint(msg.sender, _amountDsc);
        if (!minted) {
            revert DSCEngine__MintFailed();
        }
    }

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}

    function _revertIfHealthFactorIsBroken(address _user) internal view {
        uint256 userHealthFactor = _healthFactor(_user);
        if (userHealthFactor < 1) {
            revert DSCEngine_HealthFactorLessThenOne(userHealthFactor);
        }
    }

    function _healthFactor(address _user) private view returns (uint256) {
        (
            uint256 totalDsc,
            uint256 collateralValueInUsd
        ) = _getAccountInformation(_user);

        uint256 collateralAdjustedForThreshold = (collateralValueInUsd *
            LIQUIDATION_THRESHOLD) / 100;

        return (collateralAdjustedForThreshold * 1e18) / totalDsc;
    }

    function _getAccountInformation(
        address _user
    ) private view returns (uint256 totalDsc, uint256 collateralValue) {
        totalDsc = s_dcsMinted[_user];
        collateralValue = getAccountCollateralValue(_user);
    }

    function getAccountCollateralValue(
        address _user
    ) public view returns (uint256 totalCollatoralValueInUsd) {
        for (uint256 i = 0; i < s_collateralTokensAddresses.length; i++) {
            address token = s_collateralTokensAddresses[i];
            uint256 amount = s_collateralDeposited[_user][token];
            totalCollatoralValueInUsd += getUsdValue(token, amount);
        }
    }

    function getUsdValue(
        address _token,
        uint256 _amount
    ) public view returns (uint256) {
        console2.log("------IN FUNCTION GTE VALUE USD --------");
        console2.log(_token);
        console2.log(s_tokenAddrsToPriceFeed[_token]);
        console2.log("------OUT FUNCTION GTE VALUE USD --------");
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            s_tokenAddrsToPriceFeed[_token]
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();

        return ((uint256(price) * 1e10) * _amount) / 1e18;
    }
}
