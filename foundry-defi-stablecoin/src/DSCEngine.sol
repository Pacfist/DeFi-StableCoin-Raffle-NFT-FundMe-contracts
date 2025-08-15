// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {StableCoin} from "./StableCoin.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/data-feeds/interfaces/AggregatorV3Interface.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console2} from "forge-std/console2.sol";
import {OracleLib} from "./OracleLib.sol";

contract DSCEngine is ReentrancyGuard {
    event CollateralDeposited(
        address indexed sender,
        address indexed tokenCollateralAddr,
        uint256 indexed amount
    );

    event CollateralRedeemed(
        address indexed from,
        address indexed to,
        address indexed tokenCollateralAddr,
        uint256 amount
    );

    error DSCEngine__AmountNeedsMoreThenZero();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__DifferntQuantityPriceFeedAndTokens();
    error DSCEngine__TransferFailed();
    error DSCEngine_HealthFactorLessThenOne(uint256 healthFactor);
    error DSCEngine__MintFailed();
    error DSCEngine__HealthFactorOk();
    error DSCEngine__HealthFactorDoesNotImproved();

    using OracleLib for AggregatorV3Interface;

    uint256 private constant LIQUIDATION_THRESHOLD = 50;

    mapping(address token => address priceFeed) private s_tokenAddrsToPriceFeed;
    mapping(address user => mapping(address token => uint256 amount))
        private s_collateralDeposited;
    mapping(address user => uint256 amountDcsMinted) private s_dcsMinted;

    address[] private s_collateralTokensAddresses;

    StableCoin private immutable i_dsc;

    modifier moreThenZero(uint256 _amount) {
        if (_amount == 0) {
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
        i_dsc = StableCoin(dscAddress);
    }

    function depositCollateralAndMintDsc(
        address _tokenCollateralAddr,
        uint256 _amountCollateral,
        uint256 _amountDsc
    ) external {
        depositCollateral(_tokenCollateralAddr, _amountCollateral);
        mintDsc(_amountDsc);
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function depositCollateral(
        address _tokenCollateralAddr,
        uint256 _amount
    )
        public
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

    function redeemCollateralForDsc(
        address _tokenCollateral,
        uint256 _amountCollateral,
        uint256 _amountDsc
    ) external {
        burnDsc(_amountDsc);
        redeemCollateral(_tokenCollateral, _amountCollateral);
    }

    function redeemCollateral(
        address _tokenCollateral,
        uint256 _amount
    ) public moreThenZero(_amount) nonReentrant {
        _redeemCollateral(_tokenCollateral, _amount, msg.sender, msg.sender);
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function mintDsc(
        uint256 _amountDsc
    ) public moreThenZero(_amountDsc) nonReentrant {
        s_dcsMinted[msg.sender] += _amountDsc;
        _revertIfHealthFactorIsBroken(msg.sender);
        bool minted = i_dsc.mint(msg.sender, _amountDsc);
        if (!minted) {
            revert DSCEngine__MintFailed();
        }
    }

    function burnDsc(uint256 _amount) public moreThenZero(_amount) {
        _burnDsc(_amount, msg.sender, msg.sender);
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function liquidate(
        address _collateral,
        address _user,
        uint256 _debtToCover
    ) external moreThenZero(_debtToCover) nonReentrant {
        uint256 startingUserHealthFactor = _healthFactor(_user);
        if (startingUserHealthFactor >= 1e18) {
            revert DSCEngine__HealthFactorOk();
        }

        uint256 tokenAmountFromDebtCovered = getTokenAmountFromUsd(
            _collateral,
            _debtToCover
        );

        uint256 bonus = (tokenAmountFromDebtCovered * 10) / 100;
        uint256 totalCollateral = tokenAmountFromDebtCovered + bonus;

        _redeemCollateral(_collateral, totalCollateral, _user, msg.sender);
        _burnDsc(_debtToCover, _user, msg.sender);

        uint256 endingHealthFactor = _healthFactor(_user);
        if (endingHealthFactor <= startingUserHealthFactor) {
            revert DSCEngine__HealthFactorDoesNotImproved();
        }
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function getHealthFactor(address _user) external view returns (uint256) {
        return _healthFactor(_user);
    }

    function _revertIfHealthFactorIsBroken(address _user) internal view {
        uint256 userHealthFactor = _healthFactor(_user);
        console2.log("USER HEALTH FACTOR: ", userHealthFactor);
        if (userHealthFactor < 1e18) {
            revert DSCEngine_HealthFactorLessThenOne(userHealthFactor);
        }
    }

    function _healthFactor(address _user) private view returns (uint256) {
        (
            uint256 totalDsc,
            uint256 collateralValueInUsd
        ) = _getAccountInformation(_user);

        if (totalDsc == 0) {
            return type(uint256).max; // no debt -> maximally safe
        }

        console2.log("-------------------");

        console2.log(
            "IN THE _HEALTHFACTOR collateralValueInUsd is: ",
            collateralValueInUsd
        );

        console2.log("IN THE _HEALTHFACTOR totalDsc is: ", totalDsc);

        uint256 adjCollateral = (collateralValueInUsd * 50) / 100;

        uint256 hf = (adjCollateral * 1e18) / (totalDsc * 1e18);

        console2.log("IN THE _HEALTHFACTOR hf is: ", hf);

        return hf;
    }

    function _getAccountInformation(
        address _user
    ) private view returns (uint256 totalDsc, uint256 collateralValue) {
        totalDsc = s_dcsMinted[_user];
        collateralValue = getAccountCollateralValue(_user);
    }

    function _redeemCollateral(
        address _tokenCollateral,
        uint256 _amount,
        address _from,
        address _to
    ) private moreThenZero(_amount) {
        console2.log(
            "IN THE ENGINE USER AMOUNT: ",
            s_collateralDeposited[_from][_tokenCollateral]
        );
        console2.log("IN THE ENGINE AMOUNT TO REDEEM: ", _amount);
        s_collateralDeposited[_from][_tokenCollateral] -= _amount;

        emit CollateralRedeemed(_from, _to, _tokenCollateral, _amount);
        bool success = IERC20(_tokenCollateral).transfer(_to, _amount);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function _burnDsc(
        uint256 amountToBurn,
        address onBehalfOf,
        address dscFrom
    ) private {
        s_dcsMinted[onBehalfOf] -= amountToBurn;

        bool success = i_dsc.transferFrom(dscFrom, address(this), amountToBurn);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
        i_dsc.burn(amountToBurn);
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
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            s_tokenAddrsToPriceFeed[_token]
        );
        (, int256 price, , , ) = priceFeed.staleCheckLatestRoundData();
        console2.log("IN ENGINE IN GETUSDVAL PRICE: ", price);
        return ((uint256(price) * 1e10) * _amount) / 1e18;
    }

    function getCollateralTokenPriceFeed(
        address token
    ) external view returns (address) {
        return s_tokenAddrsToPriceFeed[token];
    }

    function getTokenAmountFromUsd(
        address _token,
        uint256 _usdAmountWei
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            s_tokenAddrsToPriceFeed[_token]
        );
        (, int256 price, , , ) = priceFeed.staleCheckLatestRoundData();
        return ((_usdAmountWei * 1e18) / (uint256(price) * 1e10));
    }

    function getAccountInformation(
        address _user
    ) public view returns (uint256 totalDsc, uint256 collateralValue) {
        return _getAccountInformation(_user);
    }

    function getTokenAmount(
        address _user,
        address _token
    ) public view returns (uint256) {
        return s_collateralDeposited[_user][_token];
    }

    function getCollateralTokens() external view returns (address[] memory) {
        return s_collateralTokensAddresses;
    }
}
