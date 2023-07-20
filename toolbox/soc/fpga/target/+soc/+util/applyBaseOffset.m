function address=applyBaseOffset(baseaddr,offset)
    address=dec2hex(hex2dec(baseaddr)+hex2dec(offset));
end