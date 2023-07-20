classdef CachedMessageAccessor<handle





    methods(Access=public,Static)
        function instance=getInstance()
            persistent uniqueInstance;
            if isempty(uniqueInstance)
                instance=SimulinkDebugger.CachedMessages();
                uniqueInstance=instance;
            else
                instance=uniqueInstance;
            end
        end
    end
end