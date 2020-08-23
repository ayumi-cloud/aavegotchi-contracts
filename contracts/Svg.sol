//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;
//pragma experimental ABIEncoderV2;

contract Svg {

  struct SVGContract {
    address svgContract;
    uint16 offset;
    uint16 size;
  }
  SVGContract[] svgs;
  string[] svg;
  

  function setSvg(string calldata _svg) external {
    //console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
    //greeting = _greeting;
    svg.push(_svg);    
  }

  function setSvgContract(string calldata _svg, uint[] memory sizes) external {
    // 61_00_00 -- PUSH2 (size)
    // 60_00 -- PUSH1 (code position)
    // 60_00 -- PUSH1 (mem position)    
    // 39 CODECOPY
    // 61_00_00 PUSH2 (size)
    // 60_00 PUSH1 (mem position)
    // f3 RETURN 
    bytes memory init = hex"610000_600e_6000_39_610000_6000_f3";                           
    byte size1 = byte(uint8(bytes(_svg).length));
    byte size2 = byte(uint8(bytes(_svg).length >> 8));
    init[2] = size1;
    init[1] = size2;
    init[10] = size1;
    init[9] = size2;    
    bytes memory code = abi.encodePacked(init, _svg);
        
    address newSvgContract;
    
    assembly {
      newSvgContract := create(0, add(code, 32), mload(code))
    }
    uint offset = 0;
    for(uint i; i < sizes.length; i++) {
      svgs.push(SVGContract(newSvgContract,uint16(offset),uint16(sizes[i])));
      offset += sizes[i];
    }
    
  }
 
  
}