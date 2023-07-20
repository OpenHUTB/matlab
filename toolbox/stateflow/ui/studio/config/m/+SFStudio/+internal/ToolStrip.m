function ToolStrip(fncname,cbinfo,action)



    fcn=str2func(fncname);
    if isvalid(action)
        fcn(cbinfo,action);
    end
end



function ToolstripExecutionOrder(cbinfo,action)
    entries=getExecutionOrderEntries(cbinfo);
    if isempty(entries)||~all(strcmpi(action.entries.toArray,entries))
        action.validateAndSetEntries(getExecutionOrderEntries(cbinfo));
    end
    if isempty(action.callback)
        action.setCallbackFromArray(@SFStudio.Utils.ExecutionOrderMenuItemCB,dig.model.FunctionType.Action);
    end
    action.enabled=false;
    if cbinfo.selection.size==1
        chartId=SFStudio.Utils.getChartId(cbinfo);
        chartHandle=sf('IdToHandle',chartId);
        objectId=double(cbinfo.selection.at(1).backendId);
        objH=sf('IdToHandle',objectId);
        switch class(objH)
        case{'Stateflow.State','Stateflow.AtomicSubchart'}
            type=sf('get',objectId,'state.type');


            if type==1||type==3
                action.enabled=chartHandle.UserSpecifiedStateTransitionExecutionOrder;
            else
                action.enabled=false;
            end
        case 'Stateflow.Transition'
            if~isempty(objH.Destination)&&~isempty(entries)
                action.enabled=chartHandle.UserSpecifiedStateTransitionExecutionOrder;
            else
                action.enabled=false;
            end


        otherwise
            action.enabled=false;
        end
        if action.enabled&&~sfprivate('is_object_commented',objectId)
            if isscalar(entries)
                action.selectedItem=num2str(1);
            else
                if isa(objH,'Stateflow.Transition')
                    action.selectedItem=num2str(objH.ExecutionOrder);
                else
                    action.selectedItem=num2str(sf('get',objectId,'state.executionOrder'));
                end
            end
        end
    end

end



function entries=getExecutionOrderEntries(cbinfo)
    chartId=SFStudio.Utils.getChartId(cbinfo);
    entries={};

    chartObj=sf('IdToHandle',chartId);
    if cbinfo.selection.size==1
        if chartObj.UserSpecifiedStateTransitionExecutionOrder
            objM3I=cbinfo.selection.at(1);
            id=double(objM3I.backendId);

            if id~=0


                superWireId=SFStudio.Utils.getTransitionSuperWire(id);
                if~isempty(superWireId)&&superWireId~=0
                    id=superWireId;
                end

                siblingList=sf('SemanticSiblingsOf',id);
                entries=cell(1,length(siblingList));
                for i=1:length(siblingList)
                    entries{i}=num2str(i);
                end
            end
        end
    end
end
