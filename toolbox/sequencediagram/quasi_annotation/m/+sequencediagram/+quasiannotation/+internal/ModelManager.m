classdef ModelManager<handle






    properties(Transient)
ModelHandle
    end

    properties
        SequenceDiagramManagers=sequencediagram.quasiannotation.internal.SequenceDiagramManager.empty();
    end

    methods
        function obj=ModelManager(modelHandle)
            obj.ModelHandle=modelHandle;
        end
    end
end
