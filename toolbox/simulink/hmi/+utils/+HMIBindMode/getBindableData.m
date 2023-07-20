

function bindableData=getBindableData(HMIBlockHandle,modelName,selectionHandles)



    [connectedRows,updateDiagramNeeded_bound]=utils.HMIBindMode.getConnectedRowsForHMIBlock(HMIBlockHandle,modelName);


    widgetBindingType=utils.getWidgetBindingType(HMIBlockHandle);
    if(strcmp(widgetBindingType,'ParameterOrVariable'))

        [selectionRows,updateDiagramNeeded_selection]=BindMode.utils.getParameterRowsInSelection(selectionHandles);

        combinedRows=BindMode.utils.combineSelectedAndConnectedRows(selectionRows,connectedRows);
        updateDiagramNeeded=false;
        if(updateDiagramNeeded_bound||updateDiagramNeeded_selection)
            updateDiagramNeeded=true;
        end
        bindableData.updateDiagramButtonRequired=updateDiagramNeeded;
        bindableData.bindableRows=combinedRows;

    elseif(strcmp(widgetBindingType,'SingleSignal')||strcmp(widgetBindingType,'MultipleSignal'))

        for idx=1:numel(selectionHandles)
            if(selectionHandles(idx)==0)
                continue;
            end
            if(strcmp(get_param(selectionHandles(idx),'Type'),'port'))&&...
                (strcmp(get_param(selectionHandles(idx),'PortType'),'state'))
                selectionHandles(idx)=0;
                continue;
            end
        end

        signalRows=BindMode.utils.getSignalRowsInSelection(selectionHandles);

        chartRows=BindMode.utils.getSFChartActivityInSelection(selectionHandles);

        selectionRows=[signalRows,chartRows];
        combinedRows=BindMode.utils.combineSelectedAndConnectedRows(selectionRows,connectedRows);
        bindableData.updateDiagramButtonRequired=false;
        bindableData.bindableRows=combinedRows;
    else
        bindableData.updateDiagramButtonRequired=false;
        bindableData.bindableRows={};
    end
end