function[maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)




    fixdtSignValStr='1';
    maskSignValStr='Signed';


    switch pathItem
    case 'Product output'
        paramPrefixStr='prodOutput';

    case 'Accumulator'
        paramPrefixStr='accum';

    case 'Gradients'
        paramPrefixStr='memory';

    case 'Output'
        paramPrefixStr='output';
        if strcmp(blkObj.outVelForm,'Magnitude-squared')
            fixdtSignValStr='0';
        else
            fixdtSignValStr='1';
        end
        maskSignValStr=fixdtSignValStr2maskSignValStr(h,fixdtSignValStr);
    otherwise

    end

    [wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=...
    getDTypeInfoForPathItem(h,blkObj,paramPrefixStr,fixdtSignValStr);


