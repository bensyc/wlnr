//SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;
/// @notice
interface iLNR {
    function reserve(bytes32 _node) external;
    function transfer(bytes32 _node, address _newOwner) external;
    function disown(bytes32 _node) external;
    function setContent(bytes32 _node, bytes32 _hash) external;
    function setSubRegistrar(bytes32 _node, address _addr) external;
    function setAddress(bytes32 _node, address _addr, bool _primary) external;
    
    // view functions
    function name(address _addr) external view returns(bytes32);
    function owner(bytes32 _node) external view returns(address);
    function content(bytes32 _node) external view returns(bytes32);
    function addr(bytes32 _node) external view returns(address);
    function register(bytes32 _node) external view returns(address);
    
    // ?? what is Registrar ?function? 0
    //function Registrar() external view returns(bytes32);
    // ???
    //function subRegistrar(bytes32 _node) external view returns(address);
    //function triggerFallback(bytes32 _node) external view returns(bytes32);
    
    // events
    event Changed(bytes32 _node);
    event PrimaryChanged(bytes32 _node,address _primary);
}