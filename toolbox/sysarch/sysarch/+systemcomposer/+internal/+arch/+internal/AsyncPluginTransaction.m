classdef AsyncPluginTransaction<handle




    properties(GetAccess=public,SetAccess=private)
        ModelName;
    end

    methods
        function obj=AsyncPluginTransaction(modelName)


            if~Simulink.internal.isArchitectureModel(modelName)
                error('SystemArchitecture:Architecture:InvalidOrDeletedSystemComposerModel',message('SystemArchitecture:Architecture:InvalidOrDeletedSystemComposerModel').getString);
            end

            obj.ModelName=modelName;


            systemcomposer.internal.arch.internal.processBatchedPluginEvents(obj.ModelName);
        end

        function delete(obj)

            systemcomposer.internal.arch.internal.processBatchedPluginEvents(obj.ModelName);
        end

        function commit(obj)

            delete(obj);
        end
    end
end


