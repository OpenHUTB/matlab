function signValStr=valueStr2DescriptionStr(~,fidxtSgValStr)





    switch fidxtSgValStr
    case '1'
        signValStr='Signed';
    case '0'
        signValStr='Unsigned';
    otherwise
        signValStr='Auto';
    end