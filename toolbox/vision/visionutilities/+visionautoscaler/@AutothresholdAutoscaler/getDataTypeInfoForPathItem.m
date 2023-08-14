function[maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)




    fixdtSignValStr='1';
    maskSignValStr='Signed';


    switch pathItem
    case 'Product 1'
        paramPrefixStr='P1';

    case 'Product 2'
        paramPrefixStr='P2';

    case 'Product 3'
        paramPrefixStr='P3';

    case 'Product 4'
        paramPrefixStr='P4';


        fixdtSignValStr=getInportFixdtSignValStr(h,blkObj,1);
        maskSignValStr=fixdtSignValStr2maskSignValStr(h,fixdtSignValStr);
    case 'Accumulator 1'
        paramPrefixStr='A1';

    case 'Accumulator 2'
        paramPrefixStr='A2';

    case 'Accumulator 3'
        paramPrefixStr='A3';

    case 'Accumulator 4'
        paramPrefixStr='A4';


        fixdtSignValStr=getInportFixdtSignValStr(h,blkObj,1);
        maskSignValStr=fixdtSignValStr2maskSignValStr(h,fixdtSignValStr);

    case 'Quotient'
        paramPrefixStr='Q1';

    case 'Eff Metric'
        paramPrefixStr='EM';

    otherwise

    end

    [wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=...
    getDTypeInfoForPathItem(h,blkObj,paramPrefixStr,fixdtSignValStr);


