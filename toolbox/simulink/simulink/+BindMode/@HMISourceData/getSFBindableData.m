

function bindableData=getSFBindableData(this,selectionBackendIds,~)





    if~strcmp(get_param(this.modelName,'SimulationStatus'),'stopped')
        activeEditor=BindMode.utils.getLastActiveEditor();
        BindMode.utils.showHelperNotification(activeEditor,...
        message('SimulinkHMI:HMIBindMode:StateflowRuntimeBindingNotSupported').string());
        return;
    end



    validHandle=[];
    for idx=1:numel(selectionBackendIds)
        handle=sf('IdToHandle',selectionBackendIds(idx));
        if isa(handle,'Stateflow.State')||...
            isa(handle,'Stateflow.Transition')||...
            isa(handle,'Stateflow.Data')||...
            isa(handle,'Stateflow.AtomicSubchart')||...
            isa(handle,'Stateflow.SimulinkBasedState')
            validHandle=handle;
            break;
        end
    end
    if isempty(validHandle)



        selectionBackendIds=[];
    else


        selectionFullPath=BindMode.utils.getSFHierarchicalPathArray(get(validHandle,'Path'),false);
        sourceFullPath=this.hierarchicalPathArray;
        if~BindMode.utils.isSameModelInstance(sourceFullPath,selectionFullPath)
            activeEditor=BindMode.utils.getLastActiveEditor();
            BindMode.utils.showHelperNotification(activeEditor,...
            message('SimulinkHMI:HMIBindMode:ModelRefNotSupportedText').string());

            selectionBackendIds=[];
        end
    end


    bindableData=utils.HMIBindMode.getSFBindableData(this.sourceElementHandle,this.modelName,selectionBackendIds);
end