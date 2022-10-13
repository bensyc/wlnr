// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "src/interface/iLNR.sol";
import "src/interface/iWLNR.sol";

/// @notice Devanagari Block 
/// @notice Range U+0900 ~~ U+097F (128 code points) 
/// @notice https://en.wikipedia.org/wiki/Devanagari_(Unicode_block) 
/// @author 

contract Devanagari{
    enum NAGARI{
        BLANK,
        NUMBER,
        CONSTANT,
        VOWEL,
        MODIFIER
    }

    mapping(bytes32 => NAGARI) internal _check;
    mapping(bytes4 => bool) public supportsInterface;
    event Update(uint8 indexed _type, bytes _hex);

    iLNR public immutable LNR;
    iWLNR public immutable WLNR;
    constructor(address _wlnr){
        //setup(bytes("0123456789"), NAGARI.NUMBER); // 10 loops
        WLNR = iWLNR(_wlnr);
        LNR = iLNR(0x5564886ca2C518d1964E5FCea4f423b41Db9F561);
        supportsInterface[Devanagari.isAlpha.selector] = true;
        supportsInterface[Devanagari.isNum.selector] = true;
        supportsInterface[Devanagari.isAlpha.selector] = true;
    }
    /*
    function validate(bytes calldata _name, uint8 _type) external view returns(uint, uint){
        uint _len = _name.length;
        require(_len < 33 && _len % 3 == 0, "INVALID_LENGTH");
        bool ok;
        if(_type == 2){
            ok = isAlpha(_name, _len);
        } else if(_type == 3){
            ok = isAlphaNum(_name, _len);
        } else {
            ok = isNum(_name, _len);
        }
        return(ok ? (uint(bytes32(_name) >> (256 - (_len * 8))), _len / 3) : (0,0));
    }*/

    function isAlpha(bytes calldata _name) external view returns(bool){
        uint _len = _name.length;
        if(_len > 32 || _len % 3 > 0) return false;
        bytes32 _b32;
        bytes32 _last;
        NAGARI _nagari;
        for(uint i; i < _len;){
            _b32 = bytes32(_name[i:i+=3]);
            _nagari = _check[_b32];
            if(_nagari == NAGARI.MODIFIER && _check[_last] != NAGARI.CONSTANT){
                return false;
            } else if(uint8(_nagari) < uint8(NAGARI.CONSTANT)){
                return false;
            }
            _last = _b32;
        }
        return true;
    }

    function isNum(bytes calldata _name) external view returns(bool){
        uint _len = _name.length;
        if(_len > 32 || _len % 3 > 0) return false;
        for(uint i; i < _len;){
            if(_check[bytes32(_name[i:i+=3])] != NAGARI.NUMBER){
                return false;
            }
        }
        return true;
    }

    function isAlphaNum(bytes calldata _name) external view returns(bool){
        uint _len = _name.length;
        if(_len > 32 || _len % 3 != 0) return false;
        bytes32 _b32;
        bytes32 _last;
        NAGARI _nagari;
        bool _alpha;
        bool _num;
        for(uint i; i < _len;){
            _b32 = bytes32(_name[i:i+=3]);
            _nagari = _check[_b32];
            if(_nagari == NAGARI.MODIFIER && _check[_last] != NAGARI.CONSTANT){
                return false;
            } else if(_nagari == NAGARI.BLANK){
                return false;
            }
            _last = _b32;
        }
        return true;
    }
    function generate(uint id, bytes4 _type) external view returns(string memory) {
        string memory _name = string(abi.encodePacked(id));
        // json + svg generator
        return string.concat("data:text/plain;", _name);
    }
    function setup(bytes calldata _data, NAGARI _nagari) public {    
        uint _len = _data.length;
        require(_len % 3 == 0, "INVALID_LENGTH");
        for(uint i = 0; i < _len;){
            _check[bytes32(_data[i:i+=3])] = _nagari;
        }
        emit Update(uint8(_nagari), _data);
    }

    /// @dev : revert on fallback
    fallback() external payable {
        revert();
    }

    /// @dev : revert on receive
    receive() external payable {
        revert();
    }
}
