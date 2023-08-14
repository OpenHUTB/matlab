function[maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)




    fixdtSignValStr='1';
    maskSignValStr='Signed';





    switch pathItem
    case 'Accumulator'
        paramPrefixStr='accum';


        fixdtSignValStr=getInportFixdtSignValStr(h,blkObj,1);
        maskSignValStr=fixdtSignValStr2maskSignValStr(h,fixdtSignValStr);

    case 'Output'
        paramPrefixStr='output';


        fixdtSignValStr=getInportFixdtSignValStr(h,blkObj,1);
        maskSignValStr=fixdtSignValStr2maskSignValStr(h,fixdtSignValStr);

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


