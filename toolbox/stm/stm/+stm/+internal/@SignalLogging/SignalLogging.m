classdef SignalLogging<handle




    properties(Access=private)
bindModeSourceObj
signalInfo
    end

    methods
        function this=SignalLogging(modelName,harnessName,signalSetId)
            modelToUse=modelName;
            if~isempty(harnessName)
                modelToUse=harnessName;
            end

            this.bindModeSourceObj=BindMode.STMSignalSelectorSourceData(modelToUse,this);
            this.signalInfo.signalSetId=signalSetId;
        end
    end

    methods(Access=private)
        connectedRows=createConnectedSignalMap(this);

        conRows=getConnectedRows(this);

        function activate(this)
            BindMode.BindMode.enableBindMode(this.bindModeSourceObj);
        end
    end

    methods(Access=public)

        formattedData=filterSelectionAddCheckedSignals(this,selectionHandles,activeDropDownValue);


        success=updateSignalSet(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked);
    end

    methods(Static)

        obj=createSignalLoggingObject(modelName,harnessName,ownerName,signalSetId);


        plotIndexStr=reformatPlotIndex(inputPlotIndex);


        fullBlockPath=constructBlockPathToDisplay(blkPathObj);


        deactivateBindMode(modelName);


        oldState=setGlobalDataStoreLogging(varName,sourceType,enableLogging,model);


        [dStoreName,dsmSrcType,blkPathArray]=getDataStoreBlockLoggingInfo(blkPathArray);


        [sigRows,hasBus]=getRowsWithExpandedBuses(sigRows);


        names=getBusLeafNamesForSignal(hierStruct);
        leafCount=getLeafCountFromSignalHierarchy(hierStruct);


        sigRows=getBindableRowsFromMetadata(rowsData);



        updateAllLeafSignals(topBusInfo,checkState);


        sigRows=sanitizeBindModeRows(sigRows);
    end
end