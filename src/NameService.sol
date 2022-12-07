//SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

interface iENS {
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);
    event Transfer(bytes32 indexed node, address owner);
    event NewResolver(bytes32 indexed node, address resolver);
    event NewTTL(bytes32 indexed node, uint64 ttl);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external;
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external returns(bytes32);
    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
    function setTTL(bytes32 node, uint64 ttl) external;
    function setApprovalForAll(address operator, bool approved) external;

    function owner(bytes32 node) external view returns(address);
    function resolver(bytes32 node) external view returns(address);
    function ttl(bytes32 node) external view returns(uint64);
    function recordExists(bytes32 node) external view returns(bool);
    function isApprovedForAll(address owner, address operator) external view returns(bool);
}

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

contract NameService {
    struct Records{
        address resolver;

    }
    mapping(bytes32 => mapping(bytes32 => uint)) records;
    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external{
        //;
    }

}