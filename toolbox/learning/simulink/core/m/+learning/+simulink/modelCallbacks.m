classdef modelCallbacks

    methods(Static)
        function startFunction(modelName)
            learning.simulink.glowGrader.clearAllGlows('GlowGrader',modelName);
            learning.simulink.resetGraderBadge(modelName);
            learning.simulink.closeNotificationBar(modelName);
            learning.simulink.Application.getInstance().clearStateflowBreakpoints()
        end

        function stopFunction(modelName)


            if strcmp(get_param(modelName,'SimulationStatus'),'stopped')
                save_system(modelName,'SaveDirtyReferencedModels',true);
            end
            learning.simulink.refreshSignalWindows();
        end
    end
end

