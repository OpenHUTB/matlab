function maskSignValStr=fixdtSignValStr2maskSignValStr(h,fixdtSignValStr)





    switch fixdtSignValStr
    case '1'
        maskSignValStr='Signed';
    case '0'
        maskSignValStr='Unsigned';
    otherwise
        maskSignValStr='Auto';
    end