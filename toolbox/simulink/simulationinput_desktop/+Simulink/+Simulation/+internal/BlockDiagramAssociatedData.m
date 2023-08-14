classdef BlockDiagramAssociatedData<Simulink.Simulation.internal.BlockDiagramAssociatedDataInterface



    methods(Static)
        function TF=isRegistered(modelHandle,dataId)
            TF=Simulink.BlockDiagramAssociatedData.isRegistered(modelHandle,dataId);
        end

        function register(modelHandle,dataId,dataType)
            Simulink.BlockDiagramAssociatedData.register(modelHandle,dataId,dataType);
        end

        function unregister(modelHandle,dataId)
            Simulink.BlockDiagramAssociatedData.unregister(modelHandle,dataId);
        end

        function set(modelHandle,dataId,value)
            Simulink.BlockDiagramAssociatedData.set(modelHandle,dataId,value);
        end
    end
end