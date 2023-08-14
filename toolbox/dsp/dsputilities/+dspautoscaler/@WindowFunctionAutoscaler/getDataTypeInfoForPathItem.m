function[signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=...
    getDataTypeInfoForPathItem(h,blkObj,pathItem)




    if strcmpi(blkObj.winmode,'Generate window')

        [signValStr,wlValueStr,flValueStr,specifiedDTStr]=...
        getSPCIndependentOutportDataTypeInfo(h,blkObj,1,-1);
        modeDlgStr='dataType';
        wlDlgStr='wordLen';
        flDlgStr='numFracBits';

    else

        [signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=...
        getDTInfoForNonSourceWinFcn(blkObj,pathItem);
    end



    function[signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDTInfoForNonSourceWinFcn(blkObj,pathItem)

        switch pathItem
        case 'Window'
            prefixStr='firstCoeff';
        case 'Product output'
            prefixStr='prodOutput';
        case 'Output'
            prefixStr='output';
        otherwise
            prefixStr='';
        end

        signValStr='Signed';
        wlValueStr='';
        flValueStr='';
        specifiedDTStr='';
        flDlgStr='';
        wlDlgStr='';
        modeDlgStr='';

        if~isempty(prefixStr)
            modeDlgStr=[prefixStr,'Mode'];
            specifiedDTStr=blkObj.(modeDlgStr);
            flDlgStr=[prefixStr,'FracLength'];
            wlDlgStr=[prefixStr,'WordLength'];

            if isempty(regexp(specifiedDTStr,'^(Inherit |Inherit:|Same as|Same word|Smallest )','ONCE'))

                wlValueStr=blkObj.(wlDlgStr);

                if strcmpi(specifiedDTStr,'Specify word length')

                    flValueStr='Best precision';
                    specifiedDTStr=sprintf('fixdt(1,%s)',wlValueStr);
                else
                    flValueStr=blkObj.(flDlgStr);
                    specifiedDTStr=sprintf('fixdt(1,%s,%s)',wlValueStr,flValueStr);
                end
            end
        end


