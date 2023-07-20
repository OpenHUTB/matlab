function bindableData=getBindableData(sourceBlock,selectionHandles,activeDropDownValue)







    try

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


        [~,modelRefBlockIndex]=slsignalselector.utils.SignalSelectorUtilities.hasSelectionModelRef(selectionHandles);

        if~isempty(modelRefBlockIndex)

            selectionHandles=selectionHandles(~modelRefBlockIndex);
        end



        inModelRef=slsignalselector.utils.SignalSelectorUtilities.i_IsObjectInsideModelRef(sourceBlock.sourceElementHandle,selectionHandles);

        if inModelRef
            selectionRows=BindMode.utils.getSignalRowsInSelection(selectionHandles,inModelRef);
        else


            selectionHandles=slsignalselector.utils.getVariantSubsystemPortHandles(selectionHandles);

            selectionRows=BindMode.utils.getSignalRowsInSelection(selectionHandles);
        end


        selectionRows=slsignalselector.utils.SignalSelectorUtilities.notBindableSignalTypes(selectionRows);



        combinedRows=BindMode.utils.combineSelectedAndConnectedRows(selectionRows,connectedRows);

        bindableData.updateDiagramButtonRequired=false;
        bindableData.bindableRows=combinedRows;
    catch ex
        bindableData=[];
        bindableData.updateDiagramButtonRequired=false;
        if strcmp(ex.identifier,'Simulink:blocks:ModelNotFound')
            disp(ex.message);
        end
        if isa(ex,'MException')
            ex.message;
        end
    end

end
