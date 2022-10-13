// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "src/Base.sol";

//import "src/interface/iENS.sol";
//import "src/interface/iERC721.sol";
//import "src/utils/LibNick.sol";
//import "src/utils/LibString.sol";

/// @notice LNR to ENS (CCIP) Bridge and Wrapper
/// @notice Based on Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
/// @author 0xc0de4c0ffee for BENSYC.ETH
abstract contract ERC721 is Base {
    //using LibString for uint;
    //using LibNick for string;
    //using LibString for address;
    /*//////////////////////////////////////////////////////////////
                         Name Service Bridge
    //////////////////////////////////////////////////////////////*/
    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    //function tokenURI(uint256 id) external view returns (string memory);
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);

    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function ownerOf(uint256 id) external view returns (address owner) {
        owner = LNR.owner(bytes32(id));
        if(isWrapper[owner]){
            owner = LNR.addr(bytes32(id));
        }
        require(owner != address(0), "NOT_REGD/BURNED");
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;



    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) external {
        require(isWrapped[id] == 0, "NOT_WRAPPED");
        bytes32 _name = bytes32(abi.encodePacked(id));
        require(msg.sender == LNR.addr(_name) || msg.sender == LNR.owner(_name), "NOT_AUTHORIZED");
        getApproved[id] = spender;
        emit Approval(msg.sender, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) external {
        require(balanceOf[msg.sender] > 0, "NOTHING_WRAPPED");
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public {
        require(isWrapped[id] == 0, "NOT_WRAPPED");
        bytes32 _name = bytes32(abi.encodePacked(id));
        require(from == LNR.addr(_name), "NOT_FROM_OWNER");
        require(
            msg.sender == from || 
            isApprovedForAll[from][msg.sender] || 
            msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );
        LNR.setAddress(_name, to, false);
        unchecked {
            --balanceOf[from];
            ++balanceOf[to];
        }
        delete getApproved[id];
        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) external {
        transferFrom(from, to, id);
        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) external {
        transferFrom(from, to, id);
        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    /*function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }*/

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/
/*
    function _mint(address to, uint256 id) internal {
        //require(to != address(0), "INVALID_RECIPIENT");
        require(LNR.owner(bytes32(id)) == address(0), "ALREADY_MINTED");
        // Counter overflow is incredibly unrealistic.
        unchecked {
            ++balanceOf[to];
        }
        //LNR.owner(bytes32(id)) = to;
        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal {
        address owner = LNR.owner(bytes32(id));

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            balanceOf[owner]--;
        }

        delete LNR.owner(bytes32(id));

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }
*/
    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////

    function _safeMint(address to, uint256 id) internal {
        _mint(to, id);
        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal {
        _mint(to, id);
        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }*/
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
