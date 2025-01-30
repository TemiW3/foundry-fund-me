// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundme} from "../script/DeployFundme.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundme deployFundme = new DeployFundme();
        fundMe = deployFundme.run();
    }

    function testMinimumUsdIsFive() external {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsMsgSender() external {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testfundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        fundMe.fund{value: 10 * 10 ** 18}();
    }
}
