// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundme} from "../../script/DeployFundme.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); // creating a fake user address

    uint256 constant FUNDING_AMOUNT = 0.1 ether;
    uint256 constant NEW_BALANCE = 1 ether;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: FUNDING_AMOUNT}();
        _;
    }

    function setUp() external {
        DeployFundme deployFundme = new DeployFundme();
        fundMe = deployFundme.run();
        vm.deal(USER, NEW_BALANCE); //sets the balance of an address to a new balance
    }

    function testMinimumUsdIsFive() external {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsMsgSender() external {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testfundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountfunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountfunded, FUNDING_AMOUNT);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); // the next transaction is expected to revert this will skip the vm.prank line
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 ownerStartingbalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert

        uint256 ownerEndingBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            ownerEndingBalance,
            ownerStartingbalance + startingFundMeBalance
        );
    }

    function testWithdrawWithMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), FUNDING_AMOUNT); // creates an address that already has a balance
            fundMe.fund{value: FUNDING_AMOUNT}();
        }
        uint256 ownerStartingbalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + ownerStartingbalance ==
                fundMe.getOwner().balance
        );
    }
}
