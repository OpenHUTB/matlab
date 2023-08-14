






function revertSimulationInput(obj)

    if~isempty(obj.simInRevertTempState)&&isvalid(obj.simInRevertTempState)

        if bdIsLoaded(obj.debugMdl)&&...
            ~strcmp(get_param(obj.debugMdl,'SimulationStatus'),'paused')

            delete(obj.simInRevertTempState);

            obj.disableDirtyFlagForAllModels;
            obj.simInRevertTempState=[];

            obj.clearEditorNotification;
        end
    end
end
