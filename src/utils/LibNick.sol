// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

library LibNick {

    function isValidNick(string calldata _name) internal pure returns(uint) {
        bytes memory _b = bytes(_name);
        uint len = _b.length;
        if(len > 32) { // LNR limit bytes32 
            return 0;
        }
        for(uint i = 0; i < len; i++) {
            //az09 only
            if(_b[i] < 0x30 || _b[i] > 0x7A) {
                return 0;
            } else if(_b[i] > 0x39 && _b[i] < 0x60){
                return 0;
            }
        }
        return uint(bytes32(_b) >> (256 - (len * 8)));
    }

    function _Nick2ID(string calldata _str) internal pure returns(uint){
        bytes memory _b = bytes(_str);
        require(_b.length < 33, "32_Char_Limit");
        return uint(bytes32(_b) >> (256 - (_b.length * 8)));
    }
    function _ID2Nick(uint _num) internal pure returns(string memory _str) {
        return string(abi.encodePacked(_num));
    }
}