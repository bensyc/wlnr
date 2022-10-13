// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

/// @notice Devanagari Block 
/// @notice Range U+0900 ~~ U+097F (128 code points) 
/// @notice https://en.wikipedia.org/wiki/Devanagari_(Unicode_block) 
/// @author 
interface iWLNR{

}
contract ASCII {
    //mapping(bytes32 => TYPE) internal _check;
    mapping(bytes4 => bool) public supportsInterface;
    event Update(uint8 indexed _type, bytes _hex);
    constructor(){
        supportsInterface[ASCII.isAlpha.selector] = true;
        supportsInterface[ASCII.isNum.selector] = true;
        supportsInterface[ASCII.isAlphaNum.selector] = true;
    }
    //bytes32 internal immutable xn = bytes32(bytes("xn--"));
    //require(bytes32(_name[:4]) != xn, "INVALID_FORMAT");
    function isAlpha(bytes calldata _name) external view returns(uint _len){
        _len = _name.length;        
        if(_len > 32){
            return 0;
        }
        bytes1 _b1;
        for(uint i; i < _len;){
            unchecked{
                _b1 = _name[i++];
            }
            if(_b1 < bytes1("a") || _b1 > bytes1("z")){
                return 0;
            }
        }
        return _len;
    }    
    
    function isNum(bytes calldata _name) external view returns(uint _len){
        _len = _name.length;        
        if(_len > 32){
            return 0;
        }
        bytes1 _b1;
        for(uint i; i < _len;){
            unchecked{
                _b1 = _name[i++];
            }
            if(_b1 < bytes1("0") || _b1 > bytes1("9")){
                return 0;
            }
        }
        return _len;
    }/*

    function isNum(bytes calldata _name) external view returns(bool){
        uint _len = _name.length;
        for(uint i; i < _len;){
            if(_check[bytes32(_name[i:i+=3])] != TYPE.NUMBER){
                return false;
            }
        }
        return true;
    }
*/
    function isAlphaNum(bytes calldata _name) external view returns(uint){
        uint _len = _name.length;
        require(_len < 33 && _len % 3 == 0, "INVALID_LENGTH");
        bytes32 _b32;
        bytes32 _last;
        for(uint i; i < _len;){
            _b32 = bytes32(_name[i:i+=3]);
            _last = _b32;
        }
        return _len / 3;
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
