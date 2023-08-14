function[maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)













    fixdtSignValStr='1';
    maskSignValStr='Signed';


    switch pathItem
    case 'Accumulator'
        paramPrefixStr='accum';

    case 'Product output'
        paramPrefixStr='prodOutput';

    otherwise



        wlValueStr='';
        flValueStr='';
        flDlgStr='';
        specifiedDTStr='';
        modeDlgStr='';
        wlDlgStr='';
        return;
    end

    [wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=...
    getDTypeInfoForPathItem(h,blkObj,paramPrefixStr,fixdtSignValStr);


