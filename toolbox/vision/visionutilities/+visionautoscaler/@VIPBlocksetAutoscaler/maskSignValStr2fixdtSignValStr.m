function fixdtSignValStr=maskSignValStr2fixdtSignValStr(~,maskSignValStr)





    switch maskSignValStr
    case 'Signed'
        fixdtSignValStr='1';
    case 'Unsigned'
        fixdtSignValStr='0';
    otherwise
        fixdtSignValStr='[]';
    end