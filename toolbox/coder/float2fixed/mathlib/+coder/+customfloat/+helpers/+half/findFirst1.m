%#codegen







function pos=findFirst1(mant)
    coder.allowpcode('plain');

    pos=int16(10);


    if bitand(mant,uint16(hex2dec('0700')))~=0
        pos=pos-8;
        mant=bitshift(mant,-8);
    end


    if bitand(mant,uint16(hex2dec('00F0')))~=0
        pos=pos-4;
        mant=bitshift(mant,-4);
    end


    if bitand(mant,uint16(hex2dec('000C')))~=0
        pos=pos-2;
        mant=bitshift(mant,-2);
    end


    if bitand(mant,uint16(hex2dec('0002')))~=0
        pos=pos-1;
    end

end
