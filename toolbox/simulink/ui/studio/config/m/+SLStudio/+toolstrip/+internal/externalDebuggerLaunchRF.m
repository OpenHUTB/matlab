function externalDebuggerLaunchRF(cbinfo,action)
    action.enabled=false;

    modelHandle=cbinfo.model.handle;

    if isempty(modelHandle)
        return;
    end

    simModeTopModel=get_param(modelHandle,'SimulationMode');

    editorModelHandle=cbinfo.editorModel.handle;
    if editorModelHandle~=modelHandle

        if~strcmpi(simModeTopModel,'normal')

            action.enabled=false;
            return;
        end
        paths=GLUE2.HierarchyService.getPaths(cbinfo.studio.App.getActiveEditor().getHierarchyId());
        for i=1:length(paths)-1
            if strcmp(get_param(paths{i},'BlockType'),'ModelReference')
                sim_mode=get_param(paths{i},'SimulationMode');
                if~strcmpi(sim_mode,'normal')

                    action.enabled=false;
                    return;
                end
            end

        end
    end

    switch simModeTopModel
    case{'normal','accelerator'}
        action.enabled=true;
    otherwise
        action.enabled=false;
    end
end