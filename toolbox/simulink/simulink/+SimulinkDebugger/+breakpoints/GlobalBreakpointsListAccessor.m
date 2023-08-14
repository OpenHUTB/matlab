classdef GlobalBreakpointsListAccessor<handle





    methods(Access=public,Static)
        function instance=getInstance()
            persistent uniqueInstance;
            if isempty(uniqueInstance)
                instance=SimulinkDebugger.breakpoints.GlobalBreakpointsList();
                uniqueInstance=instance;
            else
                instance=uniqueInstance;
            end
        end
    end
end