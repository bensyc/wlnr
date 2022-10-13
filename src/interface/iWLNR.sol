//SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;
interface iWLNR {
    function Dev() external view returns(address);
    function totalSupply() external view returns(uint);
    function NH2ID(bytes32 nh) external view returns(uint);
}