

classdef CovEngineProxyCleanupToken<handle







    methods
        function this=CovEngineProxyCleanupToken()
        end

        function delete(~)
        end
    end

    methods(Static,Hidden)
        function cleanupToken=getToken(testdataId)













            callbacks=cv('get',testdataId,'.cleanupCallbacks');
            if isempty(callbacks)
                cleanupToken=SlCov.CovEngineProxyCleanupToken();
                callbacks={...
                onCleanup(@()delete(cleanupToken)),...
                cleanupToken};
                cv('set',testdataId,'.cleanupCallbacks',callbacks);
            else
                cleanupToken=callbacks{2};
            end
        end
    end
end

