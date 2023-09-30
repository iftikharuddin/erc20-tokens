// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {OurToken} from "../src/OurToken.sol";
import {Test} from "forge-std/Test.sol";
import {DeployOurTokenScript} from "../script/DeployOurTokenScript.s.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is Test {

    OurToken public ourToken;
    DeployOurTokenScript public deployer;

    address john = makeAddr("john");
    address red = makeAddr("red");

    uint256 public constant S_B = 100 ether; // starting balance

    function setUp() public {
        deployer = new DeployOurTokenScript();
        ourToken = deployer.run();

        vm.prank(msg.sender); // contract deployer
        ourToken.transfer(john, S_B); // let's give john 100 ether
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testJohnBalance() public {
        assertEq(S_B, ourToken.balanceOf(john));
    }

    function testAllowanceWorks() public {
        uint256 initialAllowance = 1000;
        // John approves Red to spend on his behalf
        vm.prank(john);
        ourToken.approve(red, initialAllowance);

        uint256 transferAmount = 500;
        vm.prank(red);
        ourToken.transferFrom(john, red, transferAmount);
        //ourToken.transfer(red, transferAmount); // in transfer who ever is calling the func is auto set to from

        //assertEq(ourToken.balanceOf(john), );
        assertEq(ourToken.balanceOf(red), transferAmount);
    }

    function testTransfers() public {
        address recipient = address(this);
        uint256 transferAmount = 50;
        vm.prank(msg.sender);
        assert(ourToken.transfer(recipient, transferAmount));

        uint256 balanceRecipient = ourToken.balanceOf(recipient);
        //uint256 balanceOwner = ourToken.balanceOf(address(msg.sender));

        assertEq(balanceRecipient, transferAmount, "Recipient balance not updated correctly");
        //assertEq(balanceOwner, deployer.INITIAL_SUPPLY() - transferAmount, "Owner balance not updated correctly");
    }

}