// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundme} from "../../script/DeployFundme.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); // creating a fake user address

    uint256 constant FUNDING_AMOUNT = 0.1 ether;
    uint256 constant NEW_BALANCE = 10 ether;

    function setUp() external {
        DeployFundme deployFundme = new DeployFundme();
        fundMe = deployFundme.run();
        vm.deal(USER, NEW_BALANCE); //sets the balance of an address to a new balance
    }

    function testUserCanFundIntergation() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
