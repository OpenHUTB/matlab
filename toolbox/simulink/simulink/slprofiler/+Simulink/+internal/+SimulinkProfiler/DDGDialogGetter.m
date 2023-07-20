classdef DDGDialogGetter<Simulink.internal.SimulinkProfiler.DDGDialogGetterInterface

    methods
        function dialog=get(~,dialogSource)
            dialog=DAStudio.ToolRoot.getOpenDialogs(dialogSource);
        end
    end

end