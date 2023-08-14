function formattedData=filterSelectionAddCheckedSignals(this,selectionHandles,~)

    import stm.internal.SignalLogging.*;

    signalRows=BindMode.utils.getSignalRowsInSelection(selectionHandles);
    signalRows=stm.internal.SignalLogging.getRowsWithExpandedBuses(signalRows);





    varTypes=[BindMode.VarWorkspaceTypeEnum.BASE,BindMode.VarWorkspaceTypeEnum.MODEL,...
    BindMode.VarWorkspaceTypeEnum.DATA_DICTIONARY];
    dsmRows=BindMode.utils.getDSMRowsInSelection(selectionHandles,this.bindModeSourceObj.modelName,varTypes);


    formattedData.bindableRows=[signalRows,dsmRows];
    formattedData.updateDiagramButtonRequired=true;


    connectedRows=this.createConnectedSignalMap();
    if~isempty(connectedRows)

        formattedData.bindableRows=BindMode.utils.combineSelectedAndConnectedRows(formattedData.bindableRows,connectedRows);



        formattedData.bindableRows=stm.internal.SignalLogging.sanitizeBindModeRows(formattedData.bindableRows);
    end







    localPaths=cellfun(@(rw)getUniquePathToElement(rw.bindableMetaData),...
    formattedData.bindableRows,'UniformOutput',false);




    [~,uqIdx]=unique(localPaths,'stable');

    formattedData.bindableRows=formattedData.bindableRows(uqIdx);
end

function uniquePath=getUniquePathToElement(meta)
    uniquePath=meta.blockPathStr;
    if isprop(meta,'outputPortNumber')
        uniquePath=[uniquePath,num2str(meta.outputPortNumber)];
    end

    if isa(meta,'BindMode.SLBusElementMetaData')
        uniquePath=[uniquePath,meta.name];
    end
end