//SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

interface iWLNR {
    function Dev() external view returns(address);
    function totalSupply() external view returns(uint);
    function Namehash2ID(bytes32 namehash) external view returns(uint);
}