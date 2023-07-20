

function selectionRows=getSFStatesInSelection(selectionBackendIds,varargin)






    onlyTestpointedStates=false;
    if(nargin>=2)
        onlyTestpointedStates=varargin{1};
    end
    includeChildAndLeafActivity=false;
    if(nargin>=3)
        includeChildAndLeafActivity=varargin{2};
    end
    selectionRows={};
    for idx=1:numel(selectionBackendIds)
        stateHandle=sf('IdToHandle',selectionBackendIds(idx));
        if(~isa(stateHandle,'Stateflow.State'))
            continue;
        end
        if(onlyTestpointedStates&&~stateHandle.LoggingInfo.DataLogging&&~stateHandle.TestPoint)
            continue;
        end

        selectionRows{end+1}=locBindableRowForState(stateHandle,'self activity');%#ok<*AGROW>

        if(includeChildAndLeafActivity)
            [hasChildren,hasLeaves]=locGetObjectHasChildrenAndLeaves(stateHandle.Id);
            if hasChildren
                selectionRows{end+1}=locBindableRowForState(stateHandle,'child activity');
            end
            if hasLeaves
                selectionRows{end+1}=locBindableRowForState(stateHandle,'leaf activity');
            end
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

function[hasChildren,hasLeaves]=locGetObjectHasChildrenAndLeaves(stateId)
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
