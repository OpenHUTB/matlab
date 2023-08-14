function ReplaceMPSwitchContigDataPortToEnum(block,h,Data)


    if(Data.isEnumType==false)

        return;
    end




    ports=get_param(block,'Ports');
    nDataPorts=ports(1)-1;

    if(nDataPorts==1)

        reason=DAStudio.message('SimulinkBlocks:upgrade:MPSwitchOneDataPortEnumUnsupported');
        appendTransaction(h,block,reason,{});
        return;
    end


    defaultDataPort=get_param(block,'DataPortForDefault');
    if(strcmp(defaultDataPort,'Additional data port'))
        nDataPorts=nDataPorts-1;
    end


    dataPortOrder=get_param(block,'DataPortOrder');
    isZeroBased=strcmpi(dataPortOrder,'Zero-based contiguous');


    startIdx=1;
    endIdx=nDataPorts;
    if(isZeroBased)
        startIdx=0;
        endIdx=nDataPorts-1;
    end


    Valid=isempty(find(ismember(startIdx:endIdx,Data.EnumInts)==0,1));

    if(~Valid)
        reason=...
        DAStudio.message('SimulinkBlocks:upgrade:MPSwitchDeadportsInBlockUnsupported');
        appendTransaction(h,block,reason,{});
        return;
    end



    enumClass=Data.CPortDtype;
    enumStr='{ ';
    for dIdx=startIdx:endIdx

        eIdx=find(Data.EnumInts==dIdx);
        if(dIdx~=startIdx)
            enumStr=[enumStr,', '];%#ok<*AGROW>
        end
        enumStr=[enumStr,enumClass,'.',Data.EnumStrs{eIdx(1)}];
    end

    enumStr=[enumStr,'}'];

    funcSet=uSafeSetParam(h,block,...
    'DataPortOrder','Specify indices',...
    'DataPortIndices',enumStr);

    reason=DAStudio.message('SimulinkBlocks:upgrade:MPSwitchEnumCaseCompatible');
    appendTransaction(h,block,reason,{funcSet});

    set_param(h.MyModel,'ModelUpgradeActive','off');

end
