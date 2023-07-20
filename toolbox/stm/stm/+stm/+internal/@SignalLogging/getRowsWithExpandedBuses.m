function[expRows,hasBus]=getRowsWithExpandedBuses(signalRows)
    import stm.internal.SignalLogging.*;


    expRowCount=length(signalRows);
    hasBus=false;
    for idx=1:length(signalRows)
        pHdls=get_param(signalRows{idx}.bindableMetaData.blockPathStr,'PortHandles');
        busInfo=get_param(pHdls.Outport(signalRows{idx}.bindableMetaData.outputPortNumber),'SignalHierarchy');

        if~isempty(busInfo.Children)
            expRowCount=expRowCount+getLeafCountFromSignalHierarchy(busInfo);
            hasBus=true;
        end
    end

    if expRowCount==length(signalRows)

        expRows=signalRows;
        return
    end


    expRows=cell(1,expRowCount);


    rowCntr=1;
    for idx=1:length(signalRows)
        pHdls=get_param(signalRows{idx}.bindableMetaData.blockPathStr,'PortHandles');
        busInfo=get_param(pHdls.Outport(signalRows{idx}.bindableMetaData.outputPortNumber),'SignalHierarchy');

        if isempty(busInfo.Children)
            expRows{rowCntr}=signalRows{idx};
            rowCntr=rowCntr+1;
            continue;
        end


        busInfo.SignalName=signalRows{idx}.bindableMetaData.name;


        leafNames=getBusLeafNamesForSignal(busInfo);


        expRows{rowCntr}=getTopBusRow(signalRows{idx});
        rowCntr=rowCntr+1;


        for lf_indx=1:length(leafNames)
            expRows{rowCntr}=getLeafElementRow(leafNames{lf_indx},signalRows{idx});
            rowCntr=rowCntr+1;
        end
    end

end

function row=getTopBusRow(sigRow)
    connectStatus=false;
    bindableName=[sigRow.bindableMetaData.name,' (all)'];
    bindableType=BindMode.BindableTypeEnum.BUSOBJECT;
    bindableMetaData=BindMode.SLSignalMetaData(bindableName,...
    sigRow.bindableMetaData.blockPathStr,sigRow.bindableMetaData.outputPortNumber);
    row=BindMode.BindableRow(connectStatus,bindableType,bindableName,bindableMetaData);
end

function row=getLeafElementRow(bindableName,sigRow)
    connectStatus=false;
    bindableType=BindMode.BindableTypeEnum.BUSLEAFSIGNAL;
    bindableMetaData=BindMode.SLBusElementMetaData(bindableName,sigRow.bindableMetaData);
    row=BindMode.BindableRow(connectStatus,bindableType,bindableName,bindableMetaData);
end