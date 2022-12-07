// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "src/interface/iLNR.sol";
import "src/interface/iENS.sol";
import "src/interface/iERC721.sol";
//import "src/utils/LibNick.sol";
//import "src/utils/LibString.sol";

/**
 * @author 0xc0de4c0ffee, sshmatrix (BeenSick Labs/BENSYC)
 * @title WLNR Base
 */
abstract contract Base {
    address public Dev;
    string public constant name = "Wrapped Linagee Name Registrar";
    string public constant symbol = "WLNR";
    /*//////////////////////////////////////////////////////////////
                         Name Service Bridge
    //////////////////////////////////////////////////////////////*/
    iLNR public immutable LNR;
    iENS public immutable ENS;
    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/
    uint public totalSupply;
    mapping(uint => uint) public isWrapped;
    //mapping(uint => bool) public isSoftWrapped;
    mapping(address => bool) public isWrapper;
    mapping(address => uint256) public balanceOf;
    mapping(bytes4 => bool) public supportsInterface;
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor() {
        Dev = msg.sender;
        LNR = iLNR(0x5564886ca2C518d1964E5FCea4f423b41Db9F561);
        ENS = iENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
        //supportsInterface[0x00000000] = true;
        supportsInterface[type(iERC165).interfaceId] = true;
        supportsInterface[type(iERC721).interfaceId] = true;
        supportsInterface[type(iERC721Metadata).interfaceId] = true;
        //isWrapper[address(this)] = true;
    }
}