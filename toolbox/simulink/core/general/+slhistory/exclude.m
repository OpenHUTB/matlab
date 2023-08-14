


classdef exclude
    properties(Constant)
        DataName='SLExcludeModelFromSimulinkHistory';
    end

    methods(Static,Access=private)
        function flag=hasDataRegistered(modelHandle)
            flag=Simulink.BlockDiagramAssociatedData.isRegistered(...
            modelHandle,slhistory.exclude.DataName);
        end
    end

    methods(Static,Access=public)
        function set(modelHandle)
            if~slhistory.exclude.hasDataRegistered(modelHandle)
                Simulink.BlockDiagramAssociatedData.register(...
                modelHandle,slhistory.exclude.DataName,'any');
            end
        end

        function isExcluded=get(modelHandle)
            isExcluded=slhistory.exclude.hasDataRegistered(modelHandle);
        end
    end
end
