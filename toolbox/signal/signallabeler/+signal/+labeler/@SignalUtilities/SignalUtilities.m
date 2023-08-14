classdef SignalUtilities<handle





    methods(Static,Hidden)

        function deleteAllSLRuns()
            eng=Simulink.sdi.Instance.engine;
            slRuns=eng.getAllRunIDs('signallabeler');
            for idx=1:length(slRuns)
                eng.deleteRun(slRuns(idx));
            end
        end
    end
end

