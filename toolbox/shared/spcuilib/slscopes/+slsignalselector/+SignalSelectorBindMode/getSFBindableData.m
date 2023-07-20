function bindableData=getSFBindableData(sourceBlock,selectionBackendIds,activeDropDownValue)










    signalHandles=get_param(sourceBlock.sourceElementHandle,'IOSignals');


    activeAxes=str2double(activeDropDownValue(end));



    boundDataCheck=-1;
    if activeAxes<=length(signalHandles)

        if~isempty(signalHandles{activeAxes})
            boundDataCheck=signalHandles{activeAxes}.Handle;
        end
    end

    connectedRows=[];
    if(boundDataCheck>0)

        connectedRows=slsignalselector.SignalSelectorBindMode.getConnectedRowsForViewers(signalHandles,...
        activeAxes);
    end
    bindableData.updateDiagramButtonRequired=false;
    bindableData.bindableRows={};
    if(sourceBlock.allowStateflowBinding())











        try


            selectionRows=BindMode.utils.getSFStatesInSelection(selectionBackendIds,true);
            selectionRowsForSFData=BindMode.utils.getSFDataInSelection(selectionBackendIds,true);
            selectionRows=[selectionRows,selectionRowsForSFData];
        catch
            selectionRows=[];
        end



        inModelRef=~isempty(selectionRows)&&(numel(selectionRows{1}.bindableMetaData.hierarchicalPathArr)>2);
        if(inModelRef&&~sourceBlock.allowModelReferenceBinding())
            selectionRows=[];
            activeEditor=BindMode.utils.getLastActiveEditor();
            if~isempty(activeEditor)
                BindMode.utils.showHelperNotification(activeEditor,message('Spcuilib:scopes:StateflowModelRefNotSupportedText').string())
            end
        end


        combinedRows=BindMode.utils.combineSelectedAndConnectedRows(selectionRows,connectedRows);
        bindableData.bindableRows=combinedRows;
    end


end