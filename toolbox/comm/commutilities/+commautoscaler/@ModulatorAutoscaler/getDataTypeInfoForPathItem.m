function[signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)%#ok





    signValStr='Signed';
    wlValueStr='';
    flValueStr=getModulatorFracLenValStr(blkObj);
    specifiedDTStr=blkObj.outDtype;
    flDlgStr='outFracLen';
    modeDlgStr='outDtype';
    wlDlgStr='outWordLen';



    switch(blkObj.outDtype)
    case 'Fixed-point'

        wlValueStr=blkObj.outWordLen;

    case 'User-defined'

        outDTInfo=getCommDigBBModDTInfo(blkObj);
        wlValueStr=outDTInfo.DataTypeWordLength;
    end


    function flValueStr=getModulatorFracLenValStr(blkObj)
        switch blkObj.outDtype
        case{'Fixed-point','User-defined'}
            if strcmp(blkObj.outFracLenMode,'User-defined')
                flValueStr=blkObj.outFracLen;
            else
                flValueStr='Best precision';
            end

        otherwise
            flValueStr='Best precision';
        end
