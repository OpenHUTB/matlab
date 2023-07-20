%#codegen







function pos=findLast1(mant)
    coder.allowpcode('plain');

    pos=int16(0);


    if bitand(mant,uint16(hex2dec('0007')))~=0
        pos=pos+8;
        mant=bitshift(mant,8);
    end


    if bitand(mant,uint16(hex2dec('0078')))~=0
        pos=pos+4;
        mant=bitshift(mant,4);
    end


    if bitand(mant,uint16(hex2dec('0180')))~=0
        pos=pos+2;
        mant=bitshift(mant,2);
    end


    if bitand(mant,uint16(hex2dec('0200')))~=0
        pos=pos+1;
    end

end