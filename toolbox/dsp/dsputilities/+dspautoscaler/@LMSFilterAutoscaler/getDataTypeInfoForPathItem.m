function[signValStr,wlValueStr,flValueStr,specifiedDTStr,...
    flDlgStr,modeDlgStr,wlDlgStr]=...
    getDataTypeInfoForPathItem(h,blkObj,pathItem)





    [modeDlgStr,wlDlgStr,flDlgStr,skipThisSignal,unknownParam]=...
    getLMSFltMdWLFLDlgPrmInfo(h,pathItem,blkObj.stepflag,blkObj.Algo);

    [signValStr,wlValueStr,flValueStr,specifiedDTStr]=...
    getSLFixPtSgnWLFLStrValsFromBlkObjDlgPrms(blkObj,...
    modeDlgStr,wlDlgStr,flDlgStr,skipThisSignal,unknownParam);

    if(strncmp(pathItem,'Error',5)||...
        strncmp(pathItem,'Output',6)||...
        strcmp(pathItem,'1'))


        specifiedDTStr='Same as first input';
    end

end


function[signValStr,wlValueStr,flValueStr,specifiedDTStr]=...
    getSLFixPtSgnWLFLStrValsFromBlkObjDlgPrms(blkObj,...
    modeDlgStr,wlDlgStr,flDlgStr,skipThisSignal,unknownParam)

    signValStr='Signed';
    wlValueStr='';
    flValueStr='';


    if unknownParam||skipThisSignal
        specifiedDTStr='';
    else
        specifiedDTStr=blkObj.(modeDlgStr);
        if isempty(regexp(specifiedDTStr,...
            '^(Inherit |Inherit:|Same as|Same word|Smallest )','ONCE'))

            wlValueStr=blkObj.(wlDlgStr);
            if strcmpi(specifiedDTStr,'Specify word length')

                flValueStr='Best precision';
                specifiedDTStr=sprintf('fixdt(1,%s)',wlValueStr);
            else

                flValueStr=blkObj.(flDlgStr);
                specifiedDTStr=...
                sprintf('fixdt(1,%s,%s)',wlValueStr,flValueStr);
            end
        end
    end

end
