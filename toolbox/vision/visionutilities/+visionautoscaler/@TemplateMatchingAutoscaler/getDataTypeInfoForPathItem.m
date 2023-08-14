function[maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)%#ok





    fixdtSignValStr='1';
    maskSignValStr='Signed';


    switch pathItem

    case 'Accumulator'
        paramPrefixStr='accum';

    case 'Product output'
        paramPrefixStr='prodOutput';

    case 'Output'
        paramPrefixStr='output';


        fixdtSignValStr=getInportFixdtSignValStr(h,blkObj,1);
        maskSignValStr=fixdtSignValStr2maskSignValStr(h,fixdtSignValStr);

    otherwise

    end

    [wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=...
    getDTypeInfoForPathItem(h,blkObj,paramPrefixStr,fixdtSignValStr);


