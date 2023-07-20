

function bindableData=getSFBindableData(HMIBlockHandle,modelName,selectionBackendIds)



    [connectedRows,updateDiagramNeeded]=utils.HMIBindMode.getConnectedRowsForHMIBlock(HMIBlockHandle,modelName);


    widgetBindingType=utils.getWidgetBindingType(HMIBlockHandle);
    if strcmp(widgetBindingType,'ParameterOrVariable')

        bindableData.updateDiagramButtonRequired=updateDiagramNeeded;
        bindableData.bindableRows=connectedRows;
    elseif strcmp(widgetBindingType,'SingleSignal')||...
        strcmp(widgetBindingType,'MultipleSignal')





        selectedRows=locGetBindableSignalRows(selectionBackendIds);
        combinedRows=BindMode.utils.combineSelectedAndConnectedRows(selectedRows,connectedRows);
        bindableData.updateDiagramButtonRequired=updateDiagramNeeded;
        bindableData.bindableRows=combinedRows;
    else

        bindableData.updateDiagramButtonRequired=false;
        bindableData.bindableRows={};
    end
end

function bindableRows=locGetBindableSignalRows(selectionBackendIds)
    bindableRows={};
    checkedDataIds=[];
    for selectionIdx=1:numel(selectionBackendIds)
        objId=selectionBackendIds(selectionIdx);
        obj=sf('IdToHandle',objId);
        isState=isa(obj,'Stateflow.State');
        isBindable=isState||...
        isa(obj,'Stateflow.AtomicSubchart')||...
        isa(obj,'Stateflow.SimulinkBasedState');
        canContainData=isState||...
        isa(obj,'Stateflow.Transition');
        isData=locIsBindableData(obj);
        if isBindable

            bindableRows{end+1}=locBindableRowForState(obj,'self activity');%#ok<*AGROW>


            if isState&&strcmp(obj.Decomposition,'EXCLUSIVE_OR')
                [hasChildren,hasLeaves]=locGetStateHasChildrenAndLeaves(obj.Id);
                if hasChildren
                    bindableRows{end+1}=locBindableRowForState(obj,'child activity');
                end
                if hasLeaves
                    bindableRows{end+1}=locBindableRowForState(obj,'leaf activity');
                end
            end
        end

        if canContainData
            dataUsed=Stateflow.internal.UsesDatabase.GetAllUsesInObject(obj.Id);
            dataIds=[dataUsed.idOfObjectUsed];
            for dataIdx=1:numel(dataIds)
                dataId=dataIds(dataIdx);


                if ismember(dataId,checkedDataIds)
                    continue;
                end
                dataObj=sf('IdToHandle',dataId);
                if locIsBindableData(dataObj)
                    bindableRows{end+1}=locBindableRowForData(dataObj);
                end
                checkedDataIds(end+1)=dataId;
            end
        end


        if isData
            bindableRows{end+1}=locBindableRowForData(obj);
            checkedDataIds(end+1)=objId;
        end
    end
end

function result=locIsBindableData(obj)
    result=false;
    if isa(obj,'Stateflow.Data')&&...
        (strcmp(obj.scope,'Local')||...
        strcmp(obj.scope,'Output'))
        result=true;
    end
end

function[hasChildren,hasLeaves]=locGetStateHasChildrenAndLeaves(stateId)
    hasChildren=false;
    hasLeaves=false;
    children=sf('SubstatesOf',stateId);
    if~isempty(children)
        hasChildren=true;
        leaves=ismember(sf('LeafstatesIn',stateId),children);
        leaves(leaves~=0)=[];
        if~isempty(leaves)
            hasLeaves=true;
        end
    end
end

function bindableRow=locBindableRowForState(state,activity)
    type=BindMode.BindableTypeEnum.SFSTATE;
    name=state.LoggingInfo.LoggingName;
    sid=Simulink.ID.getSID(state);
    metadata=BindMode.SFStateMetaData(name,sid,activity);
    bindableRow=BindMode.BindableRow(false,type,name,metadata);
end

function bindableRow=locBindableRowForData(data)
    connectStatus=false;
    type=BindMode.BindableTypeEnum.SFDATA;
    name=data.Name;
    sid=Simulink.ID.getSID(data);
    scope=data.Scope;
    metadata=BindMode.SFDataMetaData(name,sid,scope);
    bindableRow=BindMode.BindableRow(connectStatus,type,name,metadata);
end
