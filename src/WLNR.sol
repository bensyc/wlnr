//SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "src/ERC721.sol";
interface iOverloadResolver {
    function addr(bytes32 node, uint256 coinType) external view returns(bytes memory);
}
interface iResolver {
    function contenthash(bytes32 node) external view returns(bytes memory);
    function addr(bytes32 node) external view returns(address payable);
    function pubkey(bytes32 node) external view returns(bytes32 x, bytes32 y);
    function text(bytes32 node, string calldata key) external view returns(string memory);
    function name(bytes32 node) external view returns(string memory);
}

/**
 * @author 0xc0de4c0ffee, sshmatrix (BeenSick Labs/BENSYC)
 * @title Wrapped Linagee Name Registrar
 */
contract WLNR is ERC721 {
    //using LibString for uint;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    //mapping(bytes32 => bytes) public b32ToBytes;
    mapping(bytes32 => uint) public Namehash2ID;
    address public DefaultResolver;
    mapping(bytes4 => mapping(bytes4 => address)) public blocks;

    /// @dev : Wrapped LNR struct
    struct NAMES {
        uint64 _wrapped;
        bytes4 _lang;
        bytes4 _type;
        address _royalty;
    }
    mapping(uint => NAMES) public NAME;

    //bytes32 basehash = keccak256(abi.encodePacked(bytes32(0), keccak256("nick")));
    /*
    function DNSDecode(bytes calldata _encoded) public view returns(bytes32 _namehash) {
        uint i = 0;
        uint _index = 0;
        bytes32[] memory labels = new bytes32[](10);
        uint len = 0;
        while (name[i] != 0x0) {
            unchecked {
                len = uint8(bytes1(name[i: ++i]));
                labels[_index] = bytes32(bytes(name[i: i += len]));
                ++_index;
            }
        }
    }
    */

    /**
     * @dev : deposit
     * @param _name : LNR name
     * @param _lang : Language
     * @param _type : Language Family
     */
    function deposit(string calldata _name, bytes4 _lang, bytes4 _type) external {
        bytes32 name32 = bytes32(bytes(_name));
        uint id = uint(name32 >> (256 - (bytes(_name).length * 8)));
        require(NAME[id]._wrapped == 0, "ALREADY_WRAPPED"); // Checks if already wrapped
        require(LNR.owner(name32) == address(this), "WRAPPER_IS_NOT_OWNER"); // Requires: Contract is set as Owner
        require(LNR.addr(name32) == msg.sender, "ADDR_NOT_SET"); // Requires: Name resolves to Sender
        address _block = blocks[_lang][_type];
        if (_block == address(0)) {
            revert InvalidLangType(_lang, _type);
        }
        if (NAME[id]._lang == bytes4(0)) { // check SoftWrap
            (bool ok, bytes memory _result) = _block.staticcall(
                abi.encodeWithSelector(_type, bytes(name))
            );
            if (!ok || !abi.decode(_result, (bool))) {
                revert InvalidName(_name, _lang, _type);
            }
            NAME[id] = NAMES(uint64(block.timestamp), _lang, _type, address(0));
            //Namehash2ID[keccak256(abi.encodePacked(bytes32(0), keccak256(bytes(_name))))] = id;
            emit Transfer(address(0), msg.sender, id);
        } else {
            NAME[id]._wrapped = uint64(block.timestamp);
        }
        unchecked {
            ++balanceOf[msg.sender];
            ++totalSupply;
        }
    }

    /**
     * @dev : batch deposit
     * @param _names : LNR name
     * @param _lang : Language
     * @param _type : Language Family
     */
    function batchDeposit(string[] calldata _names, bytes4 _lang, bytes4 _type) external {
        address _block = blocks[_lang][_type];
        if (_block == address(0)) {
            revert InvalidLangType(_lang, _type);
        }
        bool ok;
        bytes memory _result;
        bytes memory _name;
        bytes32 name32;
        uint id;
        uint len = _names.length;
        for(uint i; i < len;){
            _name = bytes(_names[i++]);
            name32 = bytes32(bytes(_name));
            id = uint(name32 >> (256 - (bytes(_name).length * 8)));
            require(NAME[id]._wrapped == 0, "ALREADY_WRAPPED"); // Checks if already wrapped
            require(LNR.owner(name32) == address(this), "WRAPPER_IS_NOT_OWNER"); // Requires: Contract is set as Owner
            require(LNR.addr(name32) == msg.sender, "ADDR_NOT_SET"); // Requires: Name resolves to Sender
            if (NAME[id]._lang == bytes4(0)) { // check SoftWrap
                (ok, _result) = _block.staticcall(
                    abi.encodeWithSelector(_type, bytes(_name))
                );
                if (!ok || !abi.decode(_result, (bool))) {
                    revert InvalidName(string(_name), _lang, _type);
                }
                NAME[id] = NAMES(uint64(block.timestamp), _lang, _type, address(0));
                //Namehash2ID[keccak256(abi.encodePacked(bytes32(0), keccak256(bytes(_name))))] = id;
                emit Transfer(address(0), msg.sender, id);
            } else {
                NAME[id]._wrapped = uint64(block.timestamp);
                //emit Transfer(address(this), msg.sender, id);
            }
        }
        unchecked {
            balanceOf[msg.sender] += len;
            totalSupply += len;
        }
    }

    /**
     * @dev : checks validity of input
     * @param _name : LNR name
     * @param _lang : Language
     * @param _type : Language Family
     */
    function checkName(string calldata _name, bytes4 _lang, bytes4 _type) public view returns(uint8 len) {
        address _block = blocks[_lang][_type];
        require(_block != address(0), "INVALID_LANG_TYPE");
        (bool ok, bytes memory _result) = _block.staticcall(
            abi.encodeWithSelector(_type, bytes(name))
        );
        if (!ok || abi.decode(_result, (bool))) {
            revert InvalidName(string(_name), _lang, _type);
        }
        len = abi.decode(_result, (uint8));
        require(len != 0, "INVALID_FORMAT");
    }
    
    /**
     * @dev : reserve new LNR name
     * @param _name : LNR name
     * @param _lang : Language
     * @param _type : Language Family
     */
    function reserve(string calldata _name, bytes4 _lang, bytes4 _type) external {
        address _block = blocks[_lang][_type];
        if (_block == address(0)) {
            revert InvalidLangType(_lang, _type);
        }
        (bool ok, bytes memory _result) = _block.staticcall(
            abi.encodeWithSelector(_type, bytes(name))
        );
        if (!ok || !abi.decode(_result, (bool))) {
            revert InvalidName(_name, _lang, _type);
        }
        bytes32 name32 = bytes32(bytes(_name));
        require(LNR.owner(name32) == address(0), "UNAVAILABLE");
        LNR.reserve(name32);
        LNR.setAddress(name32, msg.sender, false);
        unchecked {
            ++balanceOf[msg.sender];
            ++totalSupply;
            uint id = uint(name32 >> (256 - (bytes(_name).length * 8)));
            NAME[id] = NAMES(uint64(block.timestamp), _lang, _type, address(0));
            //Namehash2ID[keccak256(abi.encodePacked(bytes32(0), keccak256(bytes(_name))))] = id;
            emit Transfer(address(0), msg.sender, id);
        }
    }

    /**
     * @dev : batch reserve new LNR name
     * @param _names : LNR name
     * @param _lang : Language
     * @param _type : Language Family
     */
    function batchReserve(string[] calldata _names, bytes4 _lang, bytes4 _type) external {
        address _block = blocks[_lang][_type];
        if (_block == address(0)) {
            revert InvalidLangType(_lang, _type);
        }
        uint id;
        bytes32 name32;
        uint len = _names.length;
        bytes memory _name;
        bytes memory _result;
        bool ok;
        for (uint i; i < len;) {
            _name = bytes(_names[i]);
            (ok, _result) = _block.staticcall(
                abi.encodeWithSelector(_type, _name)
            );
            if (!ok || !abi.decode(_result, (bool))) {
                revert InvalidName(string(_name), _lang, _type);
            }
            name32 = bytes32(_name);
            require(LNR.owner(name32) == address(0), "ALREADY_REGD");
            LNR.reserve(name32);
            LNR.setAddress(name32, msg.sender, false);
            unchecked {
                id = uint(name32 >> (256 - (bytes(_name).length * 8)));
                ++i;
            }
            NAME[id] = NAMES(uint64(block.timestamp), _lang, _type, address(0));
            //Namehash2ID[keccak256(abi.encodePacked(bytes32(0), keccak256(bytes(_name))))] = id;
            emit Transfer(address(0), msg.sender, id);
        }
        unchecked {
            balanceOf[msg.sender] += len;
            totalSupply += len;
        }
    }
    error InvalidName(string _name, bytes4 _lang, bytes4 _type);
    error InvalidLangType(bytes4 _lang, bytes4 _type);

    /**
     * @dev : Soft Wrap an LNR name
     * @param _name : LNR name
     * @param _lang : Language
     * @param _type : Language Family
     */
    function softWrap(string calldata _name, bytes4 _lang, bytes4 _type) public {
        bytes32 name32 = bytes32(bytes(_name));
        uint id = uint(name32 >> (256 - (bytes(_name).length * 8)));
        require(NAME[id]._lang == bytes4(0), "ALREADY_SOFTWRAPPED");
        address _block = blocks[_lang][_type];
        if (_block == address(0)) {
            revert InvalidLangType(_lang, _type);
        }
        address _owner = LNR.owner(name32);
        if (isWrapper[_owner]) {
            _owner = LNR.addr(name32);
        }
        require(_owner != address(0), "NOT_REGD/ADDR_NOT_SET");
        NAME[id] = NAMES(uint64(0), _lang, _type, msg.sender);
        //Namehash2ID[keccak256(abi.encodePacked(bytes32(0), keccak256(bytes(_name))))] = id;
        emit Transfer(address(0), _owner, id);
    }

    function withdraw(uint id) public {
        //_burn(msg.sender, amount);
        emit Withdrawal(msg.sender, id);
        //msg.sender.safeTransferETH(amount);
    }

    /*
    function mintTo(address recipient) public payable returns(uint256) {
        uint256 newItemId = 0;
        //_safeMint(recipient, newItemId);
        return newItemId;
    }
    */

    error NotWrapped(string _name);
    function tokenURI(uint256 id) public view returns(string memory) {
        NAMES memory _n = NAME[id];
        if (_n._lang == bytes4(0)) {
            revert NotWrapped(string(abi.encodePacked(id)));
        }
        return Generator(blocks[_n._lang][_n._type]).generate(id, _n._type);
    }

    /**
     * @notice : 
     * @dev : royalty payment 
     * @param id : token ID
     * @param _salePrice : sale price
     * @return to : address to send royalty 
     * @return amount : ether/token amount to be paid as royalty
     */
    function royaltyInfo(uint256 id, uint256 _salePrice) external view returns(address to, uint256 amount) {
        bytes32 _hash = keccak256(
            abi.encodePacked(
                keccak256(abi.encodePacked(bytes32(0), keccak256(bytes("eth")))),
                keccak256(abi.encodePacked(id))
            )
        );
        // pseudo random, not safe /check timestamp [Chainlink VRF?]
        uint pRand = uint(keccak256(abi.encodePacked(_hash, id, _salePrice, block.timestamp))) % 3;
        if(pRand == 0) {
            address _resolver = ENS.resolver(_hash);
            if (_resolver != address(0)) {
                to = iResolver(_resolver).addr(_hash);
            }
        } else if (pRand == 1){
            to = NAME[id]._royalty;
        }
        if (to == address(0)) {
            to = Dev;
        }
        amount = _salePrice / 100; // 1% fixed
    }

    modifier onlyDev() {
        require(msg.sender == Dev, "ONLY_DEV");
        _;
    }

    /**
     * @dev : transfer contract ownership to new Dev
     * @param newDev : new Dev
     */
    function changeDev(address newDev) external onlyDev {
        emit OwnershipTransferred(Dev, newDev);
        Dev = newDev;
    }

    /**
     * @dev : setInterface
     * @param sig : signature
     * @param value : boolean
     */
    function setInterface(bytes4 sig, bool value) external payable onlyDev {
        require(sig != 0xffffffff, "INVALID_INTERFACE_SELECTOR");
        supportsInterface[sig] = value;
    }
}

interface Generator {
    function generate(uint id, bytes4 _type) external view returns(string memory);
}