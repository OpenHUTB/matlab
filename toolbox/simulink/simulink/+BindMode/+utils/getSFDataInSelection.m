

function selectionRows=getSFDataInSelection(selectionBackendIds,varargin)




    if(nargin==2)
        onlyTestpointedStates=varargin{1};
    else
        onlyTestpointedStates=false;
    end
    selectionRows={};
    selectionIds=[];
    for selectionIdx=1:numel(selectionBackendIds)
        obj=sf('IdToHandle',selectionBackendIds(selectionIdx));
        if(~isa(obj,'Stateflow.State')&&...
            ~isa(obj,'Stateflow.Transition'))
            continue;
        end
        dataUsed=Stateflow.internal.UsesDatabase.GetAllUsesInObject(obj.Id);
        dataIds=[dataUsed.idOfObjectUsed];
        for dataIdx=1:numel(dataIds)
            dataId=dataIds(dataIdx);

            if(any(selectionIds==dataId))
                continue;
            end

            dataObjHandle=sf('IdToHandle',dataIds(dataIdx));
            if(~isa(dataObjHandle,'Stateflow.Data'))
                continue;
            end

            if(onlyTestpointedStates&&~dataObjHandle.LoggingInfo.DataLogging&&~dataObjHandle.TestPoint)
                continue;
            end

            connectStatus=false;
            bindableType=BindMode.BindableTypeEnum.SFDATA;
            bindableName=dataObjHandle.Name;
            sid=Simulink.ID.getSID(dataObjHandle);
            bindableScope=dataObjHandle.Scope;
            bindableMetaData=BindMode.SFDataMetaData(bindableName,sid,bindableScope);
            selectionRows{end+1}=BindMode.BindableRow(connectStatus,bindableType,bindableName,bindableMetaData);%#ok<AGROW>

            selectionIds(end+1)=dataId;%#ok<AGROW>
        end
    end
end