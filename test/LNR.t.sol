// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.13;

import "forge-std/Test.sol";
import "src/interface/iLNR.sol";

contract LNRTest is Test {
    iLNR public LNR = iLNR(0x5564886ca2C518d1964E5FCea4f423b41Db9F561);
    // events
    event Changed(bytes32 _node);
    event PrimaryChanged(bytes32 _node, address _primary);
    function setUp() public {}
    function testOwnerChange() public {
        bytes32 _name32 = bytes32(bytes("ethereum"));
        address _addr = LNR.owner(_name32);
        require(_addr != address(0), "Revert: 0 address detected");
        vm.prank(_addr);
        LNR.transfer(_name32, address(this));
        assertEq(
            LNR.owner(_name32), address(this)
        );
    }
    function testReserveName() public {
        bytes32 _name32 = bytes32(bytes("randomname234"));
        LNR.reserve(_name32);
        assertEq(
            LNR.owner(_name32), address(this)
        );
        LNR.transfer(_name32, address(0xc0de4c0ffeee));
        assertEq(
            LNR.owner(_name32), address(0xc0de4c0ffeee)
        );
    }
    function testSubRegistrar() public {
        bytes32 _name32 = bytes32(bytes("randomname234"));
        LNR.reserve(_name32);
        assertEq(
            LNR.owner(_name32), address(this)
        );
        assertEq(
            LNR.register(_name32), address(0)
        );
        LNR.setSubRegistrar(_name32, address(this));
        assertEq(
            LNR.register(_name32), address(this)
        );
        LNR.setSubRegistrar(_name32, address(type(uint160).max));
        assertEq(
            LNR.register(_name32), address(type(uint160).max)
        );
        LNR.setSubRegistrar(_name32, address(0));
        assertEq(
            LNR.register(_name32), address(0)
        );
    }
    function testAddress() public {
        bytes32 _name32 = bytes32(bytes("randomname234"));
        LNR.reserve(_name32);
        assertEq(
            LNR.owner(_name32), address(this)
        );
        assertEq(
            LNR.addr(_name32), address(0)
        );
        LNR.setAddress(_name32, address(this), false);
        assertEq(
            LNR.addr(_name32), address(this)
        );
        LNR.setAddress(_name32, address(type(uint160).max), false);
        assertEq(
            LNR.addr(_name32), address(type(uint160).max)
        );
        LNR.setAddress(_name32, address(0), false);
        assertEq(
            LNR.addr(_name32), address(0)
        );
    }
    function testContent() public {
        bytes32 _name32 = bytes32(bytes("randomname234"));
        LNR.reserve(_name32);
        assertEq(
            LNR.owner(_name32), address(this)
        );
        assertEq(
            LNR.content(_name32), bytes32(0)
        );
        bytes32 MAX = bytes32(type(uint256).max);
        LNR.setContent(_name32, bytes32(uint(1234567890)));
        assertEq(
            LNR.content(_name32), bytes32(uint(1234567890))
        );
        LNR.setContent(_name32, MAX);
        assertEq(
            LNR.content(_name32), MAX
        );
        LNR.setContent(_name32, bytes32(0));
        assertEq(
            LNR.content(_name32), bytes32(0)
        );
    }
    function testReversePrimary() public {
        bytes32 _name32 = bytes32(bytes("random234"));
        LNR.reserve(_name32);
        assertEq(
            LNR.owner(_name32), address(this)
        );
        assertEq(
            LNR.name(address(this)), bytes32(0) // reverse lookup
        );
        LNR.setAddress(_name32, address(this), true);
        assertEq(
            LNR.addr(_name32), address(this)
        );
        assertEq(
            LNR.name(address(this)), _name32
        );
        LNR.setAddress(_name32, address(0x5564886ca2C518d1964E5FCea4f423b41Db9F561), true);
        assertEq(
            LNR.name(address(0x5564886ca2C518d1964E5FCea4f423b41Db9F561)), _name32
        );
        assertEq(
            LNR.addr(_name32), address(0x5564886ca2C518d1964E5FCea4f423b41Db9F561)
        );
        // bug??? 
        bytes32 _name32a = bytes32(bytes("random567"));
        LNR.reserve(_name32a);
        LNR.setAddress(_name32a, address(0x5564886ca2C518d1964E5FCea4f423b41Db9F561), true);
        assertEq(
            LNR.name(address(0x5564886ca2C518d1964E5FCea4f423b41Db9F561)), _name32a
        );
        assertEq(
            LNR.addr(_name32a), address(0x5564886ca2C518d1964E5FCea4f423b41Db9F561)
        );
    }

}