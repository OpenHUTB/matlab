function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)




    comments={};

    paramNames.skipThisSignal=0;
    paramNames.unknownParam=0;
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    switch pathItem
    case 'Input-squared product'
        prefixStr='prodOutput';
        paramNames.modeStr=strcat(prefixStr,'Mode');
    case 'Input-sum-squared product'
        prefixStr='memory';
        paramNames.modeStr=strcat(prefixStr,'Mode');
    case 'Accumulator'
        prefixStr='accum';
        paramNames.modeStr=strcat(prefixStr,'Mode');
    case 'Output'
        prefixStr='output';
        paramNames.modeStr=strcat(prefixStr,'Mode');
    otherwise
        paramNames.skipThisSignal=1;
        paramNames.unknownParam=1;
        DTConInfo=SimulinkFixedPoint.DTContainerInfo('',blkObj);
        return;
    end

    modeValStr=blkObj.(paramNames.modeStr);

    if strcmp(modeValStr,'Binary point scaling')

        signValStr=h.getInportSignednessString(blkObj);
        paramNames.wlStr=strcat(prefixStr,'WordLength');
        paramNames.flStr=strcat(prefixStr,'FracLength');
        wlValueStr=blkObj.(paramNames.wlStr);
        flValueStr=blkObj.(paramNames.flStr);
        if strcmpi(signValStr,'Unsigned')
            specifiedDTStr=sprintf('fixdt(0,%s,%s)',wlValueStr,flValueStr);
        elseif strcmpi(signValStr,'Signed')
            specifiedDTStr=sprintf('fixdt(1,%s,%s)',wlValueStr,flValueStr);
        else
            specifiedDTStr=sprintf('fixdt([],%s,%s)',wlValueStr,flValueStr);
        end
    else



        specifiedDTStr=modeValStr;
        paramNames.modeStr='';
        paramNames.wlStr='';
        paramNames.flStr='';
    end

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

end


